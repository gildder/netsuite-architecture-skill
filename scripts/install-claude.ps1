<#
.SYNOPSIS
    Instala el skill y agente para Claude Code

.DESCRIPTION
    Después de instalar el skill con "claude skill install", ejecutar este script
    para crear la estructura correcta de carpetas en el proyecto

.EXAMPLE
    .\install-claude.ps1
    # Crea .claude/skills/netsuite-clean-architecture/
    # Crea .claude/agents/orkidns/
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$SkillPath = ""
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Instalando estructura para Claude Code" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Buscar el skill instalado
if (-not $SkillPath) {
    # Buscar en ubicaciones comunes
    $possiblePaths = @(
        ".agents/skills/netsuite-clean-architecture",
        "../netsuite-architecture-skill",
        "$HOME/.claude/skills/netsuite-clean-architecture"
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $SkillPath = $path
            break
        }
    }
}

if (-not $SkillPath -or -not (Test-Path $SkillPath)) {
    Write-Host "❌ No se encontró el skill instalado" -ForegroundColor Red
    Write-Host ""
    Write-Host "Asegúrate de instalar primero el skill:" -ForegroundColor Yellow
    Write-Host "  claudeskill install gildder/netsuite-architecture-skill" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Luego ejecuta este script desde la raíz de tu proyecto" -ForegroundColor Gray
    exit 1
}

Write-Host "✅ Skill encontrado en: $SkillPath" -ForegroundColor Green
Write-Host ""

# Crear estructura .claude/
Write-Host "Creando estructura .claude/..." -ForegroundColor Cyan

# Crear carpetas
$null = New-Item -ItemType Directory -Path ".claude/skills/netsuite-clean-architecture" -Force -ErrorAction SilentlyContinue
$null = New-Item -ItemType Directory -Path ".claude/agents/orkidns" -Force -ErrorAction SilentlyContinue

# Copiar SKILL.md
$skillSrc = Join-Path $SkillPath "SKILL.md"
if (Test-Path $skillSrc) {
    Copy-Item -Path $skillSrc -Destination ".claude/skills/netsuite-clean-architecture/SKILL.md" -Force
    Write-Host "  ✅ .claude/skills/netsuite-clean-architecture/SKILL.md" -ForegroundColor Green
}

# Copiar AGENT.md
$agentSrc = Join-Path $SkillPath "AGENT.md"
if (-not $agentSrc -or -not (Test-Path $agentSrc)) {
    $agentSrc = Join-Path $SkillPath "orkidns/AGENT.md"
}
if (-not $agentSrc -or -not (Test-Path $agentSrc)) {
    $agentSrc = Join-Path $SkillPath "../orkidns/AGENT.md"
}

if (Test-Path $agentSrc) {
    Copy-Item -Path $agentSrc -Destination ".claude/agents/orkidns/AGENT.md" -Force
    Write-Host "  ✅ .claude/agents/orkidns/AGENT.md" -ForegroundColor Green
} else {
    Write-Host "  ⚠ AGENT.md no encontrado, buscando..." -ForegroundColor Yellow
    # Buscar AGENT.md en cualquier parte del skill
    $agentSearch = Get-ChildItem -Path $SkillPath -Filter "AGENT.md" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($agentSearch) {
        Copy-Item -Path $agentSearch.FullName -Destination ".claude/agents/orkidns/AGENT.md" -Force
        Write-Host "  ✅ .claude/agents/orkidns/AGENT.md" -ForegroundColor Green
    }
}

# Copiar scripts si existen
$scriptsSrc = Join-Path $SkillPath "../scripts"
if (Test-Path $scriptsSrc) {
    $null = New-Item -ItemType Directory -Path ".claude/scripts" -Force -ErrorAction SilentlyContinue
    Copy-Item -Path (Join-Path $scriptsSrc "*.ps1") -Destination ".claude/scripts/" -Force -ErrorAction SilentlyContinue
    Write-Host "  ✅ Scripts copiados a .claude/scripts/" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✅ Instalación completada!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Estructura creada:" -ForegroundColor Cyan
Write-Host "  .claude/skills/netsuite-clean-architecture/SKILL.md" -ForegroundColor White
Write-Host "  .claude/agents/orkidns/AGENT.md" -ForegroundColor White
Write-Host "  .claude/scripts/ (si hay scripts)" -ForegroundColor White
Write-Host ""
Write-Host "Ahora podés usar el skill y el agente en Claude Code" -ForegroundColor Yellow
Write-Host ""