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
  - user: "nuevo proyecto para fakturacion" → hacer preguntas + crear estructura
---
compatibility: opencode,claude-code,cursor,codex
metadata:
  version: "1.4"
  author: Gateway Team
  license: MIT
---

# NetSuite Clean Architecture - Skill Guide

## Flujo Completo de Creación de Proyecto

Cuando el usuario quiere crear un proyecto NetSuite nuevo, SIGUE ESTE FLUGO:

---

### Paso 1: Preguntar DATOS DEL PROYECTO

```
📍 PREGUNTAS INICIALES: Datos del proyecto

1. ¿Dónde querés crear el proyecto?
   Ejemplo: "C:\Users\gguerrero\Documents\proyectos\mi-proyecto"

2. ¿Cuál es el nombre del proyecto? (nombre de carpeta)
   Ejemplo: "facturacion", "tienda-online", "marketplace"

3. ¿Cuál es el prefijo del proyecto? (para scripts NetSuite)
   Ejemplo: "gw" → gw_sl_facturas.ts, gw_rs_pedidos.ts
   Este prefijo aparece al inicio de todos los scripts NetSuite.
   Debe ser en minúsculas, sin guiones.

4. ¿Cuál es el dominio principal? (Sales, Inventory, Customer, etc.)
   Ejemplo: "Sales", "Inventory", "Customer"
```

**Espera todas las respuestas del usuario.**

---

### Paso 2-6: Las 5 PREGUNTAS de clasificación

Hacerlas UNA A LA VEZ.

---

### Paso 7: RESULTADO + ACCIÓN

Después de las 5 preguntas:

```
🎯 RESULTADO: Tu proyecto es [PEQUEÑO/MEDIANO/GRANDE]

Datos del proyecto:
- Ruta: [ruta]
- Nombre: [nombre]
- Prefijo: [prefijo]
- Dominio: [dominio]

Ahora voy a:
1. Clonar el repositorio template
2. Configurar package.json, tsconfig.json
3. Crear la estructura TypeScripts según tu clasificación
4. Crear scripts NetSuite con prefijo [prefijo]_
```

---

## Estructuras Detalladas por Tipo de Proyecto

---

## 🏠 PROYECTO PEQUEÑO

**Cuándo usarlo:** 1 dominio, ≤5 scripts, ≤1500 líneas, operaciones simples

### Estructura de carpetas:

```
src/TypeScripts/[nombre-proyecto]/
├── [Dominio]/                              ← Dominio directo (ej: Sales)
│   ├── [dominio].service.ts               ← Lógica de negocio principal
│   ├── [dominio].repository.ts            ← Acceso a datos (NetSuite)
│   └── [dominio].types.ts                 ← Definición de tipos
├── Interface/
│   ├── gw_[tipo]_[nombre].ts              ← Script NetSuite
│   └── Suitelets/
│       └── [prefijo]_sl_[nombre].ts       ← Ej: gw_sl_facturas.ts
│   └── Restlets/
│       └── [prefijo]_rs_[nombre].ts       ← Ej: gw_rs_pedidos.ts
└── Shared/
    └── utils/
        └── logger.ts
```

### Ejemplo (proyecto "facturas", prefijo "gw", dominio "Sales"):

```
src/TypeScripts/facturas/
├── Sales/
│   ├── sales.service.ts
│   ├── sales.repository.ts
│   └── sales.types.ts
├── Interface/
│   ├── gw_sl_facturas.ts
│   └── Restlets/
│       └── gw_rs_facturas.ts
└── Shared/
    └── utils/
        └── logger.ts
```

**Scripts NetSuite creados:**
- `gw_sl_facturas.ts` → Suitelet
- `gw_rs_facturas.ts` → Restlet

---

## 🏢 PROYECTO MEDIANO (SIN carpeta Modules)

**Cuándo usarlo:** 1-2 dominios, 6-15 scripts, CRUD completo

### Estructura:

```
src/TypeScripts/[nombre-proyecto]/
├── [Dominio]/
│   ├── Domain/
│   │   └── entities/
│   │       └── [dominio].entity.ts
│   ├── Application/
│   │   ├── services/
│   │   │   └── [dominio].service.ts
│   │   └── transforms/
│   │       └── [dominio].transform.ts
│   ├── Infrastructure/
│   │   └── repositories/
│   │       └── [dominio].repository.ts
│   └── validations/
│       └── [dominio].validation.ts
├── Interface/
│   ├── Restlets/
│   │   └── [prefijo]_rs_[nombre].ts
│   ├── Suitelets/
│   │   └── [prefijo]_sl_[nombre].ts
│   └── UserEvents/
│       └── [prefijo]_ue_[nombre].ts
└── Shared/
    ├── utils/
    │   └── logger.ts
    └── constants/
        └── [dominio].constants.ts
```

