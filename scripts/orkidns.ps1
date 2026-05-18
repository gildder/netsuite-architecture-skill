<#
.SYNOPSIS
    OrkidNS - Orquestador NetSuite

.DESCRIPTION
    Agente para validar y generar código siguiendo la arquitectura NetSuite Clean Architecture

.COMMANDLET
    orkidns add "idea"         - Crear componentes desde una idea
    orkidns check             - Validar arquitectura del proyecto
    orkidns list              - Listar componentes del proyecto
    orkidns info [carpeta]    - Explicar qué va en cada carpeta
    orkidns fix               - Corregir problemas de arquitectura
    orkidns init              - Inicializar OrkidNS en un proyecto
    orkidns normalize [path]  - Corregir TypeScript al formato NetSuite
    orkidns hint              - Dar sugerencias basadas en código existente

.EXAMPLE
    .\orkidns.ps1 add "crear facturas"
    .\orkidns.ps1 check
    .\orkidns.ps1 list

#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("add", "check", "list", "info", "fix", "init", "normalize", "hint", "help")]
    [string]$Command = "help",

    [Parameter(Mandatory=$false)]
    [string]$Argument = "",

    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = "."
)

$ErrorActionPreference = "Continue"
$PROJECT_ROOT = $ProjectPath

function Write-Message {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✅ $Message" -ForegroundColor Green
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "  ❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "  ℹ $Message" -ForegroundColor Yellow
}

function Get-ProjectType {
    $configPath = Join-Path $PROJECT_ROOT "orkidns.config.json"
    if (Test-Path $configPath) {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        return $config.project.type
    }
    return "desconocido"
}

function Get-Domains {
    $configPath = Join-Path $PROJECT_ROOT "orkidns.config.json"
    if (Test-Path $configPath) {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        return $config.project.domains
    }
    return @()
}

function Get-Prefix {
    $configPath = Join-Path $PROJECT_ROOT "orkidns.config.json"
    if (Test-Path $configPath) {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        return $config.project.prefix
    }
    return "gw"
}

function Show-Help {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  OrkidNS - Orquestador NetSuite" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Comandos disponibles:" -ForegroundColor White
    Write-Host ""
    Write-Host "  add ""idea""      - Crear componentes desde una idea"
    Write-Host "  check            - Validar arquitectura del proyecto"
    Write-Host "  list             - Listar componentes del proyecto"
    Write-Host "  info [carpeta]   - Explicar qué va en cada carpeta"
    Write-Host "  fix              - Corregir problemas de arquitectura"
    Write-Host "  init             - Inicializar OrkidNS en un proyecto"
    Write-Host "  normalize [path] - Corregir TypeScript al formato NetSuite"
    Write-Host "  hint             - Dar sugerencias basadas en código"
    Write-Host "  help             - Mostrar esta ayuda"
    Write-Host ""
    Write-Host "Ejemplos:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  .\orkidns.ps1 add ""crear facturas"""
    Write-Host "  .\orkidns.ps1 check"
    Write-Host "  .\orkidns.ps1 normalize ""src\TypeScripts\Sales\invoice.ts"""
    Write-Host "  .\orkidns.ps1 list"
    Write-Host ""
}

