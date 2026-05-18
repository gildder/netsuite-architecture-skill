# Guía de Usuario - OrkidNS

## ¿Qué es OrkidNS?

**OrkidNS** (Orquestador NetSuite) es una herramienta CLI que te ayuda a:
- ✅ Validar que tu código siga la arquitectura correcta
- ✅ Crear componentes automáticamente desde una idea
- ✅ Normalizar archivos TypeScript para NetSuite
- ✅ Suggestionar mejoras para tu código

---

## Instalación

### Opción 1: Usar desde el proyecto skill

```powershell
cd netsuite-architecture-skill/scripts
.\orkidns.ps1
```

### Opción 2: Copiar a tu proyecto

1. Copiar `orkidns.ps1` a la carpeta `scripts` de tu proyecto
2. Asegurate de tener `orkidns.config.json` en la raíz

---

## Primeros Pasos

### 1. Inicializar OrkidNS en tu proyecto

```powershell
cd tu-proyecto
..\netsuite-architecture-skill\scripts\orkidns.ps1 init
```

Esto crea el archivo `orkidns.config.json` con la configuración de tu proyecto.

### 2. Ver la ayuda

```powershell
.\orkidns.ps1 help
```

---

## Comandos

### init - Inicializar proyecto

Inicializa OrkidNS detectando el tipo de proyecto y dominios.

```powershell
.\orkidns.ps1 init
```

**Salida esperada:**
```
📦 Inicializando OrkidNS en: .
✅ orkidns.config.json creado

Configuración:
  - Tipo: grande
  - Dominios: Sales, Inventory
```

---

### add - Crear componentes desde una idea

Describe lo que querés hacer y OrkidNS sugiere los componentes necesarios.

```powershell
.\orkidns.ps1 add "crear servicio para facturas"
```

**Salida:**
```
📋 Basándome en tu idea: "crear servicio para facturas"

Componentes sugeridos:
✅ Entity: Modules/Sales/Domain/entities/invoice.entity.ts
✅ Service: Modules/Sales/Application/services/invoice.service.ts
✅ Repository: Modules/Sales/Infrastructure/persistence/invoice.repository.ts
✅ Validation: Modules/Sales/validations/invoice.validation.ts

¿Querés que los cree? (sí/no)
```

**Palabras clave reconocidas:**

| Keyword | Componentes que genera |
|---------|----------------------|
| crear, nuevo, insertar | Entity + Service + Repository |
| leer, obtener, consultar | Repository + Service |
| integrar, conectar, api | Adapter + Port |
| sincronizar, importar | UseCase + Adapter |
| validar, verificar | Validation |
| transformar, convertir | Transform |
| crud, completo | Entity + Service + Repository + Validation + Transform |
| programado, cron | Scheduled |
| mapreduce, masivo | MapReduce |

---

### check - Validar arquitectura

Verifica que el código siga las reglas de Clean Architecture.

```powershell
.\orkidns.ps1 check
```

**Salida:**
```
🔍 Verificando arquitectura en: .
   📊 Archivos TypeScript: 24

✅ Arquitectura válida
```

**Validaciones que realiza:**
- ✅ Archivos en carpetas correctas según su tipo
- ✅ Sin dependencias circulares
- ✅ Domain no depende de Application ni Infrastructure
- ✅ Ports usados para integraciones externas

**Problemas que detecta:**
```
❌ Problemas encontrados:
   - Service en Domain: Modules/Sales/Domain/invoice.service.ts
   → Mover a Application/services/
```

---

### list - Listar componentes

Muestra todos los archivos TypeScript organizados por carpeta.

```powershell
.\orkidns.ps1 list
```

**Salida:**
```
📋 Componentes en: .

🏠 Sales (12 archivos)
   - invoice.entity.ts
   - invoice.service.ts
   - invoice.repository.ts
   - invoice.validation.ts
   ...

🏠 Inventory (8 archivos)
   - item.entity.ts
   - item.service.ts
   ...
```

---

### info - Guía de estructura

Muestra qué puede y qué NO puede ir en cada carpeta.

```powershell
.\orkidns.ps1 info
```

**Salida:**
```
📁 Guía de estructura de carpetas:

  PEQUEÑO (directo):
    [Dominio]/*.service.ts
    [Dominio]/*.repository.ts
    [Dominio]/*.types.ts

  MEDIANO/LARGE (capas):
    Domain/entities/         → *.entity.ts
    Application/services/    → *.service.ts
    Application/transforms/  → *.transform.ts
    Application/ports/       → *.port.ts
    Application/use-cases/   → *.usecase.ts
    Application/dtos/        → *.dto.ts
    Infrastructure/          → *.repository.ts
    Infrastructure/adapters/→ *.adapter.ts
    validations/             → *.validation.ts
```

**Ver info de una carpeta específica:**
```powershell
.\orkidns.ps1 info "Application/services"
```

---

### fix - Corregir problemas

Intenta corregir automáticamente los problemas de arquitectura.

```powershell
.\orkidns.ps1 fix
```

**Salida:**
```
🔧 Buscando problemas de arquitectura...

❌ Encontrado: adapter en Application/services/
   → Moviendo a Infrastructure/adapters/

✅ Corregido: Modules/Sales/Application/services/vtex.adapter.ts
   → Modules/Sales/Infrastructure/adapters/vtex.adapter.ts

❌ Encontrado: service en Domain/
   → Moviendo a Application/services/
```

---

### normalize - Corregir TypeScript

Normaliza archivos TypeScript al formato NetSuite.

