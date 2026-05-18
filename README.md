# NetSuite Clean Architecture Skill

A reusable skill for AI assistants to create and manage NetSuite TypeScript projects with Clean Architecture patterns.

## What Is This?

A **skill** is a reusable instruction bundle that AI assistants can discover and load on-demand when needed. This skill provides:

- Project classification (small/medium/large)
- Automatic template cloning and setup
- Clean Architecture structure generation
- Script type detection and creation

## What Does It Do?

### For Projects

1. **Classification**: Determines project size (small/medium/large) using 8 questions
2. **Setup**: Clones a TypeScript template and configures:
   - `package.json` with project name
   - `tsconfig.json` paths
   - `deploy.xml` and `manifest.xml`
   - `biome.json` for formatting
3. **Structure**: Creates TypeScripts folder hierarchy based on classification

### For Code

- **OrkidNS Agent**: Validates architecture and suggests improvements
- **Normalize**: Fixes TypeScript files to NetSuite format (JSDoc injection)

## How Does It Work?

```
User Request → Skill Load → Questions → Template Clone → Structure Generation
                            ↓
                     OrkidNS Agent ←── Validates and generates code
```

### Components

| Component | Purpose |
|-----------|---------|
| **SKILL.md** | Main instructions for AI assistants |
| **AGENT.md** | OrkidNS subagent definition |
| **scripts/** | Build and normalization scripts |
| **templates/** | Configuration templates |

## Installation

### Quick Setup

Copy the `.claude/` folder from this repository to your project:

```bash
# In your project directory
cp -r /path/to/netsuite-architecture-skill/.claude/ .
```

### Per Platform

#### Claude Code

```bash
# Project-level (shared with team)
mkdir -p .claude/skills/netsuite-clean-architecture
mkdir -p .claude/agents/orkidns

# Copy SKILL.md and AGENT.md
```

#### OpenCode

```bash
# Project-level
mkdir -p .opencode/skills/netsuite-clean-architecture
mkdir -p .opencode/agents/orkidns

# Copy SKILL.md and AGENT.md
```

Or configure in `opencode.json`:
```json
{
  "skills": {
    "netsuite-clean-architecture": {
      "path": "C:\\path\\to\\netsuite-architecture-skill"
    }
  }
}
```

#### Cursor / Windsurf

```bash
mkdir -p .cursor/rules/netsuite-clean-architecture
# Copy SKILL.md as .cursor/rules/netsuite-clean-architecture.md
```

## Usage

### Starting a New Project

Tell the AI assistant:

```
"Create a new NetSuite project"
"I need to start a TypeScript project for NetSuite"
```

The skill will ask 8 questions:
1. Where to create the project
2. Project name
3. Script prefix (e.g., "gw" → gw_sl_facturas.ts)
4. Primary domain (Sales, Inventory, etc.)
5. Number of domains
6. Module folder preference
7. Clean or Hexagonal Architecture
8. Script type expectations

### Using OrkidNS Agent

After project creation, invoke the agent:

```
@orkidns check      # Validate architecture
@orkidns add "..."  # Create components from idea
@orkidns normalize  # Fix TypeScript files
@orkidns list       # List all components
```

### Commands Reference

| Command | Description |
|---------|-------------|
| `/netsuite-clean-architecture` | Load the skill manually |
| `@orkidns check` | Validate project structure |
| `@orkidns add "idea"` | Generate components |
| `@orkidns normalize [path]` | Fix TypeScript format |
| `@orkidns info` | Show architecture guide |
| `@orkidns list` | List all components |
| `@orkidns hint` | Suggest improvements |

## Compatibility

| Platform | Skills Location | Agents Location |
|----------|-----------------|-----------------|
| Claude Code | `.claude/skills/` | `.claude/agents/` |
| OpenCode | `.opencode/skills/` | `.opencode/agents/` |
| Cursor | `.cursor/rules/` | Not supported |
| Windsurf | `.windsurf/rules/` | Not supported |

## File Structure

```
netsuite-architecture-skill/
├── .claude/                    # Claude Code
│   ├── skills/netsuite-clean-architecture/SKILL.md
│   └── agents/orkidns/AGENT.md
├── .opencode/                  # OpenCode
│   ├── skills/netsuite-clean-architecture/SKILL.md
│   └── agents/orkidns/AGENT.md
├── .agents/                    # Other agents
│   └── skills/netsuite-clean-architecture/SKILL.md
├── orkidns/                    # Reference files
│   ├── AGENT.md
│   ├── orkidns.config.json
│   └── templates/
├── scripts/                    # Build scripts
│   ├── create-project.sh
│   ├── prepend-headers.js
│   └── normalize-ts.ps1
├── templates/                  # Config templates
├── SKILL.md                    # Main skill (root)
├── AGENT.md                    # Agent reference
└── README.md                   # This file
```

## Requirements

- Node.js 18+
- TypeScript 5.x
- Git

## Examples

See [EXAMPLES.md](EXAMPLES.md) for detailed usage examples.

## License

MIT