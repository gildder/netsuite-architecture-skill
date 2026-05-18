---
name: netsuite-clean-architecture
description: |-
  Guía y creador de proyectos NetSuite con TypeScript usando Clean Architecture.
  Usa cuando: usuario quiere crear proyecto NetSuite, clasificar tamaño (pequeño/mediano/grande),
  preguntar sobre arquitectura, o necesita estructura de código.

  Este skill te ayudará a:
  - Entender qué es Clean Architecture y por qué se usa en NetSuite
  - Clasificar tu proyecto con preguntas simples
  - Crear la estructura correcta según el tamaño
  - Clonar el repositorio template y configurarlo automáticamente

  Examples:
  - user: "quiero crear un proyecto netsuite" → hacer PREGUNTA 1 primero
  - user: "crear proyecto sales" → hacer preguntas de clasificación
  - user: "nuevo proyecto para facturacion" → hacer preguntas + crear estructura
---
compatibility: opencode,claude-code,cursor,codex
metadata:
  version: "1.6"
  author: Gateway Team
  license: MIT
---

# NetSuite Clean Architecture - Skill Guide

## ⚠️ IMPORTANTE: Flujo de Preguntas

**Este skill debe hacer las preguntas UNA A LA VEZ.**
- NO agrupe múltiples preguntas en un solo mensaje
- NO muestre la siguiente pregunta hasta que el usuario responda la actual
- Después de cada pregunta, espere la respuesta del usuario antes de continuar

---

## FASE 1: Preguntas Iniciales del Proyecto

### PREGUNTA 1/8: Ubicación del Proyecto

**Solo muestre esta pregunta. No muestre las demás.**

```
📍 PREGUNTA 1/8: ¿Dónde querés crear el proyecto?

Por favor, proporciona la ruta completa donde se creará la carpeta del proyecto.

Ejemplos de respuesta:
- "C:\Users\gguerrero\Documents\proyectos\mi-proyecto"
- "D:\NetSuite\proyectos\nuevo"
- "./nuevo-proyecto"
```

**ESPERE la respuesta del usuario. Luego continúe a la PREGUNTA 2.**

---

### PREGUNTA 2/8: Nombre del Proyecto

**Solo después de que el usuario responda la pregunta 1.**

```
📍 PREGUNTA 2/8: ¿Cuál es el nombre del proyecto?

Este nombre se usará para:
- Nombre de la carpeta del proyecto
- Nombre en package.json
- Parte del nombre de los archivos compilados

Ejemplos de respuesta:
- "facturacion"
- "tienda-online"
- "marketplace"
- "ventas-sucursales"
```

**ESPERE la respuesta del usuario. Luego continúe a la PREGUNTA 3.**

---

### PREGUNTA 3/8: Prefijo del Proyecto

**Solo después de que el usuario responda la pregunta 2.**

```
📍 PREGUNTA 3/8: ¿Cuál es el prefijo del proyecto?

El prefijo se usará para identificar tus scripts en NetSuite.
Aparecerá al inicio de todos los archivos de scripts.

Formato: [prefijo]_[tipo]_[nombre].ts

Ejemplos de respuesta:
- "gw" → gw_sl_facturas.ts, gw_rs_pedidos.ts
- "acme" → acme_sl_facturas.ts, acme_rs_pedidos.ts
- "tienda" → tienda_sl_carrito.ts

⚠️ IMPORTANTE: El prefijo debe ser:
- En minúsculas
- Sin guiones
- Sin espacios
- Solo letras y números
```

**ESPERE la respuesta del usuario. Luego continúe a la PREGUNTA 4.**

---

## FASE 2: Preguntas de Clasificación

### PREGUNTA 4/8: Cantidad de Scripts

**Solo después de que el usuario responda la pregunta 3.**

```
📋 PREGUNTA 4/8: ¿Cuántos scripts NetSuite tendrá tu proyecto?

[A] POCOS (1-5 scripts)
    → Ejemplo: un Restlet simple o Suitelet básico

[B] MEDIO (6-15 scripts)
    → Ejemplo: CRUD completo con validaciones

[C] MUCHOS (>15 scripts)
    → Ejemplo: múltiples integraciones, colas, procesos
```

**ESPERE la respuesta del usuario (A, B o C). Luego continúe a la PREGUNTA 5.**

---

### PREGUNTA 5/8: Dominios

**Solo después de que el usuario responda la pregunta 4.**

```
📋 PREGUNTA 5/8: ¿Cuántos dominios necesitas?

(Dominios = módulos de negocio diferentes)

[A] SOLO 1 DOMINIO
    → Ejemplo: solo Sales, o solo Customer

[B] 2 DOMINIOS
    → Ejemplo: Sales + Customer, Sales + Inventory

[C] 3+ DOMINIOS
    → Ejemplo: Sales + Inventory + Customer + Accounting
```

**ESPERE la respuesta del usuario (A, B o C). Luego continúe a la PREGUNTA 6.**

---

### PREGUNTA 6/8: Operaciones

**Solo después de que el usuario responda la pregunta 5.**

