# OrkidNS - Handler de comandos para el agente
# Este script es invocado por el agente OrkidNS para ejecutar comandos

param(
    [Parameter(Mandatory=$true)]
    [string]$Comando,
    [string]$Arg1 = "",
    [string]$Arg2 = "",
    [string]$ProyectoPath = "."
)

$SkillPath = "C:\Users\gguerrero\Documents\000 desarrollo\netsuite-architecture-skill"

switch ($Comando.ToLower()) {
    "normalize" {
        if (-not $Arg1) {
            Write-Host "Usage: orkidns normalize <archivo.ts>" -ForegroundColor Red
            exit 1
        }

        $Archivo = $Arg1
        if (-not (Test-Path $Archivo)) {
            Write-Host "❌ Archivo no encontrado: $Archivo" -ForegroundColor Red
            exit 1
        }

        Write-Host "📝 Normalizando: $Archivo" -ForegroundColor Cyan

        $Contenido = Get-Content $Archivo -Raw

        # Detectar tipo de script
        $ScriptType = "Suitelet"
        if ($Contenido -match "pageInit") { $ScriptType = "ClientScript" }
        elseif ($Contenido -match "beforeSubmit|afterSubmit") { $ScriptType = "UserEventScript" }
        elseif ($Contenido -match "getInputData|map|reduce|summarize") { $ScriptType = "MapReduceScript" }
        elseif ($Contenido -match "execute") { $ScriptType = "ScheduledScript" }

        Write-Host "  ✅ Tipo detectado: $ScriptType" -ForegroundColor Green

        # Agregar JSDoc si falta
        if ($Contenido -notmatch "@NApiVersion") {
            $JSDoc = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType $ScriptType
 */

"@
            $Contenido = $JSDoc + $Contenido
            Write-Host "  ✅ JSDoc agregado" -ForegroundColor Green
        }

        # Agregar EntryPoints import si es necesario
        if ($Contenido -match "export.*onRequest|export.*pageInit|export.*beforeSubmit") {
            if ($Contenido -notmatch "from 'N/types'") {
                $Contenido = $Contenido -replace "(from 'N/[^']+')", "`$1`nimport { EntryPoints } from 'N/types';"
                Write-Host "  ✅ EntryPoints import agregado" -ForegroundColor Green
            }
        }

        Set-Content -Path $Archivo -Value $Contenido -NoNewline
        Write-Host "✅ Archivo normalizado: $Archivo" -ForegroundColor Green
    }

    "init" {
        Write-Host "📦 Inicializando OrkidNS en: $ProyectoPath" -ForegroundColor Cyan

        $configPath = Join-Path $ProyectoPath "orkidns.config.json"
        $config = @{
            version = "1.0"
            project = @{
                name = Split-Path $ProyectoPath -Leaf
                prefix = "gw"
                type = "mediano-con-modules"
                domains = @()
            }
        } | ConvertTo-Json -Depth 3

        Set-Content -Path $configPath -Value $config
        Write-Host "✅ orkidns.config.json creado" -ForegroundColor Green
    }

    "check" {
        Write-Host "🔍 Verificando arquitectura en: $ProyectoPath" -ForegroundColor Cyan

        # Buscar archivos TypeScripts
        $tsFiles = Get-ChildItem -Path (Join-Path $ProyectoPath "src") -Recurse -Filter "*.ts" -ErrorAction SilentlyContinue

        Write-Host "  📊 Archivos TypeScript encontrados: $($tsFiles.Count)" -ForegroundColor Yellow

        # Verificar estructura
        $estructuraOk = $true
        foreach ($file in $tsFiles) {
            $relPath = $file.FullName.Replace($ProyectoPath, "")

            if ($relPath -match "Modules/.*Domain/entities" -and $file.Name -notmatch "\.entity\.ts$") {
                Write-Host "  ⚠️ $($file.Name) debería terminar en .entity.ts" -ForegroundColor Yellow
                $estructuraOk = $false
            }
        }

        if ($estructuraOk) {
            Write-Host "✅ Arquitectura válida" -ForegroundColor Green
        } else {
            Write-Host "❌ Hay problemas de arquitectura" -ForegroundColor Red
        }
    }

    "list" {
        Write-Host "📋 Listando componentes en: $ProyectoPath" -ForegroundColor Cyan

        $tsFiles = Get-ChildItem -Path (Join-Path $ProyectoPath "src") -Recurse -Filter "*.ts" -ErrorAction SilentlyContinue

        $dominios = @{}
        foreach ($file in $tsFiles) {
            if ($file.Name -match "^(?<dominio>\w+)\.") {
                $dominio = $Matches.dominio
                if (-not $dominios[$dominio]) { $dominios[$dominio] = @() }
                $dominios[$dominio] += $file.Name
            }
        }

        foreach ($dominio in $dominios.Keys) {
            Write-Host "`n🏠 Dominio: $dominio" -ForegroundColor Cyan
            foreach ($file in $dominios[$dominio]) {
                Write-Host "   - $file" -ForegroundColor Gray
            }
        }
    }

    "info" {
        if (-not $Arg1) {
            Write-Host "Usage: orkidns info <carpeta>" -ForegroundColor Red
            exit 1
        }

        Write-Host "📁 Estructura de: $Arg1" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Domain/entities/     → Solo *.entity.ts" -ForegroundColor Gray
        Write-Host "  Application/        → services, transforms, use-cases, ports, dtos" -ForegroundColor Gray
        Write-Host "  Infrastructure/      → persistence, adapters" -ForegroundColor Gray
        Write-Host "  validations/        → Solo validations" -ForegroundColor Gray
    }

    default {
        Write-Host "❌ Comando desconocido: $Comando" -ForegroundColor Red
        Write-Host "Comandos disponibles: normalize, init, check, list, info" -ForegroundColor Yellow
    }
}