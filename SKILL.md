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

  Examples:
  - user: "quiero crear un proyecto netsuite" → hacer PREGUNTA 1 primero
  - user: "qué arquitectura usar?" → explicar con ejemplos
  - user: "es proyecto pequeño o grande?" → hacer PREGUNTA 1 primero
  - user: "cómo structurar mi código?" → mostrar estructuras por tipo
  - user: "ayúdame con clean architecture" → explicar arquitectura + mostrar ejemplos
---
compatibility: opencode,claude-code,cursor,codex
metadata:
  version: "1.1"
  author: Gateway Team
  license: MIT
---

# NetSuite Clean Architecture - Skill Guide

## Flujo de Clasificación

Cuando el usuario dice "quiero crear un proyecto NetSuite" o pide ayuda para clasificar un proyecto, SIGUE ESTE FLUJO EXACTAMENTE:

### Paso 1: PRIMERA PREGUNTA

**Solo muestra esta pregunta al usuario. No muestres las demás.**

```
📋 PREGUNTA 1/5: ¿Cuántos scripts NetSuite tendrá tu proyecto?

[A] POCOS (1-5 scripts)
    → Ejemplo: un Restlet simple o Suitelet básico

[B] MEDIO (6-15 scripts)
    → Ejemplo: CRUD completo con validaciones

[C] MUCHOS (>15 scripts)
    → Ejemplo: múltiples integraciones, colas, procesos
```

**Espera la respuesta del usuario antes de continuar.**

---

### Paso 2: SEGUNDA PREGUNTA

(Solo después de que el usuario responda la pregunta 1)

```
📋 PREGUNTA 2/5: ¿Cuántos dominios necesitas?
(Dominios = módulos de negocio: Sales, Inventory, Customer, etc.)

[A] SOLO 1 DOMINIO
    → Ejemplo: solo Sales, o solo Customer

[B] 2 DOMINIOS
    → Ejemplo: Sales + Customer

[C] 3+ DOMINIOS
    → Ejemplo: Sales + Inventory + Core
```

**Espera la respuesta del usuario antes de continuar.**

---

### Paso 3: TERCERA PREGUNTA

(Solo después de que el usuario responda la pregunta 2)

```
📋 PREGUNTA 3/5: ¿Qué operaciones necesitas?

[A] SOLO CREAR o LEER
    → Una operación simple

[B] CRUD COMPLETO
    → Crear, Leer, Actualizar, Borrar

[C] CRUD + PROCESOS ASÍNCRONOS + INTEGRACIONES
    → Transacciones complejas, colas, APIs externas
```

**Espera la respuesta del usuario antes de continuar.**

---

### Paso 4: CUARTA PREGUNTA

(Solo después de que el usuario responda la pregunta 3)

```
📋 PREGUNTA 4/5: ¿Tienes integraciones externas?

[A] NINGUNA o MÁXIMO 1
    → Solo operaciones internas de NetSuite

[B] 2-3 INTEGRACIONES
    → Gateway, VTEX, APIs de pagos, etc.

[C] MÁS DE 3
    → Múltiples sistemas externos
```

**Espera la respuesta del usuario antes de continuar.**

---

### Paso 5: QUINTA PREGUNTA

(Solo después de que el usuario responda la pregunta 4)

```
📋 PREGUNTA 5/5: ¿Cuántas líneas de código estimás?

[A] POCAS (hasta 1500 líneas)
    → Proyecto pequeño, código simple

[B] MEDIAS (1501-4000 líneas)
    → Proyecto mediano, funcionalidad moderada

[C] MUCHAS (más de 4000 líneas)
    → Proyecto grande, sistema completo
```

**Espera la respuesta del usuario antes de continuar.**

---

### Análisis Final

Después de las 5 preguntas, cuenta las respuestas:

| Clasificación | Criterios |
|---------------|-----------|
| **PEQUEÑO** | Mayoría de respuestas A |
| **MEDIANO** | Mayoría de respuestas B |
| **GRANDE** | Mayoría de respuestas C |

**Muestra el resultado al usuario:**

```
🎯 RESULTADO: Tu proyecto es [PEQUEÑO/MEDIANO/GRANDE]

→ Estructura recomendada: [descripción breve]
```

---

### Pregunta Adicional (solo para MEDIANO)

Si el resultado es MEDIANO, pregunta:

```
📋 Tu proyecto es MEDIANO.
¿Querés usar carpeta Modules?

[A] SÍ - Mi proyecto tendrá 3+ dominios
[B] NO - Solo tendré 1-2 dominios
```

---

## Estructuras por Tipo de Proyecto

### PROYECTO PEQUEÑO

Estructura directa, sin carpeta Modules:

```
src/TypeScripts/[NombreProyecto]/
├── [Dominio]/
│   ├── [dominio].service.ts
│   ├── [dominio].repository.ts
│   └── [dominio].types.ts
├── Interface/
│   └── gw_[tipo]_[nombre].ts
└── Shared/
    └── utils/
```

---

### PROYECTO MEDIANO

```
src/TypeScripts/[NombreProyecto]/
├── [Dominio]/
│   ├── Domain/entities/
│   ├── Application/services/
│   ├── Infrastructure/repositories/
│   └── validations/
├── Interface/
└── Shared/
```

O con Modules si respondió [A] en la pregunta adicional:

```
src/TypeScripts/[NombreProyecto]/
├── Modules/
│   └── [Dominio]/
│       ├── Domain/
│       ├── Application/
│       ├── Infrastructure/
│       └── validations/
├── Interface/
└── Shared/
```

---

### PROYECTO GRANDE

```
src/TypeScripts/[NombreProyecto]/
├── Modules/
│   └── [Dominio]/
│       ├── Domain/ (entities, value-objects, events, services)
│       ├── Application/ (use-cases, ports/inbound, ports/outbound, dtos)
│       ├── Infrastructure/ (persistence, adapters)
│       └── validations/
├── Interface/
└── Shared/
```

---

## Cuándo Explicar Arquitectura

Si el usuario pregunta:
- "qué es clean architecture?"
- "por qué usar esa arquitectura?"
- "qué es arquitectura hexagonal?"

**Entonces explica** (sin hacer preguntas de clasificación):

```
🏗️ Clean Architecture (Uncle Bob)

Capas:
├── Domain (Entidades, reglas de negocio)
├── Application (Casos de uso, servicios)
├── Infrastructure (Repositorios, adaptadores)
└── Interface (Scripts NetSuite)

Beneficio: El código de negocio no depende de NetSuite.
Podés probar la lógica sin necesidad de NetSuite.

Hexagonal Architecture (Alistair Cockburn):

Puertos y Adaptadores:
├── Ports (interfaces hacia afuera/adentro)
└── Adapters (implementaciones: NetSuite, VTEX, Gateway)

Beneficio: Podés cambiar VTEX por otro proveedor
sin tocar tu lógica de negocio.
```

---

## Referencias

- Clean Architecture: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- Hexagonal Architecture: https://alistair.cockburn.us/hexagonal-architecture
- Wikipedia: https://en.wikipedia.org/wiki/Hexagonal_architecture_(software)

Ver `ARCHITECTURE.md` para más detalles.