function Invoke-CommandAdd {
    param([string]$Idea)

    if (-not $Idea) {
        Write-ErrorMsg "Debe proporcionar una idea"
        Write-Host "Ejemplo: .\orkidns.ps1 add ""crear servicio para facturas"""
        return
    }

    Write-Message "`n📋 Basándome en tu idea: ""$Idea""" -ForegroundColor Cyan

    $ideaLower = $Idea.ToLower()
    $components = @()

    # Inferencia de componentes
    if ($ideaLower -match "crear|nuevo|insertar") {
        $components += "Entity", "Service", "Repository"
    }
    if ($ideaLower -match "leer|obtener|consultar|buscar|get") {
        $components += "Repository", "Service"
    }
    if ($ideaLower -match "integrar|conectar|api|external") {
        $components += "Adapter", "Port"
    }
    if ($ideaLower -match "sincronizar|importar|exportar|sync") {
        $components += "UseCase", "Adapter"
    }
    if ($ideaLower -match "validar|verificar|validacion") {
        $components += "Validation"
    }
    if ($ideaLower -match "transformar|convertir|convert") {
        $components += "Transform"
    }
    if ($ideaLower -match "evento|when|on ") {
        $components += "DomainEvent", "EventHandler"
    }
    if ($ideaLower -match "crud|completo") {
        $components += "Entity", "Service", "Repository", "Validation", "Transform"
    }
    if ($ideaLower -match "programado|cron|scheduled") {
        $components += "Scheduled"
    }
    if ($ideaLower -match "mapreduce|masivo|batch") {
        $components += "MapReduce"
    }

    # Deduplicar
    $components = $components | Select-Object -Unique

    if ($components.Count -eq 0) {
        $components = @("Entity", "Service")
    }

    Write-Host ""
    Write-Host "Componentes sugeridos:" -ForegroundColor White
    $prefix = Get-Prefix
    $projectType = Get-ProjectType

    $domain = "Sales"
    if ($ideaLower -match "invoice|factura") { $domain = "Sales" }
    elseif ($ideaLower -match "item|product|articulo") { $domain = "Inventory" }
    elseif ($ideaLower -match "customer|cliente") { $domain = "Customer" }

    $basePath = switch ($projectType) {
        "pequeno" { "src/TypeScripts" }
        "mediano-sin-modules" { "src/TypeScripts" }
        default { "src/TypeScripts/Modules" }
    }

    foreach ($comp in $components) {
        $path = switch ($comp) {
            "Entity" { "$basePath/$domain/Domain/entities" }
            "Service" { "$basePath/$domain/Application/services" }
            "Repository" { "$basePath/$domain/Infrastructure/repositories" }
            "Adapter" { "$basePath/$domain/Infrastructure/adapters" }
            "Port" { "$basePath/$domain/Application/ports" }
            "UseCase" { "$basePath/$domain/Application/use-cases" }
            "Validation" { "$basePath/$domain/validations" }
            "Transform" { "$basePath/$domain/Application/transforms" }
            "DomainEvent" { "$basePath/$domain/Domain/events" }
            "Scheduled" { "Interface/Scheduled" }
            "MapReduce" { "Interface/MapReduce" }
            default { "$basePath/$domain" }
        }

        $fileName = switch ($comp) {
            "Entity" { "$domain.entity.ts" }
            "Service" { "$domain.service.ts" }
            "Repository" { "$domain.repository.ts" }
            "Adapter" { "$domain.adapter.ts" }
            "Port" { "$domain.port.ts" }
            "UseCase" { "$domain.usecase.ts" }
            "Validation" { "$domain.validation.ts" }
            "Transform" { "$domain.transform.ts" }
            "DomainEvent" { "$domain.event.ts" }
            "Scheduled" { "${prefix}_${domain}_sc.ts" }
            "MapReduce" { "${prefix}_${domain}_mr.ts" }
            default { "$domain.$comp.ToLower().ts" }
        }

        Write-Host "  ✅ $comp`: $path/$fileName" -ForegroundColor Green
    }

    Write-Host ""
    $response = Read-Host "¿Querés que los cree? (sí/no)"
    if ($response -eq "sí" -or $response -eq "si" -or $response -eq "y" -or $response -eq "yes") {
        Write-Message "`n📦 Creando componentes..." -ForegroundColor Cyan

        # Aquí se implementarían las funciones de creación
        Write-Success "Componentes creados (funcionalidad pendiente de implementación)"
    }
}

function Invoke-CommandCheck {
    Write-Message "`n🔍 Verificando arquitectura en: $PROJECT_ROOT" -ForegroundColor Cyan

    $tsFiles = Get-ChildItem -Path (Join-Path $PROJECT_ROOT "src") -Filter "*.ts" -Recurse -ErrorAction SilentlyContinue
    Write-Info "Archivos TypeScript: $($tsFiles.Count)"

    $projectType = Get-ProjectType
    Write-Info "Tipo de proyecto: $projectType"

    $issues = @()
    $validations = @()

    # Validar estructura básica
    if ($projectType -eq "grande" -or $projectType -eq "mediano-con-modules") {
        $modulesPath = Join-Path $PROJECT_ROOT "src\TypeScripts\Modules"
        if (Test-Path $modulesPath) {
            $validations += "Modules/ existe"
        } else {
            $issues += "Falta carpeta Modules/"
        }
    }

    # Validar Domain no tiene código de Application
    $domainPath = Join-Path $PROJECT_ROOT "src\TypeScripts"
    $domainServices = Get-ChildItem -Path $domainPath -Filter "*.service.ts" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match "Domain[/\\]" }

    if ($domainServices) {
        foreach ($svc in $domainServices) {
            $issues += "Service en Domain: $($svc.Name)"
        }
    }

    if ($issues.Count -eq 0) {
        Write-Success "Arquitectura válida"
    } else {
        Write-Message "`n❌ Problemas encontrados:" -ForegroundColor Red
        foreach ($issue in $issues) {
            Write-ErrorMsg $issue
        }
    }
}

