<#
.SYNOPSIS
    Script para crear proyecto NetSuite MEDIANO

.DESCRIPTION
    Crea estructura con carpetas Domain/Application/Infrastructure

.PARAMETER Ruta
    Ruta donde se creará el proyecto (relativa)

.PARAMETER Nombre
    Nombre del proyecto

.PARAMETER Dominio
    Dominio principal (Sales, Inventory, etc.)

.PARAMETER Prefijo
    Prefijo para los scripts (ej: gw)

.PARAMETER ConModules
    Si especifica, usa carpeta Modules

.EXAMPLE
    .\create-medium.ps1 -Ruta "src\TypeScripts\MiProyecto" -Nombre "MiProyecto" -Dominio "Sales" -Prefijo "gw"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Ruta,

    [Parameter(Mandatory=$true)]
    [string]$Nombre,

    [Parameter(Mandatory=$true)]
    [string]$Dominio,

    [Parameter(Mandatory=$false)]
    [string]$Prefijo = "gw",

    [switch]$ConModules
)

$ErrorActionPreference = "Stop"

$useModules = $ConModules.IsPresent

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
Write-Host "  Creando proyecto MEDIANO: $Nombre" -ForegroundColor Magenta
Write-Host "  Dominio: $Dominio" -ForegroundColor Magenta
Write-Host "  Con Modules: $useModules" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Magenta

# Determinar estructura de rutas
$domainRoot = if ($useModules) { "Modules\$Dominio" } else { $Dominio }

# Crear estructura de carpetas
Write-Step "1. Creando estructura de carpetas..."

$folders = @(
    "$domainRoot\Domain\entities",
    "$domainRoot\Application\services",
    "$domainRoot\Application\transforms",
    "$domainRoot\Infrastructure\repositories",
    "$domainRoot\validations",
    "Interface\Restlets",
    "Interface\Suitelets",
    "Shared\utils",
    "Shared\constants"
)

foreach ($folder in $folders) {
    $null = New-Item -ItemType Directory -Path (Join-Path $Ruta $folder) -Force
}

Write-Success "Carpetas creadas"

# Crear archivos base
Write-Step "2. Creando archivos base..."

# Entity
$entityContent = @"
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
  status?: string;
}
"@

$entityPath = if ($useModules) { "$domainRoot\Domain\entities\$Dominio.entity.ts" } else { "$domainRoot\Domain\entities\$Dominio.entity.ts" }
Set-Content -Path (Join-Path $Ruta $entityPath) -Value $entityContent -NoNewline

# Service
$serviceContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import record from 'N/record';
import { ${Dominio}Entity } from '../../Domain/entities/${Dominio}.entity';
import { ${Dominio}Repository } from '../../Infrastructure/repositories/${Dominio}.repository';

export class ${Dominio}Service {
  private repository: ${Dominio}Repository;

  constructor() {
    this.repository = new ${Dominio}Repository();
  }

  create(data: ${Dominio}Input): { success: boolean; id?: number; error?: string } {
    const entityResult = ${Dominio}Entity.create(data);
    if (!entityResult.success) return { success: false, error: entityResult.error };

    try {
      const rec = record.create({ type: record.Type.INVOICE });
      rec.setValue({ fieldId: 'entity', value: data.name });
      const id = rec.save();
      return { success: true, id };
    } catch (e) {
      return { success: false, error: e.message };
    }
  }

  read(id: number): ${Dominio}Output | null {
    return this.repository.findById(id);
  }
}

interface ${Dominio}Input { name: string; status?: string; }
interface ${Dominio}Output { id: number; name: string; status?: string; }
"@

Set-Content -Path (Join-Path $Ruta "$domainRoot\Application\services\$Dominio.service.ts") -Value $serviceContent -NoNewline

# Repository
$repositoryContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import search from 'N/search';

export class ${Dominio}Repository {
  findAll(filters?: string[][]): any[] {
    const results: any[] = [];
    const searchObj = search.create({
      type: search.Type.INVOICE,
      filters: filters || [],
      columns: ['internalid', 'entity', 'status']
    });
    const resultSet = searchObj.run();
    let start = 0;
    while (true) {
      const range = resultSet.getRange({ start, end: start + 1000 });
      if (!range.length) break;
      range.forEach((row) => {
        results.push({
          id: parseInt(row.getValue({ name: 'internalid' }) as string, 10),
          name: row.getValue({ name: 'entity' }) as string,
          status: row.getValue({ name: 'status' }) as string
        });
      });
      start += 1000;
    }
    return results;
  }

  findById(id: number): any | null {
    return this.findAll([['internalid', 'is', String(id)]])[0] || null;
  }

  save(data: any): number {
    const rec = record.create({ type: record.Type.INVOICE });
    Object.keys(data).forEach(key => {
      rec.setValue({ fieldId: key, value: data[key] });
    });
    return rec.save();
  }
}
"@

