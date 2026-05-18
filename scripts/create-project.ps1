<#
.SYNOPSIS
    Script para crear proyecto NetSuite completo desde template

.DESCRIPTION
    Crea un proyecto NetSuite con TypeScript y Clean Architecture
    clonando un template y configurando automáticamente

.PARAMETER Ruta
    Ruta donde se creará el proyecto

.PARAMETER Nombre
    Nombre del proyecto

.PARAMETER Dominio
    Dominio principal (Sales, Inventory, etc.)

.PARAMETER Tipo
    Tipo de proyecto: pequeno, mediano-sin-modules, mediano-con-modules, grande

.PARAMETER Prefijo
    Prefijo para los scripts (ej: gw, acme)

.EXAMPLE
    .\create-project.ps1 -Ruta "C:\proyectos\mi-proyecto" -Nombre "mi-proyecto" -Dominio "Sales" -Tipo "pequeno" -Prefijo "gw"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Ruta,

    [Parameter(Mandatory=$true)]
    [string]$Nombre,

    [Parameter(Mandatory=$true)]
    [string]$Dominio,

    [Parameter(Mandatory=$true)]
    [ValidateSet("pequeno", "mediano-sin-modules", "mediano-con-modules", "grande")]
    [string]$Tipo,

    [Parameter(Mandatory=$false)]
    [string]$Prefijo = "gw"
)

$ErrorActionPreference = "Stop"

$TEMPLATE_REPO = "https://github.com/gildder/netsuite-ts-sdf-template.git"
$SKILL_PATH = Split-Path -Parent $PSScriptRoot
$PROJECT_NAME_UPPER = $Nombre.ToUpper() -replace '-', '_'

function Write-Step {
    param([string]$Message)
    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  ℹ $Message" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Magenta
Write-Host "  Creando proyecto NetSuite: $Nombre" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Magenta
Write-Host "  Dominio: $Dominio"
Write-Host "  Tipo: $Tipo"
Write-Host "  Prefijo: $Prefijo"
Write-Host "  Ruta: $Ruta"
Write-Host "==========================================" -ForegroundColor Magenta
Write-Host ""

# 1. Clonar repositorio template
Write-Step "1. Clonando repositorio template..."

if (Test-Path $Ruta) {
    Write-Info "La carpeta ya existe. Limpiando..."
    Remove-Item -Path $Ruta -Recurse -Force
}

$null = New-Item -ItemType Directory -Path $Ruta -Force
Set-Location $Ruta

git clone $TEMPLATE_REPO .
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error al clonar el repositorio template"
    exit 1
}
Write-Success "Template clonado en $Ruta"

# 2. Eliminar archivos de ejemplo
Write-Step "2. Limpiando archivos de ejemplo del template..."

$exampleFiles = Get-ChildItem -Path "$Ruta\src\TypeScripts" -Filter "*.ts" -Recurse -ErrorAction SilentlyContinue
foreach ($file in $exampleFiles) {
    Remove-Item -Path $file.FullName -Force
}

$exampleObjects = Get-ChildItem -Path "$Ruta\src\Objects" -Filter "*hello_world*" -Recurse -ErrorAction SilentlyContinue
foreach ($obj in $exampleObjects) {
    Remove-Item -Path $obj.FullName -Force
}

Write-Success "Archivos de ejemplo eliminados"

# 3. Actualizar package.json
Write-Step "3. Actualizando package.json..."

$packageJsonPath = Join-Path $Ruta "package.json"
$packageJson = Get-Content $packageJsonPath -Raw | ConvertFrom-Json
$packageJson.name = $Nombre
$packageJson.displayName = "NetSuite $Dominio Project"
$packageJson.description = "NetSuite TypeScript project for $Dominio - $Tipo"
$packageJson | ConvertTo-Json -Depth 10 | Set-Content $packageJsonPath -NoNewline

Write-Success "package.json actualizado"

# 4. Actualizar tsconfig.json
Write-Step "4. Actualizando tsconfig.json..."

$tsconfigPath = Join-Path $Ruta "tsconfig.json"
$tsconfigContent = Get-Content $tsconfigPath -Raw

# Actualizar paths
$tsconfigContent = $tsconfigContent -replace 'idev-engineering-netsuite', $Nombre
# Eliminar esModuleInterop (contamina output AMD)
$tsconfigContent = $tsconfigContent -replace '"esModuleInterop": true,?', ''
# Quitar coma extra si queda
$tsconfigContent = $tsconfigContent -replace ',,', ','

Set-Content -Path $tsconfigPath -Value $tsconfigContent -NoNewline
Write-Success "tsconfig.json actualizado (sin esModuleInterop)"

# 5. Actualizar biome.json
Write-Step "5. Corrigiendo biome.json..."

