# NetSuite Clean Architecture - Architecture Guide

## Overview

This document explains the two main architectures used in NetSuite projects: **Clean Architecture** (Uncle Bob) and **Hexagonal Architecture** (Alistair Cockburn), and why we use a hybrid approach.

---

## Clean Architecture

### Origin

- **Author**: Robert C. Martin (Uncle Bob)
- **Year**: 2012
- **Source**: [The Clean Architecture - Blog](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Layers

```
┌─────────────────────────────────────┐
│         Frameworks & Drivers        │  ← NetSuite API, TypeScript
├─────────────────────────────────────┤
│         Interface Adapters          │  ← Scripts (Restlet, Suitelet)
├─────────────────────────────────────┤
│            Application              │  ← Use Cases, Services
├─────────────────────────────────────┤
│              Domain                 │  ← Entities, Business Rules
└─────────────────────────────────────┘
```

### Principles

1. **Independent of Frameworks**: The architecture doesn't depend on NetSuite
2. **Testable**: Business rules can be tested without UI or database
3. **Independent of UI**: The same business logic works in Suitelet, Restlet, or UserEvent
4. **Independent of Database**: Switch from NetSuite to another DB without changing business logic

---

## Hexagonal Architecture

### Origin

- **Author**: Alistair Cockburn
- **Year**: 2005
- **Sources**:
  - [Hexagonal Architecture - Original](https://alistair.cockburn.us/hexagonal-architecture)
  - [Wikipedia](https://en.wikipedia.org/wiki/Hexagonal_architecture_(software))

### Concept

```
                    ┌───────────────────────┐
                    │                       │
          ┌─────────┤   Application Core    ├─────────┐
          │         │   (Domain + UseCases) │         │
          │         │                       │         │
    ┌─────┴────┐    └───────────────────────┘    ┌─────┴────┐
    │   Ports  │                                   │   Ports  │
    │  (In)    │                                   │  (Out)   │
    └─────┬────┘                                   └─────┬────┘
          │                                           │
    ┌─────┴─────┐                               ┌─────┴─────┐
    │Adapters   │                               │Adapters   │
    │  (UI)     │                               │  (DB,     │
    └───────────┘                               │   External│
                                                 └───────────┘
```

### Ports & Adapters

- **Ports**: Interfaces that define how the outside interacts with the core
- **Adapters**: Implementations that connect to external systems

---

## Why Hybrid for NetSuite?

### NetSuite Context

| Aspect | NetSuite Reality |
|--------|------------------|
| **Database** | Rarely changes - NetSuite is the system of record |
| **External Systems** | Frequently change - VTEX, Gateway, payment providers |
| **Business Logic** | Must remain stable across all interfaces |

### The Hybrid Approach

We combine Clean Architecture's layer concept with Hexagonal's ports:

```
┌─────────────────────────────────────────────────────────────┐
│                    INTERFACE LAYER                         │
│  (Restlets, Suitelets, UserEvents, Scheduled, MapReduce) │
├─────────────────────────────────────────────────────────────┤
│                   APPLICATION LAYER                        │
│  (Use Cases, Services, Transforms, Validations)           │
├─────────────────────────────────────────────────────────────┤
│                     DOMAIN LAYER                           │
│  (Entities, Value Objects, Events, Ports/Interfaces)     │
├─────────────────────────────────────────────────────────────┤
│                  INFRASTRUCTURE LAYER                      │
│  (Repositories, Adapters - VTEX, Gateway, Payment)       │
└─────────────────────────────────────────────────────────────┘
```

### Benefits

1. **Domain stays stable**: Business rules don't depend on external systems
2. **Adapters are swappable**: Change VTEX to another provider without touching domain
3. **Testable**: Mock adapters for unit tests
4. **Multiple interfaces**: Same business logic works in Restlet + UserEvent + Scheduled

---

## NetSuite Specific Implementation

### File Structure Mapping

| Clean Architecture | NetSuite Implementation |
|-------------------|------------------------|
| Frameworks | `@hitc/netsuite-types`, TypeScript, tsc |
| Interface Adapters | `src/Interface/` - Scripts |
| Application | `src/[Dominio]/Application/` - Services, Use Cases |
| Domain | `src/[Dominio]/Domain/` - Entities, Ports |
| Infrastructure | `src/[Dominio]/Infrastructure/` - Repositories, Adapters |

### Example Mapping

```
Traditional Clean Architecture          →    NetSuite TypeScript
──────────────────────────────────────          ─────────────────────
src/Interface/Restlets/                   →    src/Interface/Restlets/
  gw_restlet_sales.ts                         gw_restlet_sales.ts

src/Application/UseCases/                  →    src/Sales/Application/
  create-sales-order.ts                         services/

src/Domain/Entities/                      →    src/Sales/Domain/
  sales-order.ts                              entities/

src/Infrastructure/Repositories/          →    src/Sales/Infrastructure/
  sales-order.repository.ts                    repositories/

src/Infrastructure/Adapters/              →    src/Sales/Infrastructure/
  vtex.adapter.ts                              adapters/
```

---

## Key Concepts

### Dependency Rule

> Source code dependencies must point only inward, toward the higher-level policy.

```
GOOD:                         BAD:
Interface ─→ Domain          Interface ─→ Infrastructure
Application ─→ Domain         Application ─→ Adapter
Infrastructure ─→ Domain
```

### Dependency Injection in NetSuite

Since NetSuite doesn't support DI natively, we use:

```typescript
// Factory pattern
const repository = new SalesOrderRepository();
const adapter = new GatewayAdapter();
const service = new SalesOrderService(repository, adapter);

// Singleton pattern
const salesOrderService = new (require('salesorder.service'))();
```

---

## When to Use Each Architecture

| Scenario | Recommended Architecture |
|----------|-------------------------|
| Single Restlet | Simple Layered (no ports needed) |
| 2-3 scripts, 1 domain | Clean Architecture basic |
| 6-15 scripts, 2+ domains | Clean + Hexagonal hybrid |
| 15+ scripts, multiple integrations | Full Hexagonal with Ports |

---

## References

1. **Clean Architecture**: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
2. **Hexagonal Architecture**: https://alistair.cockburn.us/hexagonal-architecture
3. **Hexagonal Architecture Wikipedia**: https://en.wikipedia.org/wiki/Hexagonal_architecture_(software)
4. **Domain-Driven Design**: Eric Evans (for entities and value objects concept)
5. **TypeScript NetSuite Template**: https://github.com/mattplant/netsuite-ts-sdf-template

---

## License

This architecture guide is adapted from the original works of Robert C. Martin and Alistair Cockburn, licensed under their respective terms.