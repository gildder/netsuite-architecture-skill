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
  - user: "quiero crear un proyecto netsuite" → hacer preguntas de clasificación
  - user: "qué arquitectura usar?" → explicar con ejemplos
  - user: "es proyecto pequeño o grande?" → hacer 5 preguntas y clasificar
  - user: "cómo structurar mi código?" → mostrar estructuras por tipo
  - user: "ayúdame con clean architecture" → explicar arquitectura + mostrar ejemplos
---
compatibility: opencode,claude-code,cursor,codex
metadata:
  version: "1.0"
  author: Gateway Team
  license: MIT
---

# NetSuite Clean Architecture - Skill Guide

## What I Do

Soy una guía completa para crear proyectos NetSuite con TypeScript usando arquitectura limpia. Mi objetivo es ayudarte a:

1. **Entender** las arquitecturas Clean y Hexagonal
2. **Clasificar** tu proyecto con preguntas simples
3. **Crear** la estructura correcta según el tamaño

---

## When To Use Me

Usa este skill cuando:

- Quieres crear un nuevo proyecto NetSuite con TypeScript
- Necesitas clasificar un proyecto existente (pequeño/mediano/grande)
- Tienes dudas sobre qué estructura usar
- Quieres entender Clean Architecture aplicada a NetSuite

---

## Phase 1: Clasificación del Proyecto

Antes de crear cualquier estructura, necesito clasificar tu proyecto.

### Las 5 Preguntas de Clasificación

```
┌─────────────────────────────────────────────────────────────┐
│  PREGUNTA 1: ¿Cuántos scripts NetSuite tendrá?             │
├─────────────────────────────────────────────────────────────┤
│  [A] POCOS (1-5 scripts)                                  │
│      Ejemplo: un Restlet simple o Suitelet básico          │
│                                                             │
│  [B] MEDIO (6-15 scripts)                                 │
│      Ejemplo: CRUD completo con validaciones             │
│                                                             │
│  [C] MUCHOS (>15 scripts)                                 │
│      Ejemplo: múltiples integraciones, colas, procesos    │
└─────────────────────────────────────────────────────────────┘
```

```
┌─────────────────────────────────────────────────────────────┐
│  PREGUNTA 2: ¿Cuántos dominios necesitas?                  │
│  (Dominios = módulos de negocio: Sales, Inventory, etc.)   │
├─────────────────────────────────────────────────────────────┤
│  [A] SOLO 1 DOMINIO                                       │
│      Ejemplo: solo Sales, o solo Customer                 │
│                                                             │
│  [B] 2 DOMINIOS                                          │
│      Ejemplo: Sales + Customer                             │
│                                                             │
│  [C] 3+ DOMINIOS                                         │
│      Ejemplo: Sales + Inventory + Core                    │
└─────────────────────────────────────────────────────────────┘
```

```
┌─────────────────────────────────────────────────────────────┐
│  PREGUNTA 3: ¿Qué operaciones necesitas?                 │
├─────────────────────────────────────────────────────────────┤
│  [A] SOLO CREAR o LEER                                    │
│      Una operación simple                                │
│                                                             │
│  [B] CRUD COMPLETO                                        │
│      Crear, Leer, Actualizar, Borrar                      │
│                                                             │
│  [C] CRUD + PROCESOS ASÍNCRONOS + INTEGRACIONES         │
│      Transacciones complejas, colas, APIs externas       │
└─────────────────────────────────────────────────────────────┘
```

```
┌─────────────────────────────────────────────────────────────┐
│  PREGUNTA 4: ¿Tienes integraciones externas?             │
├─────────────────────────────────────────────────────────────┤
│  [A] NINGUNA o MÁXIMO 1                                  │
│      Solo operaciones internas de NetSuite                │
│                                                             │
│  [B] 2-3 INTEGRACIONES                                  │
│      Gateway, VTEX, APIs de pagos, etc.                   │
│                                                             │
│  [C] MÁS DE 3                                            │
│      Múltiples sistemas externos                         │
└─────────────────────────────────────────────────────────────┘
```