```powershell
# Normalizar un archivo
.\orkidns.ps1 normalize "src\TypeScripts\Sales\invoice.ts"

# Normalizar una carpeta
.\orkidns.ps1 normalize "src\TypeScripts\Sales"
```

**¿Qué hace?**
- ✅ Agrega JSDoc (`@NApiVersion 2.1`, `@NModuleScope Public`)
- ✅ Detecta el tipo de script automáticamente
- ✅ Agrega `@NScriptType` según corresponda
- ✅ Agrega import de `EntryPoints` si es necesario
- ✅ Convierte `record.Type.INVOICE` (string a enum)
- ✅ Convierte exports al formato NetSuite

**Ejemplo de corrección:**

*Antes:*
```typescript
import record from 'N/record';

export function onRequest(context) {
  const rec = record.create({ type: 'invoice' });
  context.response.write('Hello');
}
```

*Después:*
```typescript
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType Suitelet
 */

import record from 'N/record';
import { EntryPoints } from 'N/types';

export let onRequest: EntryPoints.Suitelet.onRequest = (context) => {
  const rec = record.create({ type: record.Type.INVOICE });
  context.response.write('Hello');
};
```

---

### hint - Sugerencias

Analiza tu código y sugiere mejoras.

```powershell
.\orkidns.ps1 hint
```

**Salida:**
```
💡 Sugerencias para el proyecto:

1. ⚠️ Falta archivo de constantes
   → Considerá crear Shared/constants/sales.constants.ts

2. ⚠️ Múltiples integraciones externas detectadas
   → Considerá usar patrón Ports/Adapters para VTEX, Gateway, Pagos

3. ✅ Buen uso de Entity con validación

4. 💡 El proyecto tiene 3+ dominios
   → Considerá usar estructura Modules/ para mejor organización
```

---

## Archivo de Configuración

OrkidNS usa un archivo de configuración `orkidns.config.json`:

```json
{
  "version": "1.0",
  "project": {
    "name": "mi-proyecto",
    "prefix": "gw",
    "type": "grande",
    "domains": ["Sales", "Inventory"]
  }
}
```

**Propiedades:**
- `name`: Nombre del proyecto
- `prefix`: Prefijo de los scripts (ej: gw)
- `type`: Tipo de proyecto (`pequeno`, `mediano-sin-modules`, `mediano-con-modules`, `grande`)
- `domains`: Dominios del proyecto (Sales, Inventory, Customer, etc.)

---

## Reglas de Arquitectura

### Dependencias válidas

```
✅ Application → Domain
✅ Infrastructure → Domain
✅ Interface → Application o Infrastructure

❌ Domain → Application
❌ Domain → Infrastructure
❌ Application → Infrastructure (usar Ports)
```

### Dónde va cada tipo de archivo

| Tipo de archivo | ✅ Ubicación correcta | ❌ Ubicación incorrecta |
|-----------------|----------------------|------------------------|
| *.entity.ts | Domain/entities/ | Application/, Infrastructure/ |
| *.service.ts | Application/services/ | Domain/ |
| *.repository.ts | Infrastructure/persistence/ | Domain/ |
| *.adapter.ts | Infrastructure/adapters/ | Application/ |
| *.port.ts | Application/ports/ | Domain/ |
| *.usecase.ts | Application/use-cases/ | Domain/ |
| *.validation.ts | validations/ | Domain/ |
| *.transform.ts | Application/transforms/ | Domain/ |

---

## Solución de Problemas

### orkidns no encuentra el archivo

Asegurate de ejecutar desde la raíz del proyecto:

```powershell
cd tu-proyecto
.\orkidns.ps1 check
```

### No detecta el tipo de proyecto

Ejecutá `init` para generar la configuración:

```powershell
.\orkidns.ps1 init
```

### normalize no funciona

Verificá que el archivo sea `.ts` y no tenga errores de sintaxis previos.

---

## Ejemplos Completos

### Ejemplo 1: Crear un nuevo módulo

```powershell
# 1. Inicializar
.\orkidns.ps1 init

# 2. Ver estructura
.\orkidns.ps1 info

# 3. Crear componentes
.\orkidns.ps1 add "crear servicio para gestión de clientes"

# 4. Normalizar el código
.\orkidns.ps1 normalize "src\TypeScripts\Customer"
```

### Ejemplo 2: Revisar arquitectura

```powershell
# 1. Ver componentes
.\orkidns.ps1 list

# 2. Validar arquitectura
.\orkidns.ps1 check

# 3. Si hay problemas, intentar corregir
.\orkidns.ps1 fix
```

### Ejemplo 3: Normalizar proyecto existente

```powershell
# Normalizar todos los archivos TypeScript
.\orkidns.ps1 normalize "src\TypeScripts"

# O solo una carpeta específica
.\orkidns.ps1 normalize "src\TypeScripts\Sales\Application\services"
```

---

## Uso con AI Assistant

Si usás un AI assistant (Claude, OpenCode, etc.), podés invocar OrkidNS con:

```
@orkidns add "crear facturas"
@orkidns check
@orkidns normalize "src/TypeScripts/Sales/invoice.ts"
```

Consultá **[SKILL.md](SKILL.md)** para más información sobre la integración.

---

## Más Información

- **Guía general**: [GUIA-USUARIO.md](GUIA-USUARIO.md)
- **Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Arquitectura**: [ARCHITECTURE.md](ARCHITECTURE.md)
- **Ejemplos**: [EXAMPLES.md](EXAMPLES.md)