# Script para normalizar TypeScript al formato NetSuite (PowerShell)
# Uso: .\normalize-ts.ps1 "ruta\al\archivo.ts"

param(
    [Parameter(Mandatory=$true)]
    [string]$Archivo
)

if (-not (Test-Path $Archivo)) {
    Write-Host "Error: El archivo no existe: $Archivo" -ForegroundColor Red
    exit 1
}

Write-Host "📝 Normalizando: $Archivo" -ForegroundColor Cyan
Write-Host ""

$Contenido = Get-Content $Archivo -Raw

# Detectar tipo de script basándose en funciones
$ScriptType = "Suitelet"
if ($Contenido -match "pageInit") {
    $ScriptType = "ClientScript"
} elseif ($Contenido -match "beforeSubmit|afterSubmit") {
    $ScriptType = "UserEventScript"
} elseif ($Contenido -match "getInputData|map|reduce|summarize") {
    $ScriptType = "MapReduceScript"
} elseif ($Contenido -match "execute") {
    $ScriptType = "ScheduledScript"
}

Write-Host "✅ Tipo de script detectado: $ScriptType" -ForegroundColor Green

# Agregar JSDoc si no existe
if ($Contenido -notmatch "@NApiVersion") {
    $JSDoc = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType $ScriptType
 */

"@
    $Contenido = $JSDoc + $Contenido
    Write-Host "✅ Agregado JSDoc con @NApiVersion 2.1 y @NScriptType $ScriptType" -ForegroundColor Green
}

# Agregar import de EntryPoints si hay export de funciones NetSuite
if ($Contenido -match "export.*onRequest|export.*pageInit|export.*beforeSubmit|export.*afterSubmit") {
    if ($Contenido -notmatch "from 'N/types'") {
        # Agregar el import después del último import de N/
        $Contenido = $Contenido -replace "(from 'N/[^']+')", "`$1`nimport { EntryPoints } from 'N/types';"
        Write-Host "✅ Agregado import de EntryPoints" -ForegroundColor Green
    }
}

# Escribir el archivo modificado
Set-Content -Path $Archivo -Value $Contenido -NoNewline

Write-Host "✅ Archivo normalizado: $Archivo" -ForegroundColor Green
Write-Host ""
Write-Host "Verificaciones realizadas:" -ForegroundColor Cyan
Write-Host "  - JSDoc con @NApiVersion 2.1" -ForegroundColor Gray
Write-Host "  - @NModuleScope Public" -ForegroundColor Gray
Write-Host "  - @NScriptType $ScriptType" -ForegroundColor Gray
Write-Host "  - EntryPoints import (si aplica)" -ForegroundColor Gray