### Ejemplo (proyecto "tienda-online", prefijo "gw", dominio "Sales"):

```
src/TypeScripts/tienda-online/
├── Sales/
│   ├── Domain/
│   │   └── entities/
│   │       └── sales.entity.ts
│   ├── Application/
│   │   ├── services/
│   │   │   └── sales.service.ts
│   │   └── transforms/
│   │       └── sales.transform.ts
│   ├── Infrastructure/
│   │   └── repositories/
│   │       └── sales.repository.ts
│   └── validations/
│       └── sales.validation.ts
├── Interface/
│   ├── Restlets/
│   │   └── gw_rs_pedidos.ts
│   ├── Suitelets/
│   │   └── gw_sl_carrito.ts
│   └── UserEvents/
│       └── gw_ue_factura.ts
└── Shared/
    ├── utils/
    │   └── logger.ts
    └── constants/
        └── sales.constants.ts
```

---

## 🏢 PROYECTO MEDIANO (CON carpeta Modules)

**Cuándo usarlo:** 2+ dominios que crescerán

### Estructura:

```
src/TypeScripts/[nombre-proyecto]/
├── Modules/
│   └── [Dominio]/
│       ├── Domain/
│       ├── Application/
│       ├── Infrastructure/
│       └── validations/
├── Interface/
│   ├── Restlets/
│   ├── Suitelets/
│   └── UserEvents/
└── Shared/
    ├── utils/
    └── constants/
```

---

## 🏰 PROYECTO GRANDE (Arquitectura Hexagonal completa)

**Cuándo usarlo:** 3+ dominios, >15 scripts, múltiples integraciones

### Estructura:

```
src/TypeScripts/[nombre-proyecto]/
├── Modules/
│   └── [Dominio]/
│       ├── Domain/
│       │   ├── entities/
│       │   ├── value-objects/
│       │   ├── events/
│       │   └── services/
│       ├── Application/
│       │   ├── use-cases/
│       │   ├── ports/
│       │   │   ├── inbound/
│       │   │   └── outbound/
│       │   ├── dtos/
│       │   ├── services/
│       │   └── transforms/
│       ├── Infrastructure/
│       │   ├── persistence/
│       │   └── adapters/
│       └── validations/
├── Interface/
│   ├── Restlets/      → [prefijo]_rs_[nombre].ts
│   ├── Suitelets/     → [prefijo]_sl_[nombre].ts
│   ├── UserEvents/    → [prefijo]_ue_[nombre].ts
│   ├── Scheduled/     → [prefijo]_ss_[nombre].ts
│   └── MapReduce/     → [prefijo]_mr_[nombre].ts
└── Shared/
    ├── domain/
    │   ├── result.ts
    │   └── guard.ts
    ├── utils/
    └── constants/
```

### Ejemplo (proyecto "marketplace", prefijo "gw", dominio "Sales"):

```
src/TypeScripts/marketplace/
├── Modules/
│   └── Sales/
│       ├── Domain/ (entities, value-objects, events, services)
│       ├── Application/ (use-cases, ports, dtos, services, transforms)
│       ├── Infrastructure/ (persistence, adapters)
│       └── validations/
├── Interface/
│   ├── Restlets/
│   │   └── gw_rs_orders.ts
│   ├── Suitelets/
│   │   └── gw_sl_checkout.ts
│   ├── UserEvents/
│   │   └── gw_ue_invoice.ts
│   ├── Scheduled/
│   │   └── gw_ss_sync.ts
│   └── MapReduce/
│       └── gw_mr_import.ts
└── Shared/
    ├── domain/
    ├── utils/
    └── constants/
```

---

## Nomenclatura de Scripts NetSuite

**Formato:** `[prefijo]_[tipo]_[nombre].ts`

| Tipo | Código | Ejemplo completo |
|------|--------|------------------|
| Suitelet | sl | gw_sl_facturas |
| Restlet | rs | gw_rs_pedidos |
| User Event | ue | gw_ue_factura |
| Scheduled | ss | gw_ss_sincronizacion |
| Map/Reduce | mr | gw_mr_importacion |
| Client Script | cs | gw_cs_validacion |
| Portlet | pt | gw_pt_dashboard |

---

## Configuraciones Automáticas

### package.json:

| Campo | Valor |
|-------|-------|
| name | [nombre-proyecto] |
| displayName | NetSuite [Dominio] Project |
| description | NetSuite TypeScript project for [Dominio] - [Tipo] |

### tsconfig.json:

| Campo | Valor |
|-------|-------|
| rootDir | src/TypeScripts/[nombre] |
| outDir | src/FileCabinet/SuiteScripts/[nombre] |
| include | src/TypeScripts/[nombre]/**/* |

---

## Referencias

- Template: https://github.com/gildder/netsuite-ts-sdf-template
- Clean Architecture: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- Hexagonal: https://alistair.cockburn.us/hexagonal-architecture