# NetSuite Clean Architecture Skill

Guía para crear proyectos NetSuite con TypeScript usando arquitectura limpia.

## Características

- ✅ Clasificación automática de proyectos (pequeño/mediano/grande)
- ✅ Clona repositorio template automáticamente
- ✅ Configura package.json y tsconfig.json
- ✅ Crea estructura TypeScripts según clasificación
- ✅ Crea scripts NetSuite con prefijo personalizado
- ✅ Soporta Clean Architecture y Hexagonal Architecture

## Compatibilidad

Este skill es compatible con múltiples modelos y herramientas de IA:

| Herramienta | Ubicación Skills | Ubicación Agentes |
|-------------|------------------|-------------------|
| **OpenCode** | `.opencode/skills/` | `.opencode/agents/` |
| **Claude Code** | `.claude/skills/` | `.claude/agents/` |
| **Cursor** | `.cursor/rules/` | `.cursor/agents/` |
| **Windsurf** | `.windsurf/rules/` | (no soportado) |

## Estructura de Archivos

```
netsuite-architecture-skill/
├── .opencode/                    ← OpenCode
│   ├── skills/netsuite-clean-architecture/SKILL.md
│   └── agents/orkidns/AGENT.md
├── .claude/                      ← Claude Code
│   ├── skills/netsuite-clean-architecture/SKILL.md
│   └── agents/orkidns/AGENT.md
├── .agents/                      ← Otros agentes
│   └── skills/netsuite-clean-architecture/SKILL.md
├── orkidns/AGENT.md              ← Referencia
├── SKILL.md                      ← Original
└── EXAMPLES.md                   ← Ejemplos
```

## Instalación por Herramienta

### OpenCode

```bash
# Copiar estructura .opencode/
cp -r .opencode/ /tu-proyecto/
```

O en `opencode.json`:
```json
{
  "skills": {
    "netsuite-clean-architecture": {
      "path": "C:\\path\\to\\netsuite-architecture-skill"
    }
  }
}
```

### Claude Code / Cursor / Windsurf

```bash
# Copiar estructura .claude/ o .cursor/
cp -r .claude/ /tu-proyecto/
```

### GitHub CLI (agents)

```bash
# Usar con gh auth
gh extension install github/agents
```

### Opción 1: Copiar directamente al proyecto

Copia la carpeta `.opencode/` de este repositorio a tu proyecto:

```bash
# En tu proyecto NetSuite
cp -r path/to/netsuite-architecture-skill/.opencode/ .
```

### Opción 2: Enlazar con opencode.json

En tu `opencode.json`:

```json
{
  "skills": {
    "netsuite-clean-architecture": {
      "path": "C:\\path\\to\\netsuite-architecture-skill",
      "description": "Guide for NetSuite TypeScript projects with Clean Architecture"
    }
  },
  "agent": {
    "orkidns": {
      "description": "Validates and generates code following NetSuite architecture",
      "mode": "subagent",
      "tools": {
        "bash": true,
        "read": true,
        "write": true,
        "grep": true,
        "glob": true
      }
    }
  }
}
```

## Flujo de Uso

### 1. El skill pregunta los datos del proyecto:

- **Ubicación**: Dónde crear el proyecto
- **Nombre**: Nombre de carpeta (ej: "facturas")
- **Prefijo**: Para scripts NetSuite (ej: "gw" → gw_sl_facturas.ts)
- **Dominio**: Principal (ej: "Sales", "Inventory")

### 2. Clasificación con 5 preguntas

Una pregunta a la vez para determinar el tipo de proyecto.

### 3. Creación automática

El skill clona el template y configura todo automáticamente.

## Estructuras de Proyecto

| Tipo | Dominios | Scripts | Estructura |
|------|----------|---------|------------|
| PEQUEÑO | 1 | ≤5 | Directa (sin Modules) |
| MEDIANO | 1-2 | 6-15 | Capas (con/sin Modules) |
| GRANDE | 3+ | >15 | Hexagonal (Ports, Use Cases) |

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

## OrkidNS - Agente de Arquitectura

Este skill incluye **OrkidNS**, un agente para validar y generar código siguiendo la arquitectura.

### Comandos

| Comando | Descripción |
|---------|-------------|
| `orkidns add "idea"` | Crear componentes desde una idea |
| `orkidns check` | Validar arquitectura |
| `orkidns info` | Explicar estructura de carpetas |
| `orkidns list` | Listar componentes |
| `orkidns init` | Inicializar en proyecto |
| `orkidns fix` | Corregir problemas |
| `orkidns normalize` | Corregir TypeScript al formato NetSuite |
| `orkidns hint` | Sugerencias |

### Ejemplos de uso

Ver [EXAMPLES.md](EXAMPLES.md) para ejemplos detallados de cada comando.

### Configuración

Agregar en `opencode.json`:

```json
{
  "skills": {
    "netsuite-clean-architecture": {
      "path": "C:\\...\\netsuite-architecture-skill"
    }
  },
  "agent": {
    "orkidns": {
      "description": "Valida y genera código siguiendo la arquitectura NetSuite",
      "mode": "subagent",
      "tools": { "bash": true, "read": true, "write": true, "grep": true }
    }
  }
}
```

Ver `orkidns/AGENT.md` para documentación completa.

## Documentación

- [SKILL.md](SKILL.md) - Guía completa del skill
- [ARCHITECTURE.md](ARCHITECTURE.md) - Explicación de arquitecturas
- [orkidns/AGENT.md](orkidns/AGENT.md) - Documentación del agente
- [EXAMPLES.md](EXAMPLES.md) - Ejemplos prácticos de uso

## Template

Este skill usa el repositorio template:
https://github.com/gildder/netsuite-ts-sdf-template

## Licencia

MIT