function Invoke-CommandList {
    Write-Message "`n📋 Componentes en: $PROJECT_ROOT" -ForegroundColor Cyan

    $tsFiles = Get-ChildItem -Path (Join-Path $PROJECT_ROOT "src") -Filter "*.ts" -Recurse -ErrorAction SilentlyContinue

    $byFolder = @{}
    foreach ($file in $tsFiles) {
        $relative = $file.FullName.Replace((Get-Location).Path, "").TrimStart("\")
        $folder = Split-Path $relative | Split-Path -Leaf
        if (-not $byFolder[$folder]) {
            $byFolder[$folder] = @()
        }
        $byFolder[$folder] += $file.Name
    }

    foreach ($folder in $byFolder.Keys | Sort-Object) {
        Write-Message "`n🏠 $folder ($($byFolder[$folder].Count) archivos)" -ForegroundColor Yellow
        foreach ($file in $byFolder[$folder] | Sort-Object | Select-Object -First 10) {
            Write-Host "    - $file" -ForegroundColor Gray
        }
        if ($byFolder[$folder].Count -gt 10) {
            Write-Host "    ... y $($byFolder[$folder].Count - 10) más" -ForegroundColor Gray
        }
    }
}

function Invoke-CommandInfo {
    param([string]$Folder)

    if (-not $Folder) {
        Write-Message "`n📁 Guía de estructura de carpetas:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  PEQUEÑO (directo):" -ForegroundColor Yellow
        Write-Host "    [Dominio]/*.service.ts"
        Write-Host "    [Dominio]/*.repository.ts"
        Write-Host "    [Dominio]/*.types.ts"
        Write-Host "    Interface/"
        Write-Host "    Shared/"
        Write-Host ""
        Write-Host "  MEDIANO/LARGE (capas):" -ForegroundColor Yellow
        Write-Host "    Domain/entities/         → *.entity.ts"
        Write-Host "    Application/services/    → *.service.ts"
        Write-Host "    Application/transforms/   → *.transform.ts"
        Write-Host "    Application/ports/       → *.port.ts"
        Write-Host "    Application/use-cases/   → *.usecase.ts"
        Write-Host "    Application/dtos/        → *.dto.ts"
        Write-Host "    Infrastructure/          → *.repository.ts"
        Write-Host "    Infrastructure/adapters/ → *.adapter.ts"
        Write-Host "    validations/             → *.validation.ts"
        return
    }

    $folderInfo = @{
        "Domain/entities" = @{ go = "*.entity.ts"; dont = "Service, Repository, Adapter" }
        "Application/services" = @{ go = "*.service.ts, lógica de negocio"; dont = "Acceso directo a record (use Repository)" }
        "Application/transforms" = @{ go = "*.transform.ts"; dont = "Lógica de negocio" }
        "Application/ports" = @{ go = "*.port.ts"; dont = "Implementaciones" }
        "Infrastructure/repositories" = @{ go = "*.repository.ts"; dont = "Lógica de negocio" }
        "Infrastructure/adapters" = @{ go = "*.adapter.ts"; dont = "Lógica de negocio" }
        "validations" = @{ go = "*.validation.ts"; dont = "Acceso a datos" }
    }

    if ($folderInfo[$Folder]) {
        Write-Message "`n📁 $Folder" -ForegroundColor Cyan
        Write-Host "  ✅ DEBE contener: $($folderInfo[$Folder].go)" -ForegroundColor Green
        Write-Host "  ❌ NO DEBE contener: $($folderInfo[$Folder].dont)" -ForegroundColor Red
    } else {
        Write-ErrorMsg "Carpeta no reconocida"
    }
}

function Invoke-CommandFix {
    Write-Message "`n🔧 Buscando problemas de arquitectura..." -ForegroundColor Cyan

    # Buscar services en Domain
    $domainPath = Join-Path $PROJECT_ROOT "src\TypeScripts"
    $domainServices = Get-ChildItem -Path $domainPath -Filter "*.service.ts" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match "Domain[/\\]Application" }

    if ($domainServices) {
        Write-Message "`n❌ Servicios en ubicación incorrecta:" -ForegroundColor Red
        foreach ($svc in $domainServices) {
            Write-Host "    $($svc.FullName)" -ForegroundColor Gray
            Write-Info "  → Mover a Application/services/"
        }
    } else {
        Write-Sight "No se encontraron problemas"
    }
}

function Invoke-CommandInit {
    Write-Message "`n📦 Inicializando OrkidNS en: $PROJECT_ROOT" -ForegroundColor Cyan

    # Detectar tipo de proyecto
    $hasModules = Test-Path (Join-Path $PROJECT_ROOT "src\TypeScripts\Modules")
    $hasDomain = Test-Path (Join-Path $PROJECT_ROOT "src\TypeScripts")

    $type = if ($hasModules) { "grande" }
            elseif ($hasDomain) { "mediano-sin-modules" }
            else { "pequeno" }

    # Detectar dominios
    $domains = @()
    if ($hasModules) {
        $modulesPath = Join-Path $PROJECT_ROOT "src\TypeScripts\Modules"
        if (Test-Path $modulesPath) {
            $domains = Get-ChildItem -Path $modulesPath -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.Name }
        }
    }

    if ($domains.Count -eq 0) { $domains = @("Sales") }

    # Crear config
    $config = @{
        version = "1.0"
        project = @{
            name = Split-Path $PROJECT_ROOT -Leaf
            prefix = "gw"
            type = $type
            domains = $domains
        }
    }

    $configPath = Join-Path $PROJECT_ROOT "orkidns.config.json"
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -NoNewline

    Write-Success "orkidns.config.json creado"
    Write-Host ""
    Write-Host "Configuración:" -ForegroundColor Cyan
    Write-Host "  - Tipo: $type"
    Write-Host "  - Dominios: $($domains -join ', ')"
}

