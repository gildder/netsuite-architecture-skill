<#
.SYNOPSIS
    Genera archivos XML de definición de scripts para SDF

.DESCRIPTION
    Crea automáticamente customscript_*.xml y customdeploy_*.xml
    basándose en los scripts TypeScript encontrados en el proyecto

.PARAMETER ProjectPath
    Ruta al proyecto (donde está el orkidns.config.json)

.PARAMETER Prefix
    Prefijo de los scripts (ej: gw)

.PARAMETER OutputPath
    Carpeta donde se generarán los XML (default: src/Objects)

.EXAMPLE
    .\generate-sdf.ps1 -ProjectPath "C:\proyectos\mi-proyecto" -Prefix "gw"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = ".",

    [Parameter(Mandatory=$false)]
    [string]$Prefix = "gw",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "src/Objects"
)

$ErrorActionPreference = "Stop"

function Get-ScriptType {
    param([string]$FileName)

    $name = $FileName.ToLower()

    if ($name -match "_sl_") { return @{ Type = "Suitelet"; ScriptType = "SuiteletScript" } }
    if ($name -match "_rl_") { return @{ Type = "Restlet"; ScriptType = "RestletScript" } }
    if ($name -match "_cs_") { return @{ Type = "ClientScript"; ScriptType = "ClientScript" } }
    if ($name -match "_ue_") { return @{ Type = "UserEvent"; ScriptType = "UserEventScript" } }
    if ($name -match "_sc_") { return @{ Type = "Scheduled"; ScriptType = "ScheduledScript" } }
    if ($name -match "_mr_") { return @{ Type = "MapReduce"; ScriptType = "MapReduceScript" } }
    if ($name -match "_pl_") { return @{ Type = "Portlet"; ScriptType = "Portlet" } }
    if ($name -match "_wa_") { return @{ Type = "WorkflowAction"; ScriptType = "WorkflowActionScript" } }
    if ($name -match "_mu_") { return @{ Type = "MassUpdate"; ScriptType = "MassUpdateScript" } }
    if ($name -match "_bi_") { return @{ Type = "BundleInstallation"; ScriptType = "BundleInstallationScript" } }

    return $null
}

function New-CustomScriptXml {
    param(
        [string]$ScriptId,
        [string]$ScriptName,
        [string]$ScriptType,
        [string]$FilePath,
        [string]$ProjectName
    )

$xml = @"
<?xml version="1.0" encoding="UTF-8">
<script type="$ScriptType" scriptid="$ScriptId">
  <description>$ScriptName - Generado automáticamente</description>
  <isinactive>F</isinactive>
  <name>$ScriptName</name>
  <notifyadmins>F</notifyadmins>
  <notifyemails></notifyemails>
  <notifyowner>T</notifyowner>
  <notifyuser>F</notifyuser>
  <scriptfile>SuiteScripts/$ProjectName/$FilePath</scriptfile>
  <status>TESTING</status>
</script>
"@

    return $xml
}

function New-CustomDeployXml {
    param(
        [string]$ScriptId,
        [string]$ScriptName,
        [string]$ScriptType,
        [string]$ProjectName
    )

    $scriptIdOnly = $ScriptId -replace "customscript_", ""

    $specificConfig = ""
    switch ($ScriptType) {
        "SuiteletScript" {
            $specificConfig = @"
  <scriptdeploytype>SCRIPTABLE</scriptdeploytype>
"@
        }
        "ClientScript" {
            $specificConfig = @"
  <applies>TRANSACTION</applies>
  <status>TESTING</status>
"@
        }
        "ScheduledScript" {
            $specificConfig = @"
  <schedule>
    <recurrence>
      <interval>
        <period>DAILY</period>
        <hours>1</hours>
      </interval>
    </recurrence>
  </schedule>
  <status>TESTING</status>
"@
        }
    }

$xml = @"
<?xml version="1.0" encoding="UTF-8">
<scriptdeploy type="$ScriptType" scriptid="$scriptIdOnly">
  <status>TESTING</status>
  <isavailable>PUBLIC</isavailable>
  <warnonunsupportedchanges>T</warnonunsupportedchanges>
  $specificConfig
</scriptdeploy>
"@

    return $xml
}