```
📋 PREGUNTA 6/8: ¿Qué operaciones necesitas?

[A] SOLO CREAR o LEER
    → Una operación simple (solo lectura o crear un registro)

[B] CRUD COMPLETO
    → Crear, Leer, Actualizar, Borrar

[C] CRUD + PROCESOS ASÍNCRONOS + INTEGRACIONES
    → Transacciones complejas, colas, APIs externas, procesos batch
```

**ESPERE la respuesta del usuario (A, B o C). Luego continúe a la PREGUNTA 7.**

---

### PREGUNTA 7/8: Integraciones

**Solo después de que el usuario responda la pregunta 6.**

```
📋 PREGUNTA 7/8: ¿Tienes integraciones externas?

[A] NINGUNA o MÁXIMO 1
    → Solo operaciones internas de NetSuite

[B] 2-3 INTEGRACIONES
    → Gateway, VTEX, APIs de pagos, servicios externos

[C] MÁS DE 3
    → Múltiples sistemas externos (ERP, CRM, logística, etc.)
```

**ESPERE la respuesta del usuario (A, B o C). Luego continúe al RESULTADO.**

---

### PREGUNTA 8/8: Líneas de Código

**Solo después de que el usuario responda la pregunta 7.**

```
📋 PREGUNTA 8/8: ¿Cuántas líneas de código estimás?

[A] POCAS (hasta 1500 líneas)
    → Proyecto pequeño, código simple

[B] MEDIAS (1501-4000 líneas)
    → Proyecto mediano, funcionalidad moderada

[C] MUCHAS (más de 4000 líneas)
    → Proyecto grande, sistema completo
```

**ESPERE la respuesta del usuario (A, B o C). Luego continúe al RESULTADO.**

---

## FASE 3: Resultado de Clasificación

**Solo después de que el usuario responda la pregunta 8.**

Analice las respuestas y muestre el resultado:

```
🎯 RESULTADO DE CLASIFICACIÓN

Basado en tus respuestas:
- Scripts: [A/B/C]
- Dominios: [A/B/C]
- Operaciones: [A/B/C]
- Integraciones: [A/B/C]
- Líneas de código: [A/B/C]

Tu proyecto es: [PEQUEÑO/MEDIANO/GRANDE]

---

Datos del proyecto:
- Ubicación: [ruta proporcionada en pregunta 1]
- Nombre: [nombre proporcionado en pregunta 2]
- Prefijo: [prefijo proporcionado en pregunta 3]

---

Ahora voy a:
1. Clonar el repositorio template directamente en [ruta] (archivos en la raíz, sin subcarpeta)
2. Configurar package.json, tsconfig.json
3. Configurar deploy.xml (actualizar path de FileCabinet)
4. Configurar manifest.xml (actualizar nombre del proyecto)
5. Crear la estructura TypeScripts según tu clasificación
6. Crear scripts NetSuite con prefijo [prefijo]_
```

---

## FASE 4: Pregunta Adicional (solo para MEDIANO)

**Solo si el resultado fue MEDIANO.**

```
📋 PREGUNTA EXTRA: Tu proyecto es MEDIANO.

¿Querés usar carpeta Modules?

[A] SÍ - Mi proyecto tendrá 3+ dominios o prevé crecer
[B] NO - Solo tendré 1-2 dominios y no pienso agregar más
```

**ESPERE la respuesta del usuario (A o B).**
**Luego proceda a crear el proyecto.**

---

## Estructuras por Tipo de Proyecto

### 🏠 PROYECTO PEQUEÑO

```
src/TypeScripts/[nombre]/
├── [Dominio]/
│   ├── [dominio].service.ts
│   ├── [dominio].repository.ts
│   └── [dominio].types.ts
├── Interface/
│   └── [prefijo]_sl_[nombre].ts
└── Shared/
    └── utils/
```

---

### 🏢 PROYECTO MEDIANO (sin Modules)

```
src/TypeScripts/[nombre]/
├── [Dominio]/
│   ├── Domain/entities/
│   ├── Application/services/, transforms/
│   ├── Infrastructure/repositories/
│   └── validations/
├── Interface/
│   ├── [prefijo]_rs_[nombre].ts
│   ├── [prefijo]_sl_[nombre].ts
│   └── [prefijo]_ue_[nombre].ts
└── Shared/
```

---

### 🏢 PROYECTO MEDIANO (con Modules)

```
src/TypeScripts/[nombre]/
├── Modules/
│   └── [Dominio]/
│       ├── Domain/entities/
│       ├── Application/services/, transforms/
│       ├── Infrastructure/repositories/
│       └── validations/
├── Interface/
│   ├── [prefijo]_rs_[nombre].ts
│   ├── [prefijo]_sl_[nombre].ts
│   └── [prefijo]_ue_[nombre].ts
└── Shared/
```

---

### 🏰 PROYECTO GRANDE