$biomePath = Join-Path $Ruta "biome.json"
$biomeJson = Get-Content $biomePath -Raw | ConvertFrom-Json

# Agregar archivos JS compilados al include
if ($biomeJson.files.include -is [array]) {
    $biomeJson.files.include += "src/FileCabinet/SuiteScripts/$Nombre/*.js"
} else {
    $biomeJson.files.include = @("**/*.ts", "**/*.json", "src/FileCabinet/SuiteScripts/$Nombre/*.js")
}

# Agregar overrides para JS compilados
$biomeJson.overrides = @(
    @{
        include = @("src/FileCabinet/**")
        linter = @{ enabled = $false }
        organizeImports = @{ enabled = $false }
    }
)

$biomeJson | ConvertTo-Json -Depth 10 | Set-Content $biomePath -NoNewline
Write-Success "biome.json corregido (include + overrides)"

# 6. Copiar scripts de normalización
Write-Step "6. Copiando scripts de normalización..."

$scriptsDest = Join-Path $Ruta "scripts"
if (-not (Test-Path $scriptsDest)) {
    $null = New-Item -ItemType Directory -Path $scriptsDest -Force
}

$prependHeadersSrc = Join-Path $SKILL_PATH "scripts\prepend-headers.js"
if (Test-Path $prependHeadersSrc) {
    Copy-Item -Path $prependHeadersSrc -Destination (Join-Path $scriptsDest "prepend-headers.js") -Force
    Write-Success "Script prepend-headers.js copiado"
}

$normalizeScriptSrc = Join-Path $SKILL_PATH "scripts\normalize-ts.ps1"
if (Test-Path $normalizeScriptSrc) {
    Copy-Item -Path $normalizeScriptSrc -Destination (Join-Path $scriptsDest "normalize-ts.ps1") -Force
    Write-Success "Script normalize-ts.ps1 copiado"
}

# 7. Actualizar package.json build
Write-Step "7. Actualizando package.json (build completo)..."

$packageJson = Get-Content $packageJsonPath -Raw | ConvertFrom-Json

# Agregar scripts de build
$packageJson.scripts | Add-Member -NotePropertyName "build" -NotePropertyValue "tsc && node scripts/prepend-headers.js && biome format --write src/FileCabinet/SuiteScripts/$Nombre" -Force
$packageJson.scripts | Add-Member -NotePropertyName "format" -NotePropertyValue "biome format --write src/FileCabinet/SuiteScripts/$Nombre" -Force
$packageJson.scripts | Add-Member -NotePropertyName "lint" -NotePropertyValue "biome check src/TypeScripts/$Nombre" -Force
$packageJson.scripts | Add-Member -NotePropertyName "lint:fix" -NotePropertyValue "biome check --write src/TypeScripts/$Nombre" -Force

$packageJson | ConvertTo-Json -Depth 10 | Set-Content $packageJsonPath -NoNewline
Write-Success "package.json actualizado (build, format, lint)"

# 8. Actualizar deploy.xml
Write-Step "8. Actualizando deploy.xml..."

$deployPath = Join-Path $Ruta "src\deploy.xml"
$deployContent = Get-Content $deployPath -Raw
$deployContent = $deployContent -replace 'idev-engineering-netsuite', $Nombre
Set-Content -Path $deployPath -Value $deployContent -NoNewline
Write-Success "deploy.xml actualizado"

# 9. Actualizar manifest.xml
Write-Step "9. Actualizando manifest.xml..."

$manifestPath = Join-Path $Ruta "src\manifest.xml"
$manifestContent = Get-Content $manifestPath -Raw
$manifestContent = $manifestContent -replace '<projectname>.*</projectname>', "<projectname>${PROJECT_NAME_UPPER}_Project</projectname>"
Set-Content -Path $manifestPath -Value $manifestContent -NoNewline
Write-Success "manifest.xml actualizado"

# 10. Crear estructura TypeScripts según tipo
Write-Step "10. Creando estructura TypeScripts..."

$tsRoot = Join-Path $Ruta "src\TypeScripts\$Nombre"

switch ($Tipo) {
    "pequeno" {
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot $Dominio) -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Interface") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Shared\utils") -Force
    }
    "mediano-sin-modules" {
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "$Dominio\Domain\entities") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "$Dominio\Application\services") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "$Dominio\Application\transforms") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "$Dominio\Infrastructure\repositories") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "$Dominio\validations") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Interface\Restlets") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Shared\utils") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Shared\constants") -Force
    }
    { $_ -in @("mediano-con-modules", "grande") } {
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Modules\$Dominio\Domain\entities") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Modules\$Dominio\Domain\value-objects") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Modules\$Dominio\Domain\events") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Modules\$Dominio\Domain\services") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Modules\$Dominio\Application\use-cases") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Modules\$Dominio\Application\ports\inbound") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Modules\$Dominio\Application\ports\outbound") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Modules\$Dominio\Application\dtos") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Modules\$Dominio\Application\services") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Modules\$Dominio\Application\transforms") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Modules\$Dominio\Infrastructure\persistence") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Modules\$Dominio\Infrastructure\adapters") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Modules\$Dominio\validations") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Interface\Restlets") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Interface\Suitelets") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Interface\UserEvents") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Shared\domain") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Shared\utils") -Force
        $null = New-Item -ItemType Directory -Path (Join-Path $tsRoot "Shared\constants") -Force
    }
}