```
┌─────────────────────────────────────────────────────────────┐
│  PREGUNTA 5: ¿Cuántas líneas de código estimás?           │
├─────────────────────────────────────────────────────────────┤
│  [A] POCAS (hasta 1500 líneas)                          │
│      Proyecto pequeño, código simple                    │
│                                                             │
│  [B] MEDIAS (1501-4000 líneas)                          │
│      Proyecto mediano, funcionalidad moderada            │
│                                                             │
│  [C] MUCHAS (más de 4000 líneas)                        │
│      Proyecto grande, sistema completo                   │
└─────────────────────────────────────────────────────────────┘
```

---

### Análisis de Respuestas

Después de las 5 preguntas, el skill analiza:

| Clasificación | Criterios |
|---------------|-----------|
| **PEQUEÑO** | A en mayoría |
| **MEDIANO** | B en mayoría |
| **GRANDE** | C en mayoría |

---

### Pregunta Adicional para Proyectos Medianos

Si el resultado es MEDIANO, hay una pregunta extra:

```
┌─────────────────────────────────────────────────────────────┐
│  Tu proyecto es MEDIANO.                                    │
│  ¿Querés usar carpeta Modules?                             │
├─────────────────────────────────────────────────────────────┤
│  [A] SÍ - Mi proyecto tendrá 3+ dominios                 │
│  [B] NO - Solo tendré 1-2 dominios                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase 2: Estructuras por Tipo de Proyecto

### PROYECTO PEQUEÑO

Estructura directa, sin carpeta Modules:

```
src/TypeScripts/[NombreProyecto]/
├── [Dominio]/                    # Directo (Sales, Inventory, etc.)
│   ├── [dominio].service.ts     # Lógica de negocio
│   ├── [dominio].repository.ts # Acceso a datos
│   └── [dominio].types.ts       # Definición de tipos
│
├── Interface/
│   └── gw_[tipo]_[nombre].ts   # Script NetSuite
│
└── Shared/
    └── utils/
        └── logger.ts
```

**Ejemplo de código:**

```typescript
// src/TypeScripts/NuevoProyecto/Sales/salesorder.service.ts
import record from 'N/record';

export class SalesOrderService {
  create(data: SalesOrderInput): number {
    const rec = record.create({ type: record.Type.SALES_ORDER });
    rec.setValue({ fieldId: 'entity', value: data.customerId });
    rec.setValue({ fieldId: 'location', value: data.locationId });
    return rec.save();
  }
}
```

---

### PROYECTO MEDIANO

Estructura con capas (Domain/Application/Infrastructure):

```
src/TypeScripts/[NombreProyecto]/
├── [Dominio]/                    # Opcional: Modules/ si ≥3 dominios
│   ├── Domain/
│   │   └── entities/
│   │       └── [dominio].entity.ts
│   │
│   ├── Application/
│   │   ├── services/
│   │   │   └── [dominio].service.ts
│   │   └── transforms/
│   │       └── [dominio].transform.ts
│   │
│   ├── Infrastructure/
│   │   └── repositories/
│   │       └── [dominio].repository.ts
│   │
│   └── validations/
│       └── [dominio].validation.ts
│
├── Interface/
│   ├── Restlets/
│   ├── UserEvents/
│   └── Suitelets/
│
└── Shared/
    ├── utils/
    └── constants/
```

**Ejemplo de código:**

```typescript
// src/TypeScripts/NuevoProyecto/Sales/Domain/entities/salesorder.entity.ts
export class SalesOrder {
  private data: SalesOrderData;

  constructor(data: SalesOrderData) {
    this.data = data;
  }

  canBeCreated(): boolean {
    return this.data.customerId > 0 && 
           this.data.locationId > 0 && 
           this.data.items.length > 0;
  }

  calculateTotal(): number {
    return this.data.items.reduce((sum, item) => {
      return sum + (item.quantity * item.rate);
    }, 0);
  }

