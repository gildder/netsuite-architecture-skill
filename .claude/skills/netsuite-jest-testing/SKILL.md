---
name: netsuite-jest-testing
description: |-
  Testing de proyectos NetSuite SDF (SuiteScript 2.x, TypeScript compilado a AMD) con Jest y
  @oracle/suitecloud-unit-testing. Usar al configurar Jest, escribir o revisar tests de dominio,
  casos de uso, repositorios (N/search, N/record, N/log) o entry points (RESTlet, User Event,
  Suitelet, Map/Reduce), al medir cobertura o al depurar errores como "define is not defined".
---

# NetSuite Jest Testing

Cómo testear un proyecto NetSuite SDF con Jest usando la configuración y los stubs oficiales de Oracle. Complementa a `netsuite-clean-architecture`: esa skill define las capas, esta define cómo se prueba cada una.

## Qué se testea en cada capa

| Capa | Tipo de test | Dobles | Qué se verifica |
| --- | --- | --- | --- |
| Dominio | Unitario | Ninguno | Reglas, cálculos, bordes (nulos, ceros, fechas) |
| Caso de uso | Unitario | Fake literal del puerto | Orquestación, `success`/`failure`, mensajes |
| Repositorio | Adaptador | `jest.mock('N/*')` | Mapper NetSuite → dominio, resultados vacíos, manejo de errores |
| Entry point | Smoke | `jest.mock('<módulo del use case>')` | Validación de parámetros y delegación al use case |
| Filtros de búsqueda, SuiteQL, governance, permisos | Integración | Cuenta sandbox | No se simulan en Jest |

Un mock de `N/search` solo prueba que se llamó a la API, no que el filtro sea correcto. Por eso, los tests de repositorio se concentran en el mapeo y en los caminos de error, y la corrección de las búsquedas se valida en sandbox.

## Configuración

### Base oficial

```js
// jest.config.js
const SuiteCloudJestConfiguration = require('@oracle/suitecloud-unit-testing/jest-configuration/SuiteCloudJestConfiguration');
const cliConfig = require('./suitecloud.config');

const base = SuiteCloudJestConfiguration.build({
  projectFolder: cliConfig.defaultProjectFolder,
  projectType: SuiteCloudJestConfiguration.ProjectType.ACP, // SUITEAPP para SuiteApps
});

module.exports = {
  ...base,
  // Necesario con pnpm (ver Gotchas).
  transformIgnorePatterns: [
    '/node_modules/(?!\\.pnpm/@oracle.suitecloud-unit-testing|@oracle/suitecloud-unit-testing)',
  ],
  collectCoverageFrom: [
    '<rootDir>/src/FileCabinet/SuiteScripts/<proyecto>/**/*.js',
  ],
  coverageThreshold: {
    global: { statements: 90, branches: 85, functions: 85, lines: 90 },
  },
};
```

Qué aporta `build()`:

- `moduleNameMapper` de cada `N/*` a su stub en `@oracle/suitecloud-unit-testing/stubs/`.
- Alias `SuiteScripts/...` hacia `src/FileCabinet/SuiteScripts` (ACP).
- Transformer Babel con `transform-amd-to-commonjs`, solo para archivos `.js`.

### TypeScript

El transformer oficial solo procesa `.js`. Hay dos caminos:

- **Testear el JS compilado (recomendado por defecto).** Los tests son `.js` e importan vía `SuiteScripts/<proyecto>/...`. Se prueba exactamente lo que se despliega. Requiere compilar antes: `"test": "tsc && jest"` o `pnpm build && pnpm test`.
- **ts-jest sobre el fuente.** Sobrescribir `transform` con `'^.+\\.ts$': 'ts-jest'` y un `tsconfig` de test con `module: commonjs`. Da feedback inmediato y tests tipados, pero el AMD desplegado deja de estar testeado. Validar con una prueba de concepto antes de adoptarlo.

### Cobertura honesta

Sin `collectCoverageFrom`, Jest solo mide los archivos que algún test importa, y los módulos sin tests no aparecen en el reporte. Siempre declarar `collectCoverageFrom`. Si los repositorios o entry points quedan fuera del alcance, excluirlos de forma explícita, por ejemplo con `'!**/repository/**'`. No dejar que desaparezcan en silencio.

## Patrones

### Caso de uso: fake literal del puerto

```js
import { GetCustomer } from 'SuiteScripts/<proyecto>/features/customer/usecase/get-customer.usecase';

function makeFakeRepo(overrides = {}) {
  return {
    findByDocumentNumber: () => null,
    ...overrides,
  };
}

test('returns failure when the customer does not exist', () => {
  const result = new GetCustomer(makeFakeRepo()).execute('123');
  expect(result.success).toBe(false);
});
```

Sin `jest.mock` ni imports de `N/*`: el puerto es un objeto literal.

### Repositorio: stubs `N/*` con automock

Los stubs oficiales son métodos vacíos, no `jest.fn()`. Hay que activar el automock con `jest.mock('N/...')` para que Jest convierta cada método en `jest.fn()`.

