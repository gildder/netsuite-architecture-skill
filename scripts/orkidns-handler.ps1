# OrkidNS - Handler de comandos para el agente
# Soporta normalizacion por archivo y por carpeta

param(
    [Parameter(Mandatory=$true)]
    [string]$Comando,
    [string]$Arg1 = "",
    [string]$Arg2 = "",
    [string]$ProyectoPath = "."
)

$SkillPath = "C:\Users\gguerrero\Documents\000 desarrollo\netsuite-architecture-skill"

function Normalizar-Archivo {
    param([string]$Archivo)
    
    if (-not (Test-Path $Archivo)) {
        Write-Host "  ❌ No encontrado: $Archivo" -ForegroundColor Red
        return $false
    }

    Write-Host "  📝 Normalizando: $Archivo" -ForegroundColor Cyan

    $Contenido = Get-Content $Archivo -Raw
    $cambios = 0

    # Detectar tipo de script
    $ScriptType = "Suitelet"
    if ($Contenido -match "pageInit") { $ScriptType = "ClientScript" }
    elseif ($Contenido -match "beforeSubmit|afterSubmit") { $ScriptType = "UserEventScript" }
    elseif ($Contenido -match "getInputData|map|reduce|summarize") { $ScriptType = "MapReduceScript" }
    elseif ($Contenido -match "execute") { $ScriptType = "ScheduledScript" }

    Write-Host "    ✅ Tipo: $ScriptType" -ForegroundColor Green

    # 1. Agregar JSDoc si falta
    if ($Contenido -notmatch "@NApiVersion") {
        $JSDoc = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType $ScriptType
 */

"@
        $Contenido = $JSDoc + $Contenido
        Write-Host "    ✅ + JSDoc" -ForegroundColor Green
        $cambios++
    }

    # 2. Agregar EntryPoints import si es necesario
    if ($Contenido -match "export.*onRequest|export.*pageInit|export.*beforeSubmit|export.*afterSubmit|export let") {
        if ($Contenido -notmatch "from 'N/types'") {
            $Contenido = $Contenido -replace "(from 'N/[^']+')", "`$1`nimport { EntryPoints } from 'N/types';"
            Write-Host "    ✅ + EntryPoints" -ForegroundColor Green
            $cambios++
        }
    }

    # 3. Corregir record.Type string a enum
    if ($Contenido -match "type:\s*'invoice'") {
        $Contenido = $Contenido -replace "type:\s*'invoice'", "type: record.Type.INVOICE"
        Write-Host "    ✅ record.Type.INVOICE" -ForegroundColor Green
        $cambios++
    }

    # 4. Agregar @NModuleScope si falta
    if ($Contenido -notmatch "@NModuleScope") {
        $Contenido = $Contenido -replace "(@NApiVersion 2\.1)", "`$1`n * @NModuleScope Public"
        Write-Host "    ✅ + @NModuleScope" -ForegroundColor Green
        $cambios++
    }

    # Guardar cambios
    if ($cambios -gt 0) {
        Set-Content -Path $Archivo -Value $Contenido -NoNewline
        Write-Host "    ✅ Normalizado ($cambios cambios)" -ForegroundColor Green
        return $true
    } else {
        Write-Host "    ✅ Ya está normalizado" -ForegroundColor Gray
        return $false
    }
}

function Normalizar-Carpeta {
    param([string]$Carpeta)
    
    if (-not (Test-Path $Carpeta)) {
        Write-Host "❌ Carpeta no encontrada: $Carpeta" -ForegroundColor Red
        return
    }

    $archivos = Get-ChildItem -Path $Carpeta -Recurse -Filter "*.ts" | Where-Object { $_.Name -notmatch "\.d\.ts$" }
    $total = $archivos.Count
    $procesados = 0
    $modificados = 0

    Write-Host "📁 Normalizando carpeta: $Carpeta" -ForegroundColor Cyan
    Write-Host "   Archivos TypeScript: $total" -ForegroundColor Yellow
    Write-Host ""

    foreach ($archivo in $archivos) {
        Write-Host "[$($archivos.IndexOf($archivo) + 1)/$total] $($archivo.Name)" -ForegroundColor Gray
        if (Normalizar-Archivo -Archivo $archivo.FullName) {
            $modificados++
        }
        $procesados++
    }

    Write-Host ""
    Write-Host "✅ Resumen:" -ForegroundColor Cyan
    Write-Host "   Procesados: $procesados" -ForegroundColor Gray
    Write-Host "   Modificados: $modificados" -ForegroundColor Yellow
}

