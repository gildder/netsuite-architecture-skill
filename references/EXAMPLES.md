# Ejemplos de Uso - NetSuite Clean Architecture Skill

## 🎯 SKILL: Clasificación y Creación de Proyectos

### Iniciar un nuevo proyecto

```
USER: "quiero crear un proyecto NetSuite"

SKILL: 📍 PREGUNTA 1/8: ¿Dónde querés crear el proyecto?

USER: "C:\Users\gguerrero\Documents\proyectos\nuevo-proyecto"

SKILL: 📍 PREGUNTA 2/8: ¿Cuál es el nombre del proyecto?

USER: "facturas"

SKILL: 📍 PREGUNTA 3/8: ¿Cuál es el prefijo del proyecto?

USER: "gw"

(Sigue con las preguntas de clasificación...)

RESULTADO: Tu proyecto es SMALL
```

### Crear proyecto directamente (sin preguntas)

```
USER: "crea un proyecto llamado ventas en D:\proyectos\ventas con prefijo acme"

SKILL: ✅ Creando proyecto:
- Ubicación: D:\proyectos\ventas
- Nombre: ventas
- Prefijo: acme
- Tipo: SMALL (basado en parámetros)
```

---

## 🤖 AGENTE: OrkidNS

### orkidns init - Inicializar proyecto

```
USER: orkidns init

ORKIDNS:
📦 Inicializando OrkidNS en: .
✅ orkidns.config.json creado

Contenido:
{
  "version": "1.0",
  "project": {
    "name": "mi-proyecto",
    "prefix": "gw",
    "type": "medium-with-modules",
    "domains": []
  }
}
```

---

### orkidns add - Crear componentes desde idea

```
USER: orkidns add "quiero hacer un servicio para crear facturas"

ORKIDNS:
📋 Basándome en tu idea "hacer un servicio para crear facturas":

Componentes sugeridos:
✅ Entity: Modules/Sales/Domain/entities/invoice.entity.ts
✅ Service: Modules/Sales/Application/services/invoice.service.ts
✅ Repository: Modules/Sales/Infrastructure/persistence/invoice.repository.ts
✅ Validation: Modules/Sales/validations/invoice.validation.ts

¿Querés que los cree? (sí/no)
```

```
USER: sí

ORKIDNS:
✅ Creando invoice.entity.ts
✅ Creando invoice.service.ts
✅ Creando invoice.repository.ts
✅ Creando invoice.validation.ts

✅ 4 componentes creados en Modules/Sales/
```

---

### orkidns normalize - Normalizar TypeScript

#### Por archivo específico:

```
USER: orkidns normalize "src/TypeScripts/Sales/invoice.ts"

ORKIDNS:
📝 Normalizando: src/TypeScripts/Sales/invoice.ts
  ✅ Tipo: Suitelet
  ✅ + JSDoc (@NApiVersion 2.1, @NModuleScope Public, @NScriptType Suitelet)
  ✅ + EntryPoints import
  ✅ Archivo normalizado (2 cambios)
```

#### Por carpeta:

```
USER: orkidns normalize "src/TypeScripts/Sales/"

ORKIDNS:
📁 Normalizando carpeta: src/TypeScripts/Sales/
   Archivos TypeScript: 8

[1/8] invoice.service.ts
  ✅ Ya está normalizado

[2/8] invoice.entity.ts
  📝 Normalizando: Sales/invoice.entity.ts
    ✅ Tipo: Suitelet
    ✅ + JSDoc
    ✅ Normalizado (1 cambio)
...

✅ Resumen:
   Procesados: 8
   Modificados: 3
```

---

### orkidns check - Verificar arquitectura

```
USER: orkidns check

ORKIDNS:
🔍 Verificando arquitectura en: .
   📊 Archivos TypeScript: 24

✅ Arquitectura válida

(Si hay problemas:)
❌ Problemas encontrados:
   - Service en Domain: Modules/Sales/Domain/invoice.service.ts
   - Adapter en Application: Modules/Sales/Application/adapters/vtex.adapter.ts
```

---

### orkidns list - Listar componentes

```
USER: orkidns list

ORKIDNS:
📋 Componentes en: .

🏠 Sales (12 archivos)
   - invoice.entity.ts
   - invoice.service.ts
   - invoice.repository.ts
   - invoice.validation.ts
   - customer.entity.ts
   ...

🏠 Inventory (8 archivos)
   - item.entity.ts
   - item.service.ts
   ...
```

---

### orkidns info - Guía de estructura

```
USER: orkidns info

ORKIDNS:
📁 Guía de estructura de carpetas

🏠 SMALL (directo):
   [Dominio]/
     - *.service.ts
     - *.repository.ts
     - *.types.ts

🏢 MEDIUM/LARGE (capas):
   Domain/entities/         → *.entity.ts
   Application/services/   → *.service.ts
   Application/transforms/ → *.transform.ts
   Application/ports/      → *.port.ts
   Application/use-cases/ → *.usecase.ts
   Application/dtos/       → *.dto.ts
   Infrastructure/persistence/ → *.repository.ts
   Infrastructure/adapters/   → *.adapter.ts
   validations/            → *.validation.ts
```

---

### orkidns fix - Corregir problemas

```
USER: orkidns fix

ORKIDNS:
🔧 Buscando problemas de arquitectura...

❌ Encontrado: vtex.adapter.ts en Application/services/
   → Moviendo a Infrastructure/adapters/

✅ Corregido: Modules/Sales/Application/services/vtex.adapter.ts
   → Modules/Sales/Infrastructure/adapters/vtex.adapter.ts

❌ Encontrado: invoice.service.ts en Domain/
   → Moviendo a Application/services/

✅ Corregido: Modules/Sales/Domain/invoice.service.ts
   → Modules/Sales/Application/services/invoice.service.ts
```

---

### orkidns hint - Sugerencias

```
USER: orkidns hint

ORKIDNS:
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

## 📋 Resumen de Comandos

| Comando | Uso | Ejemplo |
|---------|-----|---------|
| **Skill** | Crear proyectos desde cero | "quiero crear un proyecto NetSuite" |
| orkidns init | Inicializar config | orkidns init |
| orkidns add | Crear desde idea | orkidns add "crear facturas" |
| orkidns normalize | Corregir TypeScript | orkidns normalize "archivo.ts" |
| orkidns check | Verificar arquitectura | orkidns check |
| orkidns list | Listar componentes | orkidns list |
| orkidns info | Guía de estructura | orkidns info |
| orkidns fix | Corregir problemas | orkidns fix |
| orkidns hint | Sugerencias | orkidns hint |

---

## 🔧 Scripts de Build

### build completo (después de crear proyecto)

```bash
# Compilar TypeScript → JavaScript
yarn build
# Output: tsc && node scripts/prepend-headers.js && biome format

# Deploy a NetSuite
yarn deploy
```

### other scripts útiles

```bash
# Formatear código
yarn format

# Lint código
yarn lint

# Lint y formatear
yarn lint:fix
```