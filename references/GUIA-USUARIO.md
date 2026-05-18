# Guía de Usuario - NetSuite Clean Architecture

## ¿Qué es este proyecto?

**NetSuite Clean Architecture** es un conjunto de herramientas que te ayudan a crear proyectos NetSuite con TypeScript siguiendo las mejores prácticas de arquitectura de software.

### ¿Para qué sirve?

- ✅ Crear proyectos NetSuite desde cero con estructura profesional
- ✅ Mantener el código organizado siguiendo Clean Architecture
- ✅ Normalizar archivos TypeScript para que funcionen en NetSuite
- ✅ Validar que el código siga las reglas de arquitectura
- ✅ Generar automáticamente los archivos XML de despliegue

---

## Requisitos Previos

Antes de comenzar, asegurate de tener instalado:

| Requerimiento | Versión mínima | Verificar con |
|---------------|----------------|---------------|
| Node.js | 18.x | `node --version` |
| npm o yarn | 6.x+ | `npm --version` |
| Git | 2.x | `git --version` |
| PowerShell | 5.1+ | `$PSVersionTable.PSVersion` |

---

## Inicio Rápido

### Paso 1: Clonar o descargar este repositorio

```bash
git clone https://github.com/tu-usuario/netsuite-architecture-skill.git
cd netsuite-architecture-skill
```

### Paso 2: Ejecutar el script de creación

```powershell
# Desde la carpeta scripts
cd scripts

# Crear un proyecto nuevo
.\create-project.ps1 -Ruta "C:\proyectos\mi-proyecto" -Nombre "mi-proyecto" -Dominio "Sales" -Tipo "pequeno" -Prefijo "gw"
```

### Paso 3: ¡Listo!

El script automáticamente:
- Clona el template de NetSuite
- Configura package.json, tsconfig.json
- Crea la estructura de carpetas
- Instala las dependencias

---

## Tipos de Proyectos

### 🏠 Pequeño (1-5 scripts)

Para proyectos simples como un Restlet básico o un Suitelet pequeño.

```
src/TypeScripts/mi-proyecto/
├── Sales/
│   ├── Sales.types.ts
│   ├── Sales.service.ts
│   └── Sales.repository.ts
├── Interface/
│   └── gw_sales_restlet.ts
└── Shared/
    └── utils/
```

**Usa este tipo si:**
- Tenés menos de 5 scripts
- Solo un dominio (Sales, Inventory, etc.)
- Operaciones básicas (crear/leer)

---

### 🏢 Mediano (6-15 scripts)

Para proyectos con más complejidad, como un CRUD completo.

**Sin Modules:**
```
src/TypeScripts/mi-proyecto/
├── Sales/
│   ├── Domain/entities/
│   ├── Application/services/, transforms/
│   ├── Infrastructure/repositories/
│   └── validations/
├── Interface/
└── Shared/
```

**Con Modules:**
```
src/TypeScripts/mi-proyecto/
├── Modules/
│   └── Sales/
│       ├── Domain/entities/
│       ├── Application/
│       └── Infrastructure/
├── Interface/
└── Shared/
```

**Usa este tipo si:**
- Tenés entre 6-15 scripts
- Necesitás 2+ dominios
- Tenés integraciones externas

---

### 🏰 Grande (15+ scripts)

Para proyectos complejos con múltiples integraciones.

```
src/TypeScripts/mi-proyecto/
├── Modules/
│   └── [Dominio]/
│       ├── Domain/ (entities, value-objects, events)
│       ├── Application/ (use-cases, ports, dtos, services)
│       ├── Infrastructure/ (persistence, adapters)
│       └── validations/
├── Interface/ (Restlets, Suitelets, UserEvents, etc.)
└── Shared/ (domain, utils, constants)
```

**Usa este tipo si:**
- Tenés más de 15 scripts
- Múltiples integraciones (VTEX, Gateway, etc.)
- Procesos asíncronos (Scheduled, MapReduce)

---

## Guía de Scripts

### create-project.ps1

Crea un proyecto completo desde cero.

```powershell
.\create-project.ps1 -Ruta "C:\proyectos\mi-proyecto" `
                      -Nombre "mi-proyecto" `
                      -Dominio "Sales" `
                      -Tipo "pequeno" `
                      -Prefijo "gw"
```

**Parámetros:**