Set-Content -Path (Join-Path $Ruta "$domainRoot\Infrastructure\repositories\$Dominio.repository.ts") -Value $repositoryContent -NoNewline

# Validation
$validationContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export interface ${Dominio}ValidationResult {
  valid: boolean;
  errors: string[];
}

export class ${Dominio}Validator {
  validate(data: any): ${Dominio}ValidationResult {
    const errors: string[] = [];

    if (!data.name || data.name.trim() === '') {
      errors.push('El campo name es requerido');
    }

    if (data.name && data.name.length > 100) {
      errors.push('El campo name no puede exceder 100 caracteres');
    }

    return { valid: errors.length === 0, errors };
  }

  validateForCreate(data: any): ${Dominio}ValidationResult {
    const baseValidation = this.validate(data);
    if (!baseValidation.valid) return baseValidation;

    const errors: string[] = [];

    if (data.id) {
      errors.push('No se debe proporcionar ID para crear un nuevo registro');
    }

    return { valid: errors.length === 0, errors: [...baseValidation.errors, ...errors] };
  }

  validateForUpdate(data: any): ${Dominio}ValidationResult {
    const baseValidation = this.validate(data);
    if (!baseValidation.valid) return baseValidation;

    const errors: string[] = [];

    if (!data.id) {
      errors.push('El ID es requerido para actualizar');
    }

    return { valid: errors.length === 0, errors: [...baseValidation.errors, ...errors] };
  }
}
"@

Set-Content -Path (Join-Path $Ruta "$domainRoot\validations\$Dominio.validation.ts") -Value $validationContent -NoNewline

# RESTlet ejemplo
$restletContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType Restlet
 */
import { EntryPoints } from 'N/types';
import { ${Dominio}Service } from '../../${domainRoot}/Application/services/${Dominio}.service';
import { ${Dominio}Validator } from '../../${domainRoot}/validations/${Dominio}.validation';

const service = new ${Dominio}Service();
const validator = new ${Dominio}Validator();

export let get: EntryPoints.Restlet.get = (context) => {
  const id = context.request.parameters.id;
  if (id) {
    const result = service.read(parseInt(id, 10));
    return result || { error: 'Registro no encontrado' };
  }
  return { message: 'Use POST para crear, PUT para actualizar' };
};

export let post: EntryPoints.Restlet.post = (context) => {
  const data = JSON.parse(context.request.body || '{}');
  const validation = validator.validateForCreate(data);

  if (!validation.valid) {
    return { success: false, errors: validation.errors };
  }

  return service.create(data);
};

export let put: EntryPoints.Restlet.put = (context) => {
  const id = context.request.parameters.id;
  if (!id) {
    return { success: false, error: 'ID requerido para actualizar' };
  }

  const data = JSON.parse(context.request.body || '{}');
  data.id = parseInt(id, 10);
  const validation = validator.validateForUpdate(data);

  if (!validation.valid) {
    return { success: false, errors: validation.errors };
  }

  return { success: true };
};

export let delete: EntryPoints.Restlet.delete = (context) => {
  const id = context.request.parameters.id;
  if (!id) {
    return { success: false, error: 'ID requerido para eliminar' };
  }
  return { success: true };
};
"@

Set-Content -Path (Join-Path $Ruta "Interface\Restlets\${Prefijo}_${Dominio}_restlet.ts") -Value $restletContent -NoNewline

# Suitelet ejemplo
$suiteletContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType Suitelet
 */
import { EntryPoints } from 'N/types';
import { ${Dominio}Service } from '../../${domainRoot}/Application/services/${Dominio}.service';

const service = new ${Dominio}Service();

export let onRequest: EntryPoints.Suitelet.onRequest = (context) => {
  const response = context.response;
  const request = context.request;

  if (request.method === 'GET') {
    const id = request.parameters.id;
    const data = id ? service.read(parseInt(id, 10)) : { message: 'Use POST para crear' };

    response.write({
      body: JSON.stringify(data),
      contentType: 'application/json'
    });
  } else if (request.method === 'POST') {
    const data = JSON.parse(request.body || '{}');
    const result = service.create(data);
    response.write({ body: JSON.stringify(result) });
  }
};
"@

Set-Content -Path (Join-Path $Ruta "Interface\Suitelets\${Prefijo}_${Dominio}_suitelet.ts") -Value $suiteletContent -NoNewline

Write-Success "Archivos creados"
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  ✅ Proyecto MEDIANO creado exitosamente!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Estructura creada:" -ForegroundColor Cyan
Write-Host "  $domainRoot/"
Write-Host "    Domain/entities/"
Write-Host "    Application/services/, transforms/"
Write-Host "    Infrastructure/repositories/"
Write-Host "    validations/"
Write-Host "  Interface/"
Write-Host "    Restlets/, Suitelets/"
Write-Host "  Shared/"
Write-Host "    utils/, constants/"
Write-Host ""