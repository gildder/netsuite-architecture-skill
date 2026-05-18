# NetSuite Clean Architecture - Troubleshooting Guide

## Problemas Comunes y Soluciones

---

## 1. Compilación TypeScript

### Problema: esModuleInterop contamina el output AMD

**Síntoma:** Cada archivo .js compilado comienza con ~33 líneas de código helper:
```javascript
var __importStar = (this && this.__importStar) || ...
var __createBinding = (this && this.__createBinding) || ...
```

**Causa:** Tener `"esModuleInterop": true` combinado con `import * as x from 'N/x'`

**Solución:**
1. Eliminar `"esModuleInterop": true` del tsconfig.json
2. En NetSuite siempre usar namespace imports que son AMD-native:
```typescript
// ✅ CORRECTO
import record from 'N/record';

// ❌ INCORRECTO (contamina output)
import * as record from 'N/record';
```

---

### Problema: JSDoc @NApiVersion desaparece en la compilación

**Síntoma:** El header JSDoc requerido por NetSuite no aparece en el .js compilado.

**Causa:** tsc en modo AMD no preserva comentarios JSDoc a nivel de archivo.

**Solución:**
1. Usar script post-build `scripts/prepend-headers.js`
2. O ejecutar normalizador: `.\normalize-ts.ps1 "archivo.ts"`

---

### Problema: TypeScript no compila a la carpeta correcta

**Síntoma:** Los archivos .js se generan en otra ubicación esperada.

**Causa:** Configuración incorrecta en tsconfig.json paths.

**Solución:**
```json
{
  "compilerOptions": {
    "outDir": "./src/FileCabinet/SuiteScripts/MiProyecto",
    "rootDir": "./src/TypeScripts"
  }
}
```

---

## 2. Biome

### Problema: Biome no encuentra archivos en Windows

**Síntoma:** Biome reporta "0 files linted"

**Causa:** El patrón `["**/*.{ts,json}"]` no funciona en Biome 1.9.4 en Windows.

**Solución:**
```json
// biome.json
{
  "files": {
    "include": ["**/*.ts", "**/*.json"]
  }
}
```

---

### Problema: Biome formatea archivos compilados

**Síntoma:** Biome modifica los archivos .js en FileCabinet

**Solución:**
```json
// biome.json
{
  "files": {
    "include": ["**/*.ts", "**/*.json"]
  },
  "overrides": [
    {
      "include": ["src/FileCabinet/**"],
      "linter": { "enabled": false },
      "organizeImports": { "enabled": false }
    }
  ]
}
```

---

## 3. NetSuite Scripts

### Problema: Error "Missing required script property"

**Síntoma:** Error al cargar script en NetSuite

**Causa:** Falta el JSDoc con @NScriptType

**Solución:**
Agregar al inicio del archivo:
```typescript
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType Suitelet
 */
```

---

### Problema: Error "Module does not have function"

**Síntoma:** NetSuite no encuentra la función del script

**Causa:** El export no usa el formato correcto de EntryPoints

**Solución:**
```typescript
// ❌ INCORRECTO
export function onRequest(context) { }

// ✅ CORRECTO
export let onRequest: EntryPoints.Suitelet.onRequest = (context) => { };
```

---

### Problema: record.create() falla

**Síntoma:** Error al crear registro

**Causa:** Usar string en lugar de enum para type

**Solución:**
```typescript
// ❌ INCORRECTO
record.create({ type: 'invoice' });

// ✅ CORRECTO
record.create({ type: record.Type.INVOICE });
```

---

### Problema: search.run() retorna null

**Síntoma:** Error al ejecutar búsqueda

**Causa:** No manejar el resultado correctamente

**Solución:**
```typescript
const resultSet = searchObj.run();
const range = resultSet.getRange({ start: 0, end: 1000 });
if (range && range.length > 0) {
    // Procesar resultados
}
```

---

## 4. Proyecto

### Problema: No se crea la estructura correcta

**Síntoma:** Las carpetas no se generan como se espera

**Causa:** El tipo de proyecto no coincide con la estructura

**Solución:**
- Verificar orkidns.config.json
- Usar el script correcto según tipo: create-small.ps1, create-medium.ps1, create-large.ps1

