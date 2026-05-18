<#
.SYNOPSIS
    Script para normalizar TypeScript al formato NetSuite

.DESCRIPTION
    Corrige archivos TypeScript para que compilen correctamente a JavaScript de NetSuite.
    - Agrega JSDoc faltante
    - Detecta tipo de script automáticamente
    - Convierte record.Type string a enum
    - Convierte exports al formato NetSuite

.PARAMETER Path
    Ruta al archivo o carpeta a normalizar

.PARAMETER Recursive
    Si se especifica, procesa carpetas recursivamente

.EXAMPLE
    .\normalize-ts.ps1 "src\TypeScripts\Sales\invoice.ts"
    .\normalize-ts.ps1 "src\TypeScripts\Sales" -Recursive

#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,

    [switch]$Recursive
)

$ErrorActionPreference = "Continue"

function Write-Message {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Get-ScriptType {
    param([string]$Content)

    if ($Content -match "onRequest") { return "Suitelet" }
    if ($Content -match "pageInit") { return "ClientScript" }
    if ($Content -match "beforeSubmit|afterSubmit") { return "UserEventScript" }
    if ($Content -match "getInputData|map|reduce|summarize") { return "MapReduceScript" }
    if ($Content -match "execute") { return "ScheduledScript" }
    if ($Content -match "render|resize|columnClicked") { return "Portlet" }
    if ($Content -match "^get$|^post$|^put$|^delete$") { return "Restlet" }

    return "Suitelet"
}

function Normalize-File {
    param([string]$FilePath)

    $modified = $false
    $changes = @()

    if (-not (Test-Path $FilePath)) {
        Write-Message "  ⚠ Archivo no existe: $FilePath" -Color Yellow
        return
    }

    $content = Get-Content $FilePath -Raw

    $relativePath = $FilePath.Replace((Get-Location).Path, "").TrimStart("\")

    # 1. Detectar tipo de script
    $scriptType = Get-ScriptType -Content $content

    # 2. Agregar JSDoc si no existe o está incompleto
    $hasJsdoc = $content -match "@NApiVersion"
    $hasScriptType = $content -match "@NScriptType"
    $hasModuleScope = $content -match "@NModuleScope"

    if (-not $hasJsdoc) {
        $jsdoc = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType $scriptType
 */

"@
        $content = $jsdoc + $content
        $modified = $true
        $changes += "JSDoc agregado"
    } elseif (-not $hasScriptType) {
        # Ya tiene JSDoc, agregar @NScriptType
        $content = $content -replace "(\*/)", " * @NScriptType $scriptType`n */"
        $modified = $true
        $changes += "@NScriptType agregado"
    }

    # 3. Agregar import de EntryPoints si hay funciones NetSuite
    $needsEntryPoints = $content -match "export\s+let\s+(onRequest|pageInit|beforeSubmit|afterSubmit|getInputData|map|reduce|summarize|execute|render|resize|get|post|put|delete)"
    if ($needsEntryPoints -and $content -notmatch "from 'N/types'") {
        # Encontrar el último import de N/
        if ($content -match "(from 'N/[^']+')") {
            $content = $content -replace "(from 'N/[^']+')", "`$1`nimport { EntryPoints } from 'N/types';"
            $modified = $true
            $changes += "EntryPoints import"
        } else {
            # Agregar al inicio después de cualquier comentario
            $content = $content -replace "^(\s*)(import\s)", "`$1import { EntryPoints } from 'N/types';`n`$1`$2"
            $modified = $true
            $changes += "EntryPoints import"
        }
    }

    # 4. Convertir record.Type string a enum
    # Buscar patrones como record.create({ type: 'invoice' })
    if ($content -match "record\.(create|load|delete)\s*\(\s*\{\s*type:\s*'([a-zA-Z]+)'") {
        $content = $content -replace "record\.(create|load|delete)\s*\(\s*\{\s*type:\s*'(\w+)'", "record.`$1({ type: record.Type.`$2"
        $modified = $true
        $changes += "record.Type enum"
    }

    # 5. Convertir exports al formato EntryPoints si es necesario
    # Cambiar export function onRequest a export let onRequest: EntryPoints.Suitelet.onRequest
    if ($scriptType -eq "Suitelet") {
        if ($content -match "export\s+function\s+onRequest") {
            $content = $content -replace "export\s+function\s+onRequest", "export let onRequest: EntryPoints.Suitelet.onRequest"
            $modified = $true
            $changes += "Export Suitelet"
        }
    }
    if ($scriptType -eq "ClientScript") {
        if ($content -match "export\s+function\s+pageInit") {
            $content = $content -replace "export\s+function\s+pageInit", "export let pageInit: EntryPoints.ClientScript.pageInit"
            $modified = $true
            $changes += "Export ClientScript"
        }
    }
    if ($scriptType -eq "UserEventScript") {
        if ($content -match "export\s+function\s+beforeSubmit") {
            $content = $content -replace "export\s+function\s+beforeSubmit", "export let beforeSubmit: EntryPoints.UserEvent.beforeSubmit"
            $modified = $true
        }
        if ($content -match "export\s+function\s+afterSubmit") {
            $content = $content -replace "export\s+function\s+afterSubmit", "export let afterSubmit: EntryPoints.UserEvent.afterSubmit"
            $modified = $true
        }
        $changes += "Export UserEvent"
    }
    if ($scriptType -eq "ScheduledScript") {
        if ($content -match "export\s+function\s+execute") {
            $content = $content -replace "export\s+function\s+execute", "export let execute: EntryPoints.Scheduled.execute"
            $modified = $true
            $changes += "Export Scheduled"
        }
    }
    if ($scriptType -eq "MapReduceScript") {
        if ($content -match "export\s+function\s+getInputData") {
            $content = $content -replace "export\s+function\s+getInputData", "export let getInputData: EntryPoints.MapReduce.getInputData"
            $modified = $true
        }
        if ($content -match "export\s+function\s+map") {
            $content = $content -replace "export\s+function\s+map", "export let map: EntryPoints.MapReduce.map"
            $modified = $true
        }
        if ($content -match "export\s+function\s+reduce") {
            $content = $content -replace "export\s+function\s+reduce", "export let reduce: EntryPoints.MapReduce.reduce"
            $modified = $true
        }
        if ($content -match "export\s+function\s+summarize") {
            $content = $content -replace "export\s+function\s+summarize", "export let summarize: EntryPoints.MapReduce.summarize"
            $modified = $true
        }
        $changes += "Export MapReduce"
    }
    if ($scriptType -eq "Restlet") {
        if ($content -match "export\s+function\s+get") {
            $content = $content -replace "export\s+function\s+get\b", "export let get: EntryPoints.Restlet.get"
            $modified = $true
        }
        if ($content -match "export\s+function\s+post") {
            $content = $content -replace "export\s+function\s+post", "export let post: EntryPoints.Restlet.post"
            $modified = $true
        }
        if ($content -match "export\s+function\s+put") {
            $content = $content -replace "export\s+function\s+put", "export let put: EntryPoints.Restlet.put"
            $modified = $true
        }
        if ($content -match "export\s+function\s+delete") {
            $content = $content -replace "export\s+function\s+delete\b", "export let delete: EntryPoints.Restlet.delete"
            $modified = $true
        }
        $changes += "Export Restlet"
    }

    # Guardar si hubo cambios
    if ($modified) {
        Set-Content -Path $FilePath -Value $content -NoNewline
        Write-Message "✅ $relativePath" -Color Green
        foreach ($change in $changes) {
            Write-Message "     + $change" -Color Gray
        }
    } else {
        Write-Message "  ✓ $relativePath (ya normalizado)" -Color DarkGray
    }

    return $modified
}

# Main
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  NetSuite TypeScript Normalizer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$fullPath = if ([System.IO.Path]::IsPathRooted($Path)) { $Path }
            else { Join-Path (Get-Location) $Path }

$processed = 0
$modified = 0

if (Test-Path $fullPath) {
    $item = Get-Item $fullPath

    if ($item.PSIsContainer) {
        # Es carpeta
        Write-Message "📁 Normalizando carpeta: $Path" -Color Cyan

        if ($Recursive) {
            $files = Get-ChildItem -Path $fullPath -Filter "*.ts" -Recurse -File
        } else {
            $files = Get-ChildItem -Path $fullPath -Filter "*.ts" -File
        }

        Write-Message "   Archivos TypeScript: $($files.Count)" -Color Yellow

        foreach ($file in $files) {
            $processed++
            if (Normalize-File -FilePath $file.FullName) {
                $modified++
            }
        }
    } else {
        # Es archivo
        Write-Message "📝 Normalizando archivo: $Path" -Color Cyan
        $processed++
        if (Normalize-File -FilePath $fullPath) {
            $modified++
        }
    }
} else {
    Write-Message "❌ La ruta no existe: $Path" -Color Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Resumen:" -ForegroundColor Cyan
Write-Host "    Procesados: $processed" -ForegroundColor White
Write-Host "    Modificados: $modified" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""