switch ($Comando.ToLower()) {
    
    "normalize" {
        if (-not $Arg1) {
            Write-Host "Usage: orkidns normalize <archivo.ts | carpeta/>" -ForegroundColor Red
            Write-Host "Examples:" -ForegroundColor Yellow
            Write-Host "  orkidns normalize src/TypeScripts/Sales/invoice.ts" -ForegroundColor Gray
            Write-Host "  orkidns normalize src/TypeScripts/Sales/" -ForegroundColor Gray
            Write-Host "  orkidns normalize src/TypeScripts/" -ForegroundColor Gray
            exit 1
        }

        # Determinar si es archivo o carpeta
        if (Test-Path $Arg1) {
            if (Test-Path $Arg1 -PathType Leaf) {
                # Es un archivo
                Normalizar-Archivo -Archivo $Arg1
            } else {
                # Es una carpeta
                Normalizar-Carpeta -Carpeta $Arg1
            }
        } else {
            Write-Host "❌ No encontrado: $Arg1" -ForegroundColor Red
            exit 1
        }
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

        $srcPath = Join-Path $ProyectoPath "src"
        if (-not (Test-Path $srcPath)) {
            Write-Host "❌ No se encontró carpeta src" -ForegroundColor Red
            exit 1
        }

        $tsFiles = Get-ChildItem -Path $srcPath -Recurse -Filter "*.ts" -ErrorAction SilentlyContinue

        Write-Host "  📊 Archivos TypeScript: $($tsFiles.Count)" -ForegroundColor Yellow

        $problemas = @()

        foreach ($file in $tsFiles) {
            $relPath = $file.FullName.Replace($srcPath, "")

            # Verificar entidades
            if ($relPath -match "Domain/entities" -and $file.Name -notmatch "\.entity\.ts$") {
                $problemas += "Entidad sin sufijo .entity: $($file.Name)"
            }

            # Verificar servicios en Domain (no debería estar)
            if ($relPath -match "Domain/.*\.service\.ts$") {
                $problemas += "Service en Domain: $($file.Name)"
            }

            # Verificar adapters en Application (no debería estar)
            if ($relPath -match "Application/.*\.adapter\.ts$") {
                $problemas += "Adapter en Application: $($file.Name)"
            }
        }

        if ($problemas.Count -eq 0) {
            Write-Host "✅ Arquitectura válida" -ForegroundColor Green
        } else {
            Write-Host "❌ Problemas encontrados:" -ForegroundColor Red
            foreach ($p in $problemas) {
                Write-Host "   - $p" -ForegroundColor Yellow
            }
        }
    }

    "list" {
        Write-Host "📋 Componentes en: $ProyectoPath" -ForegroundColor Cyan

        $srcPath = Join-Path $ProyectoPath "src"
        if (-not (Test-Path $srcPath)) {
            Write-Host "❌ No se encontró carpeta src" -ForegroundColor Red
            exit 1
        }

        $tsFiles = Get-ChildItem -Path $srcPath -Recurse -Filter "*.ts" -ErrorAction SilentlyContinue

        $dominios = @{}
        foreach ($file in $tsFiles) {
            if ($file.Name -match "^(?<dominio>\w+)\.") {
                $dominio = $Matches.dominio
                if (-not $dominios[$dominio]) { $dominios[$dominio] = @{ count = 0; files = @() } }
                $dominios[$dominio].count++
                $dominios[$dominio].files += $file.Name
            }
        }

        if ($dominios.Count -eq 0) {
            Write-Host "   No se encontraron componentes TypeScript" -ForegroundColor Gray
        } else {
            foreach ($dominio in $dominios.Keys | Sort-Object) {
                Write-Host "`n🏠 $dominio ($($dominios[$dominio].count) archivos)" -ForegroundColor Cyan
                foreach ($file in $dominios[$dominio].files | Select-Object -First 10) {
                    Write-Host "   - $file" -ForegroundColor Gray
                }
                if ($dominios[$dominio].count -gt 10) {
                    Write-Host "   ... y $($dominios[$dominio].count - 10) más" -ForegroundColor Gray
                }
            }
        }
    }

    "info" {
        Write-Host "📁 Guía de estructura de carpetas" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "🏠 PEQUEÑO (directo):" -ForegroundColor Yellow
        Write-Host "   [Dominio]/" -ForegroundColor Gray
        Write-Host "     - *.service.ts" -ForegroundColor Gray
        Write-Host "     - *.repository.ts" -ForegroundColor Gray
        Write-Host "     - *.types.ts" -ForegroundColor Gray
        Write-Host ""
        Write-Host "🏢 MEDIANO/GRANDE (capas):" -ForegroundColor Yellow
        Write-Host "   Domain/entities/         → *.entity.ts" -ForegroundColor Gray
        Write-Host "   Application/services/   → *.service.ts" -ForegroundColor Gray
        Write-Host "   Application/transforms/ → *.transform.ts" -ForegroundColor Gray
        Write-Host "   Application/ports/      → *.port.ts" -ForegroundColor Gray
        Write-Host "   Application/use-cases/ → *.usecase.ts" -ForegroundColor Gray
        Write-Host "   Application/dtos/       → *.dto.ts" -ForegroundColor Gray
        Write-Host "   Infrastructure/persistence/ → *.repository.ts" -ForegroundColor Gray
        Write-Host "   Infrastructure/adapters/   → *.adapter.ts" -ForegroundColor Gray
        Write-Host "   validations/            → *.validation.ts" -ForegroundColor Gray
    }

    default {
        Write-Host "❌ Comando desconocido: $Comando" -ForegroundColor Red
        Write-Host ""
        Write-Host "Comandos disponibles:" -ForegroundColor Yellow
        Write-Host "  orkidns normalize <archivo|carpeta>  - Normalizar TypeScript" -ForegroundColor Gray
        Write-Host "  orkidns init                         - Inicializar config" -ForegroundColor Gray
        Write-Host "  orkidns check                        - Verificar arquitectura" -ForegroundColor Gray
        Write-Host "  orkidns list                         - Listar componentes" -ForegroundColor Gray
        Write-Host "  orkidns info                         - Mostrar guía de estructura" -ForegroundColor Gray
    }
}