---

### Problema: Git no clona el template

**Síntoma:** Error al ejecutar git clone

**Causa:** permisos o problema de red

**Solución:**
1. Verificar que Git esté instalado: `git --version`
2. Verificar conexión: `git ls-remote https://github.com/gildder/netsuite-ts-sdf-template.git`

---

### Problema: yarn install falla

**Síntoma:** Error al instalar dependencias

**Causa:** Node.js no instalado o versión incompatible

**Solución:**
1. Verificar Node.js: `node --version` (requiere 18+)
2. Verificar npm: `npm --version`
3. Limpiar cache: `npm cache clean --force`

---

## 5. OrkidNS

### Problema: orkidns check no encuentra problemas

**Síntoma:** No detecta archivos en ubicación incorrecta

**Causa:** El script busca en rutas hardcodeadas

**Solución:**
1. Verificar que el proyecto tenga orkidns.config.json
2. Ejecutar desde la raíz del proyecto

---

### Problema: orkidns normalize no funciona

**Síntoma:** El script no modifica el archivo

**Causa:** El archivo ya está normalizado o tiene formato no reconocido

**Solución:**
1. Verificar que el archivo sea .ts
2. Verificar que no tenga errores de sintaxis previos

---

## 6. Deploy

### Problema: Error al hacer deploy

**Síntoma:** Error en SDF o en FileCabinet

**Causa:**
- Archivo deploy.xml incorrecto
- Archivos .js no compilados

**Solución:**
1. Verificar deploy.xml: `src/deploy.xml`
2. Compilar: `yarn build`
3. Verificar que los .js existan en FileCabinet

---

### Problema: Script no aparece en NetSuite

**Síntoma:** El script no está disponible en la cuenta

**Causa:**
- No se hizo deploy del script
- El customscript_*.xml no existe

**Solución:**
1. Verificar que existe el archivo XML del script
2. Ejecutar `yarn deploy`
3. Verificar en NetSuite: SuiteCloud > Script Deployment

---

## 7. Debugging

### Verificar estructura del proyecto

```powershell
# Ver estructura de carpetas
Get-ChildItem -Path "src" -Recurse -Directory | Select-Object FullName

# Ver archivos TypeScript
Get-ChildItem -Path "src" -Filter "*.ts" -Recurse | Select-Object FullName
```

### Verificar compilación

```powershell
# Ver errores TypeScript
npx tsc --noEmit

# Ver archivos generados
Get-ChildItem -Path "src/FileCabinet/SuiteScripts" -Filter "*.js" -Recurse
```

### Verificar configuración

```powershell
# Ver package.json
Get-Content "package.json" | ConvertFrom-Json | Select-Object -ExpandProperty scripts

# Ver tsconfig.json
Get-Content "tsconfig.json" | ConvertFrom-Json | Select-Object -ExpandProperty compilerOptions

# Ver orkidns.config.json
Get-Content "orkidns.config.json" | ConvertFrom-Json
```

---

## 8. Código de Error Comunes

| Código | Significado | Solución |
|--------|-------------|----------|
| SS_201 | Error de permisos | Verificar N/record permissions |
| SS_202 | Error de búsqueda | Revisar filtros de search |
| SS_203 | Error de validación | Verificar datos de entrada |
| SS_204 | Error de despliegue | Verificar deploy.xml |

---

## 9. Recursos Adicionales

- [NetSuite Help Center](https://system.netsuite.com/app/help/helpcenter.nl)
- [SuiteScript 2.1 API](https://docs.oracle.com/en/cloud/saas/netsuite/ns-cloud-suiteScript_2_1.html)
- [TypeScript Docs](https://www.typescriptlang.org/docs/)
- [Biome Docs](https://biomejs.dev/docs/)

---

## 10. Obtener Ayuda

Si los problemas persisten:

1. Verificar README.md para información general
2. Verificar EXAMPLES.md para ejemplos de uso
3. Verificar ARCHITECTURE.md para conceptos de arquitectura
4. Ejecutar `.\orkidns.ps1 hint` para sugerencias

---

Última actualización: Mayo 2026