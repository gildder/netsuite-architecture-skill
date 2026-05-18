# OrkidNS - NetSuite Architecture Agent

## Overview

OrkidNS (Orkestador NetSuite) is a sub-agent that validates and generates code following the NetSuite Clean Architecture pattern. It ensures that all code follows the established architecture rules.

## Available Commands

| Command | Description |
|---------|-------------|
| `orkidns add "idea"` | Create components from a user idea |
| `orkidns check` | Validate project architecture |
| `orkidns info [folder]` | Explain what goes in each folder |
| `orkidns list` | List all project components |
| `orkidns init` | Initialize OrkidNS in a project |
| `orkidns fix` | Fix architecture problems |
| `orkidns normalize` | Fix TypeScript to NetSuite format |
| `orkidns hint` | Suggest improvements based on existing code |

---

## Command Details

### orkidns add "idea"

Analyzes the user's idea and infers the components needed:

```
USER: orkidns add "I want to create invoices"

ORKIDNS RESPONSE:
📋 Based on your idea "create invoices":

Suggested components:
✅ Entity: Domain/entities/invoice.entity.ts
✅ Service: Application/services/invoice.service.ts
✅ Repository: Infrastructure/persistence/invoice.repository.ts

Proceed? (yes/no/edit)
```

**Inference Keywords:**
- "create" / "new" → Entity + Service + Repository
- "read" / "get" / "consult" → Repository + Service
- "integrate" → Adapter + Port
- "sync" / "import" / "export" → UseCase + Adapter
- "validate" → Validation
- "transform" → Transform
- "event" → DomainEvent + EventHandler
- "crud" / "complete" → Entity + Service + Repository + Validation + Transform
- "api" / "restlet" → Port + Adapter
- "scheduled" / "batch" → UseCase + Scheduled

---

### orkidns check

Validates the entire project architecture:

```
✅ Valid: Domain/entities/ - only contains .entity.ts files
❌ Invalid: Application/services/ contains adapter code
   → Move adapters to Infrastructure/adapters/
✅ Valid: Imports follow dependency rules
```

**Validation Rules:**
1. Files are in correct folders based on type
2. No circular dependencies
3. Domain does not depend on Application or Infrastructure
4. Ports are used for external integrations

---

### orkidns info [folder]

Shows what should and should NOT be in a folder:

```
orkidns info "Application/services"

📁 Application/services/
   ✅ SHOULD contain:
      - * .service.ts (business logic)
      - Business orchestration
      - Use case implementations

   ❌ SHOULD NOT contain:
      - Direct record access (use Repository)
      - External API calls (use Adapter)
      - Entity definitions (use Domain/entities/)

   📝 Example:
      // CORRECT
      export class InvoiceService {
        private repository: InvoiceRepository;
        create(data) { ... }
      }

      // INCORRECT - direct record access
      export class InvoiceService {
        create(data) {
          const rec = record.create({ type: 'invoice' }); // WRONG!
        }
      }
```

---

### orkidns list

Lists all components organized by domain:

```
📊 Project Components:

🏠 Domain: Sales
   ├── Entities (3): invoice, customer, product
   ├── Services (2): invoice, customer
   └── Repositories (2): invoice, customer

🏠 Domain: Inventory
   ├── Entities (2): item, stock
   └── Services (1): item
```

---

### orkidns init

Initializes OrkidNS in a project:

1. Detects project type from package.json/tsconfig.json
2. Scans existing folders
3. Creates orkidns.config.json
4. Validates current structure

---

### orkidns fix

Automatically fixes architecture problems:

```
❌ Found: adapter in Application/services/
   → Moving to Infrastructure/adapters/

✅ Fixed: src/Modules/Sales/Application/services/vtex.adapter.ts
   → src/Modules/Sales/Infrastructure/adapters/vtex.adapter.ts
```

---

### orkidns normalize

Fixes TypeScript files to ensure they compile correctly to NetSuite JavaScript. This command:

1. Adds missing JSDoc headers (`@NApiVersion 2.1`, `@NModuleScope`)
2. Fixes export format for NetSuite entry points
3. Adds missing imports for NetSuite types
4. Fixes common TypeScript issues