```
src/TypeScripts/[nombre]/
├── Modules/
│   └── [Dominio]/
│       ├── Domain/ (entities, value-objects, events, services)
│       ├── Application/ (use-cases, ports, dtos, services, transforms)
│       ├── Infrastructure/ (persistence, adapters)
│       └── validations/
├── Interface/
│   ├── [prefijo]_cs_[nombre].ts   ← Client Script
│   ├── [prefijo]_ue_[nombre].ts   ← User Event
│   ├── [prefijo]_sl_[nombre].ts   ← Suitelet
│   ├── [prefijo]_rl_[nombre].ts   ← RESTlet
│   ├── [prefijo]_pl_[nombre].ts   ← Portlet
│   ├── [prefijo]_sc_[nombre].ts   ← Scheduled
│   ├── [prefijo]_mr_[nombre].ts   ← Map/Reduce
│   ├── [prefijo]_gl_[nombre].ts   ← SuiteGL
│   ├── [prefijo]_wa_[nombre].ts   ← Workflow Action
│   ├── [prefijo]_mu_[nombre].ts   ← Mass Update
│   └── [prefijo]_bi_[nombre].ts   ← Bundle Installation
└── Shared/
    ├── domain/ (result.ts, guard.ts)
    ├── utils/
    └── constants/
```

---

## Nomenclatura de Scripts NetSuite

Formato: `[prefijo]_[tipo]_[nombre].ts`

| Tipo | Código | Ejemplo |
|------|--------|---------|
| Client Script | cs | gw_cs_validacion.ts |
| User Event | ue | gw_ue_factura.ts |
| Suitelet | sl | gw_sl_facturas.ts |
| RESTlet | rl | gw_rl_pedidos.ts |
| Portlet | pl | gw_pl_dashboard.ts |
| Scheduled | sc | gw_sc_sincronizacion.ts |
| Map/Reduce | mr | gw_mr_importacion.ts |
| SuiteGL | gl | gl_asiento_automatico.ts |
| Workflow Action | wa | wa_aprobacion_pedido.ts |
| Mass Update | mu | mu_actualizacion_masiva.ts |
| Bundle Installation | bi | bi_instalacion_bundle.ts |

---

## Configuración SDF

Al crear un proyecto, se configuran automáticamente los archivos de SDF:

### deploy.xml

```xml
<deploy>
    <configuration>
        <path>~/AccountConfiguration/*</path>
    </configuration>
    <files>
        <path>~/FileCabinet/SuiteScripts/[nombre-proyecto]/*</path>
    </files>
    <objects>
        <path>~/Objects/*</path>
    </objects>
    <translationimports>
        <path>~/Translations/*</path>
    </translationimports>
</deploy>
```

### manifest.xml

```xml
<manifest projecttype="ACCOUNTCUSTOMIZATION">
  <projectname>[NOMBRE_UPPER_CASE]_Project</projectname>
  <frameworkversion>1.0</frameworkversion>
  <dependencies>
    <features>
      <feature required="true">SERVERSIDESCRIPTING</feature>
    </features>
  </dependencies>
</manifest>
```

### Archivos que se actualizan:

| Archivo | Campo actualizado |
|---------|-----------------|
| deploy.xml | `FileCabinet/SuiteScripts/[nombre-proyecto]` |
| manifest.xml | `projectname` → `[NOMBRE_UPPER]_Project` |

---

## Referencias

- Template: https://github.com/gildder/netsuite-ts-sdf-template
- Clean Architecture: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- Hexagonal: https://alistair.cockburn.us/hexagonal-architecture

---

## OrkidNS - Agente de Arquitectura

Para crear y validar componentes siguiendo la arquitectura, usá el agente **OrkidNS**.

### Comandos disponibles

| Comando | Descripción |
|---------|-------------|
| `orkidns add "idea"` | Crear componentes desde una idea |
| `orkidns check` | Validar arquitectura del proyecto |
| `orkidns info [carpeta]` | Explicar qué va y qué NO va en esa carpeta |
| `orkidns list` | Listar componentes del proyecto |
| `orkidns init` | Inicializar OrkidNS en un proyecto |
| `orkidns fix` | Corregir problemas de arquitectura |
| `orkidns hint` | Dar sugerencias basadas en código existente |

### Ejemplo de uso

```
USER: orkidns add "quiero hacer un servicio para crear facturas"

ORKIDNS:
📋 Basándome en tu idea "crear facturas":

Componentes sugeridos:
✅ Entity: Domain/entities/invoice.entity.ts
✅ Service: Application/services/invoice.service.ts
✅ Repository: Infrastructure/persistence/invoice.repository.ts

¿Querés que los cree? (sí/no)
```

### Palabras clave para inferencia

| Keyword | → | Componentes |
|---------|---|-------------|
| "crear" / "nuevo" | | Entity + Service + Repository |
| "integrar" | | Adapter + Port |
| "sincronizar" | | UseCase + Scheduled |
| "validar" | | Validation |
| "transformar" | | Transform |
| "evento" | | DomainEvent |
| "CRUD" | | Entity + Service + Repository + Validation + Transform |
| "api" | | Port + Adapter |
| "programado" | | Scheduled |

### Para usar OrkidNS

1. Configurá el agente en `opencode.json`
2. Inicializá con `orkidns init` en tu proyecto
3. Usá los comandos para crear y validar

Ver `orkidns/AGENT.md` para documentación completa del agente.