Write-Success "Estructura creada: $Tipo"

# 11. Crear archivos base según tipo
Write-Step "11. Creando archivos base..."

$typesTemplate = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export interface ${Dominio}Input {
  id?: number;
  name: string;
}

export interface ${Dominio}Output {
  id: number;
  name: string;
}
"@

$serviceTemplate = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import record from 'N/record';

export class ${Dominio}Service {
  create(data: ${Dominio}Input): number {
    const rec = record.create({ type: record.Type.INVOICE });
    rec.setValue({ fieldId: 'entity', value: data.name });
    return rec.save();
  }

  read(id: number): ${Dominio}Output | null {
    try {
      const rec = record.load({ type: record.Type.INVOICE, id });
      return { id: rec.id, name: rec.getValue({ fieldId: 'entity' }) as string };
    } catch {
      return null;
    }
  }
}
"@

$entityTemplate = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export class ${Dominio}Entity {
  private data: ${Dominio}Data;

  constructor(data: ${Dominio}Data) {
    this.data = data;
  }

  canBeCreated(): boolean {
    return !!this.data.name;
  }

  validate(): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    if (!this.data.name) errors.push('name es requerido');
    return { valid: errors.length === 0, errors };
  }

  static create(data: ${Dominio}Data): { success: boolean; entity?: ${Dominio}Entity; error?: string } {
    const entity = new ${Dominio}Entity(data);
    const validation = entity.validate();
    if (!validation.valid) return { success: false, error: validation.errors.join(', ') };
    return { success: true, entity };
  }
}

interface ${Dominio}Data {
  name: string;
  id?: number;
}
"@

switch ($Tipo) {
    "pequeno" {
        Set-Content -Path (Join-Path $tsRoot "$Dominio\$Dominio.types.ts") -Value $typesTemplate -NoNewline
        Set-Content -Path (Join-Path $tsRoot "$Dominio\$Dominio.service.ts") -Value $serviceTemplate -NoNewline
    }
    { $_ -in @("mediano-sin-modules", "mediano-con-modules") } {
        $domainPath = if ($Tipo -eq "mediano-sin-modules") { Join-Path $tsRoot "$Dominio\Domain\entities" } else { Join-Path $tsRoot "Modules\$Dominio\Domain\entities" }
        Set-Content -Path (Join-Path $domainPath "$Dominio.entity.ts") -Value $entityTemplate -NoNewline
    }
    "grande" {
        Set-Content -Path (Join-Path $tsRoot "Modules\$Dominio\Domain\entities\$Dominio.entity.ts") -Value $entityTemplate -NoNewline

        # Grande tiene Ports adicionales
        $portsTemplate = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export interface ${Dominio}InputPort {
  create(input: ${Dominio}InputDTO): Promise<{ success: boolean; id?: number; error?: string }>;
  read(id: number): Promise<${Dominio}OutputDTO | null>;
}

export interface ${Dominio}InputDTO { name: string; status?: string; }
export interface ${Dominio}OutputDTO { id: number; name: string; status?: string; }
"@
        Set-Content -Path (Join-Path $tsRoot "Modules\$Dominio\Application\ports\inbound\$Dominio.input.port.ts") -Value $portsTemplate -NoNewline
    }
}

Write-Success "Archivos base creados"

# 12. Crear archivo de configuración OrkidNS
Write-Step "12. Creando configuración de OrkidNS..."

$orkidnsConfig = @"
{
  "version": "1.0",
  "project": {
    "name": "$Nombre",
    "prefix": "$Prefijo",
    "type": "$Tipo",
    "domains": ["$Dominio"]
  }
}
"@

Set-Content -Path (Join-Path $Ruta "orkidns.config.json") -Value $orkidnsConfig -NoNewline
Write-Success "orkidns.config.json creado"

# Resumen final
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  ✅ Proyecto $Nombre creado exitosamente!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Cyan
Write-Host "  1. cd $Ruta"
Write-Host "  2. yarn install  (o npm install)"
Write-Host "  3. yarn setup   (para conectar tu cuenta NetSuite)"
Write-Host "  4. yarn build   (para compilar TypeScript)"
Write-Host "  5. yarn deploy  (para desplegar a NetSuite)"
Write-Host ""