| Parámetro | Obligatorio | Descripción |
|-----------|-------------|-------------|
| `-Ruta` | Sí | Ruta absoluta donde se creará el proyecto |
| `-Nombre` | Sí | Nombre del proyecto (se usa en package.json) |
| `-Dominio` | Sí | Dominio principal: Sales, Inventory, Customer, etc. |
| `-Tipo` | Sí | `pequeno`, `mediano-sin-modules`, `mediano-con-modules`, `grande` |
| `-Prefijo` | No | Prefijo para los scripts (default: `gw`) |

---

### create-small.ps1

Crea solo la estructura de proyecto pequeño (sin clonar template).

```powershell
.\create-small.ps1 -Ruta "src\TypeScripts\MiProyecto" `
                   -Nombre "MiProyecto" `
                   -Dominio "Sales" `
                   -Prefijo "gw"
```

---

### create-medium.ps1

Crea estructura de proyecto mediano.

```powershell
.\create-medium.ps1 -Ruta "src\TypeScripts\MiProyecto" `
                    -Nombre "MiProyecto" `
                    -Dominio "Sales" `
                    -Prefijo "gw" `
                    -ConModules  # Agregar si quiere carpeta Modules
```

---

### create-large.ps1

Crea estructura de proyecto grande con todos los componentes.

```powershell
.\create-large.ps1 -Ruta "src\TypeScripts\MiProyecto" `
                   -Nombre "MiProyecto" `
                   -Dominio "Sales" `
                   -Prefijo "gw"
```

---

### normalize-ts.ps1

Normaliza archivos TypeScript al formato NetSuite.

**Normalizar un archivo:**
```powershell
.\normalize-ts.ps1 "src\TypeScripts\Sales\invoice.ts"
```

**Normalizar una carpeta:**
```powershell
.\normalize-ts.ps1 "src\TypeScripts\Sales" -Recursive
```

**¿Qué hace este script?**
- Agrega JSDoc faltante (`@NApiVersion`, `@NModuleScope`, `@NScriptType`)
- Detecta el tipo de script automáticamente
- Convierte `record.Type` de string a enum
- Convierte exports al formato de NetSuite

---

### generate-sdf.ps1

Genera los archivos XML de definición de scripts.

```powershell
.\generate-sdf.ps1 -ProjectPath "C:\proyectos\mi-proyecto" -Prefix "gw"
```

**¿Qué genera?**
- `customscript_gw_sales_mi-proyecto.xml` - Definición del script
- `customdeploy_gw_sales_mi-proyecto.xml` - Configuración de despliegue

---

## Estructura de Carpetas

### Nomenclatura de Scripts

Los scripts NetSuite siguen este formato:

```
[prefijo]_[tipo]_[nombre].ts
```

| Tipo | Código | Ejemplo |
|------|--------|---------|
| Client Script | cs | gw_cs_validacion.ts |
| User Event | ue | gw_ue_factura.ts |
| Suitelet | sl | gw_sl_facturas.ts |
| RESTlet | rl | gw_rl_pedidos.ts |
| Scheduled | sc | gw_sc_sincronizacion.ts |
| Map/Reduce | mr | gw_mr_importacion.ts |
| Portlet | pl | gw_pl_dashboard.ts |

---

## Comandos de Build

Una vez creado el proyecto, podés usar los siguientes comandos:

```bash
# Instalar dependencias
npm install
# o
yarn install

# Compilar TypeScript
npm run build
# Output: tsc && node scripts/prepend-headers.js && biome format

# Formatear código
npm run format

# Verificar código
npm run lint

# Desplegar a NetSuite
npm run deploy
```

---

## Solución de Problemas

Si tenés errores, consultá el archivo **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** que tiene las soluciones a los problemas más comunes.

### Problemas frecuentes:

1. **Biome no formatea los archivos**
   - Verificar que el patrón en biome.json sea correcto

2. **TypeScript no compila**
   - Verificar que `esModuleInterop` esté deshabilitado en tsconfig.json

3. **JSDoc no aparece en el .js**
   - Usar el script `prepend-headers.js` después de compilar

---

## Siguientes Pasos

1. **Leer la guía de arquitectura**: [ARCHITECTURE.md](ARCHITECTURE.md)
2. **Ver ejemplos de uso**: [EXAMPLES.md](EXAMPLES.md)
3. **Usar OrkidNS para validar código**: consultar [GUIA-ORKIDNS.md](GUIA-ORKIDNS.md)

---

## Créditos

Basado en el template: https://github.com/gildder/netsuite-ts-sdf-template

Documentación de Clean Architecture: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

---

¿Tenés preguntas? ¡Consultá el archivo TROUBLESHOOTING.md o creá un issue en el repositorio!