# NetSuite Clean Architecture Skill

Guía para crear proyectos NetSuite con TypeScript usando arquitectura limpia.

## Características

- ✅ Clasificación automática de proyectos (pequeño/mediano/grande)
- ✅ Clona repositorio template automáticamente
- ✅ Configura package.json y tsconfig.json
- ✅ Crea estructura TypeScripts según clasificación
- ✅ Crea scripts NetSuite con prefijo personalizado
- ✅ Soporta Clean Architecture y Hexagonal Architecture

## Instalación

```bash
npx skills add gildder/netsuite-architecture-skill
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
| Suitelet | sl | gw_sl_facturas.ts |
| Restlet | rs | gw_rs_pedidos.ts |
| User Event | ue | gw_ue_factura.ts |
| Scheduled | ss | gw_ss_sync.ts |
| Map/Reduce | mr | gw_mr_import.ts |

## Documentación

- [SKILL.md](SKILL.md) - Guía completa del skill
- [ARCHITECTURE.md](ARCHITECTURE.md) - Explicación de arquitecturas

## Template

Este skill usa el repositorio template:
https://github.com/gildder/netsuite-ts-sdf-template

## Licencia

MIT