```js
jest.mock('N/search');
jest.mock('N/record');
jest.mock('N/log');

import search from 'N/search';
import log from 'N/log';
import { NetSuiteCustomerRepository } from 'SuiteScripts/<proyecto>/features/customer/repository/customer.repository';

function fakeResult(values, texts = {}) {
  return {
    getValue: (column) => values[column] ?? null,
    getText: (column) => texts[column] ?? '',
  };
}

function mockSearchRows(rows) {
  search.create.mockReturnValue({
    run: () => ({
      getRange: () => rows,
      each: (callback) => {
        // Like NetSuite: iteration stops when the callback returns a falsy value.
        for (const row of rows) if (!callback(row)) break;
      },
    }),
  });
}

beforeEach(() => jest.clearAllMocks());

test('maps a search row to the domain', () => {
  mockSearchRows([fakeResult({ internalid: '7', creditlimit: '1000' }, { custentity_type: 'NORMAL' })]);

  const customer = new NetSuiteCustomerRepository().findByDocumentNumber('123');

  expect(customer.toJSON()).toEqual(expect.objectContaining({ id: '7' }));
  expect(search.create).toHaveBeenCalledWith(expect.objectContaining({ type: 'customer' }));
});

test('returns null and logs when the search throws', () => {
  search.create.mockImplementation(() => {
    throw new Error('boom');
  });

  expect(new NetSuiteCustomerRepository().findByDocumentNumber('1')).toBeNull();
  expect(log.error).toHaveBeenCalled();
});
```

Otros módulos siguen el mismo patrón:

- `search.lookupFields.mockReturnValue({ campo: 'valor' })`
- `record.load.mockReturnValue({ getValue: jest.fn(), setValue: jest.fn(), save: jest.fn() })`
- `record.submitFields` se verifica con `toHaveBeenCalledWith`.

Reglas para los fakes de resultados:

- Reproducir la forma real de la API: `getValue` devuelve strings (`'1000'`, `'T'`), `getText` devuelve la etiqueta de la lista, y `each` sigue iterando mientras el callback devuelva `true`.
- Probar los bordes que vienen de NetSuite: campos vacíos, `null`, checkbox en `'T'`/`'F'` o `true`/`false`, y números como string.

### Entry point: smoke test con el use case mockeado

```js
jest.mock('N/log');
jest.mock('SuiteScripts/<proyecto>/features/customer/usecase/get-customer.usecase');

import { GetCustomer } from 'SuiteScripts/<proyecto>/features/customer/usecase/get-customer.usecase';
import { get } from 'SuiteScripts/<proyecto>/suitescript/restlet/mc_rl_get_customer';

test('rejects a request without documentNumber', () => {
  expect(JSON.parse(get({})).success).toBe(false);
});

test('delegates to the use case', () => {
  GetCustomer.prototype.execute.mockReturnValue({ success: true, data: { id: '7' } });
  expect(JSON.parse(get({ documentNumber: '123' }))).toEqual({ success: true, data: { id: '7' } });
});
```

`jest.mock` con el alias resuelve al mismo archivo que el `define([...'../../features/...'])` relativo del script, así que el mock aplica. Para User Events y Suitelets se arma el `context` a mano (`{ newRecord, type, request, response }`) con `jest.fn()` donde haga falta y se llama a `beforeSubmit(context)`, `onRequest(context)`, etc.

## Gotchas

- **pnpm: `ReferenceError: define is not defined` al importar `N/*`.** El `transformIgnorePatterns` oficial solo excluye `node_modules/@oracle/suitecloud-unit-testing`. Con pnpm, la ruta real es `node_modules/.pnpm/@oracle+suitecloud-unit-testing@x/node_modules/@oracle/...`, así que el stub AMD no se transforma. La solución es el patrón de la sección Configuración.
- **Windows: no escapar `+` en `transformIgnorePatterns`.** Jest reescribe los separadores de ruta y elimina los escapes `\\`, por lo que `\\+` termina siendo un cuantificador. Usar `.` en su lugar.
- **Build desactualizado.** Si los tests importan el JS compilado, un `jest` sin compilar antes prueba código viejo. Encadenar la compilación en el script de test o en CI.
- **Fechas y zona horaria.** Fijar `TZ` en el script de test (por ejemplo `TZ=America/La_Paz jest`) e inyectar la fecha de referencia en el dominio. No usar `new Date()` dentro de reglas.
- **`N/log`.** Con automock es un `jest.fn()` sin efecto. Afirmar sobre él solo cuando el log es parte del contrato, por ejemplo el camino de error.
- **Governance y permisos.** No se pueden simular en Jest; se validan en sandbox.
- **Estado entre tests.** Usar `beforeEach(() => jest.clearAllMocks())`, y `mockReset` si un test usa `mockImplementation` que no debe filtrarse a los siguientes.

## Checklist

- [ ] `collectCoverageFrom` declarado y `coverageThreshold` definido.
- [ ] `transformIgnorePatterns` compatible con pnpm, si el proyecto usa pnpm.
- [ ] Cada dominio con reglas tiene su test, incluidos los bordes.
- [ ] Cada use case expuesto tiene su test con un fake literal del puerto.
- [ ] Cada repositorio tiene tests de mapeo, de resultado vacío y de error.
- [ ] Cada entry point tiene un smoke test de validación y delegación.
- [ ] El script de test compila antes de ejecutar Jest (si se testea el JS compilado).
- [ ] Ningún test depende del orden de ejecución ni de la fecha actual.
