# NetSuite Clean Architecture Skill

Guía para crear proyectos NetSuite con TypeScript usando arquitectura limpia.

## Instalación

### Para OpenCode

```bash
npx skills add gguerrero/netsuite-architecture-skill
```

### Para Claude Code / Cursor / Codex

```bash
# Clonar el repositorio
git clone https://github.com/gguerrero/netsuite-architecture-skill.git
cd netsuite-architecture-skill
```

## Uso

### 1. Clasificar tu Proyecto

El skill te hará 5 preguntas para determinar el tamaño de tu proyecto:

```
1. ¿Cuántos scripts NetSuite tendrá? (A/B/C)
2. ¿Cuántos dominios necesitas? (A/B/C)
3. ¿Qué operaciones necesitas? (A/B/C)
4. ¿Tienes integraciones externas? (A/B/C)
5. ¿Cuántas líneas de código estimás? (A/B/C)
```

### 2. Crear la Estructura

Una vez clasificado, ejecuta el script correspondiente:

```bash
# Proyecto pequeño (sin Modules)
./scripts/create-small.sh "src/TypeScripts/MiProyecto" "MiProyecto" "Sales"

# Proyecto mediano (sin Modules)
./scripts/create-medium.sh "src/TypeScripts/MiProyecto" "MiProyecto" "Sales" "no"

# Proyecto mediano (con Modules)
./scripts/create-medium.sh "src/TypeScripts/MiProyecto" "MiProyecto" "Sales" "yes"

# Proyecto grande (con Modules)
./scripts/create-large.sh "src/TypeScripts/MiProyecto" "MiProyecto" "Sales"
```

### 3. Compilar a JavaScript

```bash
npm install
npm run build
```

## Estructuras de Proyecto

| Tamaño | Dominios | Scripts | Líneas | Estructura |
|--------|----------|---------|--------|------------|
| PEQUEÑO | 1 | ≤5 | ≤1500 | Directa |
| MEDIANO | 1-2 | 6-15 | 1501-4000 | Capas (con/sin Modules) |
| GRANDE | 3+ | >15 | >4000 | Módulos con Ports |

## Documentación

- [SKILL.md](SKILL.md) - Guía completa del skill
- [ARCHITECTURE.md](ARCHITECTURE.md) - Explicación de arquitecturas

## Requisitos

- Node.js 18+
- TypeScript 5+
- NetSuite SDF CLI (para despliegue)

## Licencia

MIT