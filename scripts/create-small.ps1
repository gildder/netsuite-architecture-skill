<#
.SYNOPSIS
    Script para crear proyecto NetSuite PEQUEÑO

.DESCRIPTION
    Crea estructura simple sin carpeta Modules

.PARAMETER Ruta
    Ruta donde se creará el proyecto (relativa)

.PARAMETER Nombre
    Nombre del proyecto

.PARAMETER Dominio
    Dominio principal (Sales, Inventory, etc.)

.PARAMETER Prefijo
    Prefijo para los scripts (ej: gw)

.EXAMPLE
    .\create-small.ps1 -Ruta "src\TypeScripts\MiProyecto" -Nombre "MiProyecto" -Dominio "Sales" -Prefijo "gw"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Ruta,

    [Parameter(Mandatory=$true)]
    [string]$Nombre,

    [Parameter(Mandatory=$true)]
    [string]$Dominio,

    [Parameter(Mandatory=$false)]
    [string]$Prefijo = "gw"
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Magenta
Write-Host "  Creando proyecto PEQUEÑO: $Nombre" -ForegroundColor Magenta
Write-Host "  Dominio: $Dominio" -ForegroundColor Magenta
Write-Host "  Ruta: $Ruta" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Magenta

# Crear estructura de carpetas
Write-Step "1. Creando estructura de carpetas..."

$dominioPath = Join-Path $Ruta $Dominio
$interfacePath = Join-Path $Ruta "Interface"
$sharedPath = Join-Path $Ruta "Shared\utils"

$null = New-Item -ItemType Directory -Path $dominioPath -Force
$null = New-Item -ItemType Directory -Path $interfacePath -Force
$null = New-Item -ItemType Directory -Path $sharedPath -Force

Write-Success "Carpetas creadas"

# Crear types.ts
Write-Step "2. Creando archivos base..."

$typesContent = @"
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

Set-Content -Path (Join-Path $dominioPath "$Dominio.types.ts") -Value $typesContent -NoNewline

# Crear service.ts
$serviceContent = @"
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

  update(id: number, data: ${Dominio}Input): boolean {
    try {
      const rec = record.load({ type: record.Type.INVOICE, id });
      rec.setValue({ fieldId: 'entity', value: data.name });
      rec.save();
      return true;
    } catch {
      return false;
    }
  }

  delete(id: number): boolean {
    try {
      record.delete({ type: record.Type.INVOICE, id });
      return true;
    } catch {
      return false;
    }
  }
}
"@

Set-Content -Path (Join-Path $dominioPath "$Dominio.service.ts") -Value $serviceContent -NoNewline

# Crear repository.ts
$repositoryContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import search from 'N/search';

export class ${Dominio}Repository {
  findAll(filters?: string[][]): ${Dominio}Output[] {
    const results: ${Dominio}Output[] = [];
    const searchObj = search.create({
      type: search.Type.INVOICE,
      filters: filters || [],
      columns: ['internalid', 'entity']
    });
    const resultSet = searchObj.run();
    let start = 0;
    while (true) {
      const range = resultSet.getRange({ start, end: start + 1000 });
      if (!range.length) break;
      range.forEach((row) => {
        results.push({
          id: parseInt(row.getValue({ name: 'internalid' }) as string, 10),
          name: row.getValue({ name: 'entity' }) as string
        });
      });
      start += 1000;
    }
    return results;
  }

  findById(id: number): ${Dominio}Output | null {
    const results = this.findAll([['internalid', 'is', String(id)]]);
    return results.length > 0 ? results[0] : null;
  }
}
"@

Set-Content -Path (Join-Path $dominioPath "$Dominio.repository.ts") -Value $repositoryContent -NoNewline

# Crear Interface/Restlet ejemplo
$restletContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType Restlet
 */
import { EntryPoints } from 'N/types';
import { ${Dominio}Service } from '../${Dominio}/${Dominio}.service';

const service = new ${Dominio}Service();

export let get: EntryPoints.Restlet.get = (context) => {
  const id = context.request.parameters.id;
  return id ? service.read(parseInt(id, 10)) : service.findAll();
};

export let post: EntryPoints.Restlet.post = (context) => {
  return { id: service.create(context.request.body) };
};

export let put: EntryPoints.Restlet.put = (context) => {
  const id = context.request.parameters.id;
  return { success: service.update(parseInt(id, 10), context.request.body) };
};

export let delete: EntryPoints.Restlet.delete = (context) => {
  const id = context.request.parameters.id;
  return { success: service.delete(parseInt(id, 10)) };
};
"@

Set-Content -Path (Join-Path $interfacePath "${Prefijo}_${Dominio}_restlet.ts") -Value $restletContent -NoNewline

Write-Success "Archivos creados"
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  ✅ Proyecto PEQUEÑO creado exitosamente!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Estructura creada:" -ForegroundColor Cyan
Write-Host "  $Dominio/"
Write-Host "    - $Dominio.types.ts"
Write-Host "    - $Dominio.service.ts"
Write-Host "    - $Dominio.repository.ts"
Write-Host "  Interface/"
Write-Host "    - ${Prefijo}_${Dominio}_restlet.ts"
Write-Host "  Shared/"
Write-Host "    - utils/"
Write-Host ""