# Main
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Generador de XML SDF" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$fullProjectPath = if ([System.IO.Path]::IsPathRooted($ProjectPath)) { $ProjectPath }
                    else { Join-Path (Get-Location) $ProjectPath }

# Cargar configuración de OrkidNS
$configPath = Join-Path $fullProjectPath "orkidns.config.json"
if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    $Prefix = $config.project.prefix
    Write-Host "Usando prefijo: $Prefix" -ForegroundColor Yellow
}

$projectName = Split-Path $fullProjectPath -Leaf
$outputDir = Join-Path $fullProjectPath $OutputPath

# Crear carpeta de salida
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Write-Host "Buscando scripts TypeScript..." -ForegroundColor Yellow

# Buscar scripts en Interface
$interfacePath = Join-Path $fullProjectPath "src\TypeScripts\$projectName\Interface"
$scriptsGenerated = @()

if (Test-Path $interfacePath) {
    $tsFiles = Get-ChildItem -Path $interfacePath -Filter "*.ts" -Recurse

    foreach ($file in $tsFiles) {
        $fileName = $file.Name
        $scriptInfo = Get-ScriptType -FileName $fileName

        if ($scriptInfo) {
            $scriptId = "customscript_${Prefix}_$($scriptInfo.Type)_$projectName"
            $deployId = "customdeploy_${Prefix}_$($scriptInfo.Type)_$projectName"
            $scriptName = "$($scriptInfo.Type) - $projectName"

            Write-Host ""
            Write-Host "  📄 Encontrado: $fileName" -ForegroundColor White
            Write-Host "     Tipo: $($scriptInfo.ScriptType)" -ForegroundColor Gray
            Write-Host "     Script ID: $scriptId" -ForegroundColor Gray

            # Generar customscript_*.xml
            $scriptXml = New-CustomScriptXml -ScriptId $scriptId -ScriptName $scriptName -ScriptType $scriptInfo.ScriptType -FilePath "Interface/$($file.Directory.Name)/$fileName" -ProjectName $projectName
            $scriptXmlPath = Join-Path $outputDir "${scriptId}.xml"
            $scriptXml | Set-Content -Path $scriptXmlPath -NoNewline
            Write-Success "  ✓ $scriptId.xml creado"

            # Generar customdeploy_*.xml
            $deployXml = New-CustomDeployXml -ScriptId $scriptId -ScriptName $scriptName -ScriptType $scriptInfo.ScriptType -ProjectName $projectName
            $deployXmlPath = Join-Path $outputDir "${deployId}.xml"
            $deployXml | Set-Content -Path $deployXmlPath -NoNewline
            Write-Success "  ✓ $deployId.xml creado"

            $scriptsGenerated += $scriptId
        }
    }
}

if ($scriptsGenerated.Count -eq 0) {
    Write-Host ""
    Write-Host "⚠ No se encontraron scripts en la carpeta Interface" -ForegroundColor Yellow
    Write-Host "   Asegurate de tener archivos .ts con el formato:" -ForegroundColor Yellow
    Write-Host "   [prefijo]_[tipo]_[nombre].ts" -ForegroundColor Gray
    Write-Host "   Ejemplos:" -ForegroundColor Gray
    Write-Host "     - gw_sl_facturas.ts" -ForegroundColor Gray
    Write-Host "     - gw_rs_pedidos.ts" -ForegroundColor Gray
    Write-Host "     - gw_ue_factura.ts" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ XMLs generados: $($scriptsGenerated.Count)" -ForegroundColor Green
    Write-Host "  Ubicación: $outputDir" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
}

Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Cyan
Write-Host "  1. Revisar los XML generados en $OutputPath" -ForegroundColor White
Write-Host "  2. Ajustar configuraciones según necesidad" -ForegroundColor White
Write-Host "  3. Agregar al deploy.xml si es necesario" -ForegroundColor White
Write-Host ""