  static create(data: SalesOrderData): { success: boolean; data?: SalesOrder; error?: string } {
    if (!data.customerId) {
      return { success: false, error: 'customerId es requerido' };
    }
    return { success: true, data: new SalesOrder(data) };
  }
}
```

---

### PROYECTO GRANDE

Estructura completa con Ports y Use Cases:

```
src/TypeScripts/[NombreProyecto]/
├── Modules/                      # SIEMPRE con Modules
│   └── [Dominio]/
│       ├── Domain/
│       │   ├── entities/
│       │   ├── value-objects/
│       │   ├── events/
│       │   └── services/
│       │
│       ├── Application/
│       │   ├── use-cases/
│       │   ├── ports/
│       │   │   ├── inbound/
│       │   │   └── outbound/
│       │   ├── dtos/
│       │   └── services/
│       │
│       ├── Infrastructure/
│       │   ├── persistence/
│       │   └── adapters/
│       │
│       └── validations/
│
├── Interface/
│   ├── Restlets/
│   ├── Suitelets/
│   ├── UserEvents/
│   ├── Scheduled/
│   └── MapReduce/
│
└── Shared/
    ├── domain/
    │   ├── result.ts
    │   └── guard.ts
    └── utils/
```

**Ejemplo de código:**

```typescript
// src/TypeScripts/NuevoProyecto/Modules/Sales/Application/use-cases/create-sales-order.usecase.ts
import { SalesOrder } from '../../Domain/entities/salesorder.entity';
import { SalesOrderRepositoryPort } from '../ports/outbound/sales-order-repository.port';
import { GatewayAdapterPort } from '../ports/outbound/gateway-adapter.port';

export class CreateSalesOrderUseCase {
  constructor(
    private repository: SalesOrderRepositoryPort,
    private gatewayAdapter: GatewayAdapterPort
  ) {}

  async execute(inputData: unknown): Promise<{ success: boolean; data?: number; error?: string }> {
    // 1. Adaptar datos de entrada
    const adapted = this.gatewayAdapter.adapt(inputData);
    if (!adapted.success) return adapted;

    // 2. Validar con Entity
    const entityResult = SalesOrder.create(adapted.data);
    if (!entityResult.success) return { success: false, error: entityResult.error };

    // 3. Persistir
    return await this.repository.create(entityResult.data);
  }
}
```

---

## Phase 3: Cómo Crear un Proyecto

Una vez clasificado el proyecto, el skill puede crear la estructura automáticamente.

**Parámetros necesarios:**

| Parámetro | Descripción | Ejemplo |
|-----------|-------------|---------|
| `ruta` | Ruta donde crear el proyecto | `src/TypeScripts/MiProyecto/` |
| `nombre` | Nombre del proyecto | `MiProyecto` |
| `dominio` | Dominio principal | `Sales` |

**En OpenCode**, ejecutar:

```bash
# Proyecto pequeño
./scripts/create-small.sh "src/TypeScripts/NuevoSales" "NuevoSales" "Sales"

# Proyecto mediano sin Modules
./scripts/create-medium.sh "src/TypeScripts/NuevoSales" "NuevoSales" "Sales" "no"

# Proyecto mediano con Modules
./scripts/create-medium.sh "src/TypeScripts/NuevoSales" "NuevoSales" "Sales" "yes"

# Proyecto grande
./scripts/create-large.sh "src/TypeScripts/NuevoSales" "NuevoSales" "Sales"
```

---

## Recursos

Para más información sobre las arquitecturas usadas:

- **Clean Architecture**: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **Hexagonal Architecture**: https://alistair.cockburn.us/hexagonal-architecture
- **Wikipedia**: https://en.wikipedia.org/wiki/Hexagonal_architecture_(software)

Consulta también el archivo `ARCHITECTURE.md` para una explicación detallada de por qué se usa esta arquitectura híbrida.

---

## Troubleshooting

**Problema**: No sé qué tamaño elegir

- Si es tu primer proyecto NetSuite → probablemente PEQUEÑO
- Si solo necesitas un Restlet simple → PEQUEÑO
- Si necesitas CRUD completo → MEDIANO
- Si tienes múltiples integraciones → GRANDE

**Problema**: ¿Modules o no?

- 1 dominio → NO
- 2 dominios → OPCIONAL (depende si crecerás)
- 3+ dominios → SÍ