```
USER: orkidns normalize "src/TypeScripts/Sales/invoice.ts"

ORKIDNS RESPONSE:
📝 Fixing: src/TypeScripts/Sales/invoice.ts

✅ Added JSDoc header:
   - @NApiVersion 2.1
   - @NModuleScope Public
   - @NScriptType Suitelet

✅ Fixed exports:
   - Added EntryPoints type for onRequest
   - Changed export to NetSuite format

✅ Fixed imports:
   - Added "N/types" for EntryPoints
   - Kept "N/record" import

---
Before:
```typescript
import record from 'N/record';

export function onRequest(context) {
  const rec = record.create({ type: 'invoice' });
  context.response.write('Hello');
}
```

After:
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
```

#### Auto-detection of Script Type

OrkidNS analyzes the file content to detect the script type:

| Content Pattern | → | Script Type |
|----------------|---|-------------|
| `onRequest` | | Suitelet |
| `pageInit` | | ClientScript |
| `beforeSubmit` / `afterSubmit` | | UserEvent |
| `getInputData` / `map` / `reduce` / `summarize` | | MapReduce |
| `execute` | | Scheduled |

#### Fixes Applied

| Issue | Fix Applied |
|-------|-------------|
| Missing JSDoc | Adds `@NApiVersion 2.1`, `@NModuleScope Public` |
| Missing @NScriptType | Auto-detects based on function names |
| Wrong export format | Converts to NetSuite entry point format |
| Missing EntryPoints import | Adds `import { EntryPoints } from 'N/types'` |
| Non-existent types | Fixes to correct NetSuite types |
| record.Type string | Changes to `record.Type.INVOICE` (enum) |

---

### orkidns hint

Analyzes existing code and suggests improvements:

```
💡 Suggestions for src/Modules/Sales/Application/services/invoice.service.ts:

1. ⚠️ Direct record access detected
   → Consider using Repository pattern

2. ✅ Good use of Entity validation

3. 💡 Missing DTOs for input/output
   → Consider adding Application/dtos/
```

---

## Folder Structure Rules

### PEQUEÑO (Small)
```
src/TypeScripts/[project]/
├── [Domain]/
│   ├── *.service.ts
│   ├── *.repository.ts
│   └── *.types.ts
├── Interface/
└── Shared/
```

### MEDIANO (Medium)
```
src/TypeScripts/[project]/
├── [Domain]/
│   ├── Domain/entities/
│   ├── Application/services/, transforms/
│   ├── Infrastructure/repositories/
│   └── validations/
├── Interface/
└── Shared/
```

### GRANDE (Large)
```
src/TypeScripts/[project]/
├── Modules/
│   └── [Domain]/
│       ├── Domain/ (entities, value-objects, events, services)
│       ├── Application/ (use-cases, ports, dtos, services, transforms)
│       ├── Infrastructure/ (persistence, adapters)
│       └── validations/
├── Interface/
└── Shared/
```

---

## Architecture Rules

### Dependency Rule
```
✅ VALID:
- Application → Domain
- Infrastructure → Domain
- Interface → Application or Infrastructure

❌ INVALID:
- Domain → Application
- Domain → Infrastructure
- Application → Infrastructure (use Ports instead)
```

### File Type Rules

| File Type | Where it GOES | Where it DOES NOT GO |
|-----------|---------------|---------------------|
| *.entity.ts | Domain/entities/ | Application/, Infrastructure/ |
| *.service.ts | Application/services/ | Domain/ |
| *.repository.ts | Infrastructure/persistence/ | Domain/ |
| *.adapter.ts | Infrastructure/adapters/ | Application/ |
| *.port.ts | Application/ports/ | Domain/ |
| *.usecase.ts | Application/use-cases/ | Domain/ |
| *.validation.ts | validations/ | Domain/ |
| *.transform.ts | Application/transforms/ | Domain/ |

---

## Integration

This agent is configured in opencode.json and can be invoked using the commands above.

For full skill documentation, see SKILL.md.