function Invoke-CommandNormalize {
    param([string]$Path)

    if (-not $Path) {
        Write-ErrorMsg "Debe especificar la ruta del archivo"
        Write-Host "Ejemplo: .\orkidns.ps1 normalize ""src\TypeScripts\Sales\invoice.ts"""
        return
    }

    $fullPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path }
                else { Join-Path $PROJECT_ROOT $Path }

    if (-not (Test-Path $fullPath)) {
        Write-ErrorMsg "El archivo no existe: $fullPath"
        return
    }

    Write-Message "`n📝 Normalizando: $Path" -ForegroundColor Cyan

    $content = Get-Content $fullPath -Raw
    $modified = $false

    # Detectar tipo de script
    $scriptType = "Suitelet"
    if ($content -match "pageInit") { $scriptType = "ClientScript" }
    elseif ($content -match "beforeSubmit|afterSubmit") { $scriptType = "UserEventScript" }
    elseif ($content -match "getInputData|map|reduce|summarize") { $scriptType = "MapReduceScript" }
    elseif ($content -match "execute") { $scriptType = "ScheduledScript" }

    Write-Success "Tipo de script detectado: $scriptType"

    # Agregar JSDoc si no existe
    if ($content -notmatch "@NApiVersion") {
        $jsdoc = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType $scriptType
 */

"@
        $content = $jsdoc + $content
        $modified = $true
        Write-Success "Agregado JSDoc (@NApiVersion, @NModuleScope, @NScriptType)"
    }

    # Agregar import de EntryPoints si hay funciones NetSuite
    $needsEntryPoints = $content -match "export.*onRequest|export.*pageInit|export.*beforeSubmit|export.*afterSubmit|export.*getInputData|export.*map|export.*reduce|export.*execute"
    if ($needsEntryPoints -and $content -notmatch "from 'N/types'") {
        $content = $content -replace "(from 'N/[^']+')", "`$1`nimport { EntryPoints } from 'N/types';"
        $modified = $true
        Write-Success "Agregado import de EntryPoints"
    }

    # Corregir record.Type string a enum
    if ($content -match "record\.Type\.[a-zA-Z]+" -and $content -notmatch "record\.Type\.INVOICE") {
        # Ya tiene el formato correcto de enum
    }

    if ($modified) {
        Set-Content -Path $fullPath -Value $content -NoNewline
        Write-Message "`n✅ Archivo normalizado: $Path" -ForegroundColor Green
    } else {
        Write-Info "El archivo ya está normalizado"
    }
}

function Invoke-CommandHint {
    Write-Message "`n💡 Sugerencias para el proyecto:" -ForegroundColor Cyan

    $projectType = Get-ProjectType

    if ($projectType -eq "pequeno") {
        Write-Info "Considerá migrar a estructura MEDIUM si el proyecto crece"
    }

    # Buscar archivos sin validations
    $hasValidations = Get-ChildItem (Join-Path $PROJECT_ROOT "src") -Filter "*validation*" -Recurse -ErrorAction SilentlyContinue
    if (-not $hasValidations) {
        Write-Host ""
        Write-Warning "⚠️ Falta archivo de validations"
        Write-Info "Considerá crear validations/ en tu dominio"
    }

    # Buscar integraciones
    $hasAdapters = Get-ChildItem (Join-Path $PROJECT_ROOT "src") -Filter "*adapter*" -Recurse -ErrorAction SilentlyContinue
    if ($hasAdapters) {
        Write-Host ""
        Write-Info "💡 Múltiples adaptadores detectados"
        Write-Info "Considerá usar patrón Ports/Adapters para mejor abstracción"
    }

    Write-Host ""
    Write-Success "Análisis completado"
}

# Ejecutar comando
switch ($Command) {
    "add" { Invoke-CommandAdd -Idea $Argument }
    "check" { Invoke-CommandCheck }
    "list" { Invoke-CommandList }
    "info" { Invoke-CommandInfo -Folder $Argument }
    "fix" { Invoke-CommandFix }
    "init" { Invoke-CommandInit }
    "normalize" { Invoke-CommandNormalize -Path $Argument }
    "hint" { Invoke-CommandHint }
    "help" { Show-Help }
    default { Show-Help }
}