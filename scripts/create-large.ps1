<#
.SYNOPSIS
    Script para crear proyecto NetSuite GRANDE

.DESCRIPTION
    Crea estructura completa con Modules, Ports, Adapters, UseCases

.PARAMETER Ruta
    Ruta donde se creará el proyecto (relativa)

.PARAMETER Nombre
    Nombre del proyecto

.PARAMETER Dominio
    Dominio principal (Sales, Inventory, etc.)

.PARAMETER Prefijo
    Prefijo para los scripts (ej: gw)

.EXAMPLE
    .\create-large.ps1 -Ruta "src\TypeScripts\MiProyecto" -Nombre "MiProyecto" -Dominio "Sales" -Prefijo "gw"
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

$domainRoot = "Modules\$Dominio"

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
Write-Host "  Creando proyecto GRANDE: $Nombre" -ForegroundColor Magenta
Write-Host "  Dominio: $Dominio" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Magenta

# Crear estructura de carpetas
Write-Step "1. Creando estructura de carpetas..."

$folders = @(
    "$domainRoot\Domain\entities",
    "$domainRoot\Domain\value-objects",
    "$domainRoot\Domain\events",
    "$domainRoot\Domain\services",
    "$domainRoot\Application\use-cases",
    "$domainRoot\Application\ports\inbound",
    "$domainRoot\Application\ports\outbound",
    "$domainRoot\Application\dtos",
    "$domainRoot\Application\services",
    "$domainRoot\Application\transforms",
    "$domainRoot\Infrastructure\persistence",
    "$domainRoot\Infrastructure\adapters",
    "$domainRoot\validations",
    "Interface\Restlets",
    "Interface\Suitelets",
    "Interface\UserEvents",
    "Interface\ClientScripts",
    "Interface\Scheduled",
    "Interface\MapReduce",
    "Shared\domain",
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
  private readonly data: ${Dominio}Data;

  constructor(data: ${Dominio}Data) {
    this.data = data;
  }

  get id(): number | undefined { return this.data.id; }
  get name(): string { return this.data.name; }
  get status(): string | undefined { return this.data.status; }

  canBeCreated(): boolean {
    return !!this.data.name && this.data.name.length > 0;
  }

  canBeUpdated(): boolean {
    return !!this.data.id && !!this.data.name;
  }

  validate(): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    if (!this.data.name) errors.push('name es requerido');
    if (this.data.name && this.data.name.length > 100) errors.push('name no puede exceder 100 caracteres');
    return { valid: errors.length === 0, errors };
  }

  toDTO(): ${Dominio}DTO {
    return {
      id: this.data.id,
      name: this.data.name,
      status: this.data.status
    };
  }

  static create(data: ${Dominio}Data): { success: boolean; entity?: ${Dominio}Entity; error?: string } {
    const entity = new ${Dominio}Entity(data);
    const validation = entity.validate();
    if (!validation.valid) return { success: false, error: validation.errors.join(', ') };
    return { success: true, entity };
  }
}

interface ${Dominio}Data {
  id?: number;
  name: string;
  status?: string;
  metadata?: Record<string, unknown>;
}

export interface ${Dominio}DTO {
  id?: number;
  name: string;
  status?: string;
}
"@

Set-Content -Path (Join-Path $Ruta "$domainRoot\Domain\entities\$Dominio.entity.ts") -Value $entityContent -NoNewline

# Value Object
$voContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export class ${Dominio}Status {
  private readonly value: string;

  private static readonly VALID_STATUSES = ['pending', 'active', 'completed', 'cancelled'];

  private constructor(value: string) {
    this.value = value;
  }

  static create(value: string): ${Dominio}Status | null {
    if (!this.VALID_STATUSES.includes(value)) {
      return null;
    }
    return new ${Dominio}Status(value);
  }

  getValue(): string {
    return this.value;
  }

  isPending(): boolean { return this.value === 'pending'; }
  isActive(): boolean { return this.value === 'active'; }
  isCompleted(): boolean { return this.value === 'completed'; }
  isCancelled(): boolean { return this.value === 'cancelled'; }
}
"@

Set-Content -Path (Join-Path $Ruta "$domainRoot\Domain\value-objects\$Dominio.status.ts") -Value $voContent -NoNewline

# Domain Event
$eventContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export type ${Dominio}EventType =
  | '${Dominio}Created'
  | '${Dominio}Updated'
  | '${Dominio}Deleted';

export interface ${Dominio}Event {
  type: ${Dominio}EventType;
  data: ${Dominio}EventData;
  timestamp: Date;
}

export interface ${Dominio}EventData {
  id?: number;
  name: string;
  previousName?: string;
}

export class ${Dominio}EventDispatcher {
  private handlers: Map<${Dominio}EventType, Array<(event: ${Dominio}Event) => void>>;

  constructor() {
    this.handlers = new Map();
  }

  on(eventType: ${Dominio}EventType, handler: (event: ${Dominio}Event) => void): void {
    if (!this.handlers.has(eventType)) {
      this.handlers.set(eventType, []);
    }
    this.handlers.get(eventType)?.push(handler);
  }

  dispatch(event: ${Dominio}Event): void {
    const handlers = this.handlers.get(event.type) || [];
    handlers.forEach(handler => handler(event));
  }
}
"@

Set-Content -Path (Join-Path $Ruta "$domainRoot\Domain\events\$Dominio.event.ts") -Value $eventContent -NoNewline

# Input Port
$inputPortContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export interface ${Dominio}InputPort {
  create(input: ${Dominio}InputDTO): Promise<${Dominio}ResultDTO>;
  read(id: number): Promise<${Dominio}OutputDTO | null>;
  update(input: ${Dominio}UpdateDTO): Promise<${Dominio}ResultDTO>;
  delete(id: number): Promise<boolean>;
  list(filters?: ${Dominio}Filters): Promise<${Dominio}OutputDTO[]>;
}

export interface ${Dominio}InputDTO {
  name: string;
  status?: string;
  metadata?: Record<string, unknown>;
}

export interface ${Dominio}UpdateDTO {
  id: number;
  name?: string;
  status?: string;
  metadata?: Record<string, unknown>;
}

export interface ${Dominio}OutputDTO {
  id: number;
  name: string;
  status?: string;
  metadata?: Record<string, unknown>;
}

export interface ${Dominio}ResultDTO {
  success: boolean;
  id?: number;
  data?: ${Dominio}OutputDTO;
  error?: string;
  errors?: string[];
}

export interface ${Dominio}Filters {
  status?: string;
  name?: string;
  pageSize?: number;
  page?: number;
}
"@

Set-Content -Path (Join-Path $Ruta "$domainRoot\Application\ports\inbound\$Dominio.input.port.ts") -Value $inputPortContent -NoNewline

# Repository Port (Output)
$repoPortContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export interface ${Dominio}RepositoryPort {
  save(data: ${Dominio}Data): Promise<number>;
  update(id: number, data: Partial<${Dominio}Data>): Promise<boolean>;
  delete(id: number): Promise<boolean>;
  findById(id: number): Promise<${Dominio}Data | null>;
  findAll(filters?: ${Dominio}Filters): Promise<${Dominio}Data[]>;
}

export interface ${Dominio}Data {
  id?: number;
  name: string;
  status?: string;
  metadata?: Record<string, unknown>;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface ${Dominio}Filters {
  status?: string;
  name?: string;
  pageSize?: number;
  page?: number;
}
"@

Set-Content -Path (Join-Path $Ruta "$domainRoot\Application\ports\outbound\$Dominio.repository.port.ts") -Value $repoPortContent -NoNewline

# Adapter Port (Output)
$adapterPortContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export interface ${Dominio}ExternalPort {
  sync(data: ${Dominio}ExternalDTO): Promise<${Dominio}ExternalResult>;
  fetch(externalId: string): Promise<${Dominio}ExternalDTO | null>;
}

export interface ${Dominio}ExternalDTO {
  externalId: string;
  name: string;
  status: string;
  lastSync?: Date;
}

export interface ${Dominio}ExternalResult {
  success: boolean;
  externalId?: string;
  error?: string;
}
"@

Set-Content -Path (Join-Path $Ruta "$domainRoot\Application\ports\outbound\$Dominio.external.port.ts") -Value $adapterPortContent -NoNewline

# Service (Application Layer)
$serviceContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import { ${Dominio}InputPort, ${Dominio}InputDTO, ${Dominio}UpdateDTO, ${Dominio}OutputDTO, ${Dominio}ResultDTO, ${Dominio}Filters } from '../ports/inbound/${Dominio}.input.port';
import { ${Dominio}RepositoryPort, ${Dominio}Data, ${Dominio}Filters as RepoFilters } from '../ports/outbound/${Dominio}.repository.port';
import { ${Dominio}Entity } from '../../Domain/entities/${Dominio}.entity';
import { ${Dominio}EventDispatcher } from '../../Domain/events/${Dominio}.event';

export class ${Dominio}Service implements ${Dominio}InputPort {
  private repository: ${Dominio}RepositoryPort;
  private eventDispatcher: ${Dominio}EventDispatcher;

  constructor(repository: ${Dominio}RepositoryPort, eventDispatcher?: ${Dominio}EventDispatcher) {
    this.repository = repository;
    this.eventDispatcher = eventDispatcher || new ${Dominio}EventDispatcher();
  }

  async create(input: ${Dominio}InputDTO): Promise<${Dominio}ResultDTO> {
    const entityResult = ${Dominio}Entity.create(input);
    if (!entityResult.success) {
      return { success: false, error: entityResult.error };
    }

    try {
      const id = await this.repository.save(input);

      this.eventDispatcher.dispatch({
        type: '${Dominio}Created',
        data: { id, name: input.name },
        timestamp: new Date()
      });

      return { success: true, id, data: { id, ...input } };
    } catch (e) {
      return { success: false, error: e.message };
    }
  }

  async read(id: number): Promise<${Dominio}OutputDTO | null> {
    const data = await this.repository.findById(id);
    return data ? { id: data.id!, name: data.name, status: data.status } : null;
  }

  async update(input: ${Dominio}UpdateDTO): Promise<${Dominio}ResultDTO> {
    const existing = await this.repository.findById(input.id);
    if (!existing) {
      return { success: false, error: 'Registro no encontrado' };
    }

    const entityResult = ${Dominio}Entity.create({ ...existing, ...input });
    if (!entityResult.success) {
      return { success: false, error: entityResult.error };
    }

    try {
      await this.repository.update(input.id, input);

      this.eventDispatcher.dispatch({
        type: '${Dominio}Updated',
        data: { id: input.id, name: input.name || existing.name, previousName: existing.name },
        timestamp: new Date()
      });

      return { success: true, id: input.id };
    } catch (e) {
      return { success: false, error: e.message };
    }
  }

  async delete(id: number): Promise<boolean> {
    const existing = await this.repository.findById(id);
    if (!existing) return false;

    try {
      await this.repository.delete(id);

      this.eventDispatcher.dispatch({
        type: '${Dominio}Deleted',
        data: { id, name: existing.name },
        timestamp: new Date()
      });

      return true;
    } catch {
      return false;
    }
  }

  async list(filters?: ${Dominio}Filters): Promise<${Dominio}OutputDTO[]> {
    const repoFilters: RepoFilters = filters ? {
      status: filters.status,
      name: filters.name,
      pageSize: filters.pageSize,
      page: filters.page
    } : undefined;

    const results = await this.repository.findAll(repoFilters);
    return results.map(r => ({ id: r.id!, name: r.name, status: r.status }));
  }
}
"@

Set-Content -Path (Join-Path $Ruta "$domainRoot\Application\services\$Dominio.service.ts") -Value $serviceContent -NoNewline

# Infrastructure - Repository Implementation
$repoImplContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import record from 'N/record';
import search from 'N/search';
import { ${Dominio}RepositoryPort, ${Dominio}Data, ${Dominio}Filters } from '../../Application/ports/outbound/${Dominio}.repository.port';

export class ${Dominio}Repository implements ${Dominio}RepositoryPort {
  async save(data: ${Dominio}Data): Promise<number> {
    const rec = record.create({ type: record.Type.INVOICE });
    rec.setValue({ fieldId: 'entity', value: data.name });
    if (data.status) rec.setValue({ fieldId: 'status', value: data.status });
    return rec.save();
  }

  async update(id: number, data: Partial<${Dominio}Data>): Promise<boolean> {
    try {
      const rec = record.load({ type: record.Type.INVOICE, id });
      if (data.name) rec.setValue({ fieldId: 'entity', value: data.name });
      if (data.status) rec.setValue({ fieldId: 'status', value: data.status });
      rec.save();
      return true;
    } catch {
      return false;
    }
  }

  async delete(id: number): Promise<boolean> {
    try {
      record.delete({ type: record.Type.INVOICE, id });
      return true;
    } catch {
      return false;
    }
  }

  async findById(id: number): Promise<${Dominio}Data | null> {
    try {
      const rec = record.load({ type: record.Type.INVOICE, id });
      return {
        id: rec.id,
        name: rec.getValue({ fieldId: 'entity' }) as string,
        status: rec.getValue({ fieldId: 'status' }) as string
      };
    } catch {
      return null;
    }
  }

  async findAll(filters?: ${Dominio}Filters): Promise<${Dominio}Data[]> {
    const results: ${Dominio}Data[] = [];
    const filtersArray: string[][] = [];

    if (filters?.status) filtersArray.push(['status', 'is', filters.status]);
    if (filters?.name) filtersArray.push(['entity', 'contains', filters.name]);

    const searchObj = search.create({
      type: search.Type.INVOICE,
      filters: filtersArray,
      columns: ['internalid', 'entity', 'status']
    });

    const resultSet = searchObj.run();
    let start = 0;
    const pageSize = filters?.pageSize || 1000;
    const pageStart = ((filters?.page || 1) - 1) * pageSize;

    while (true) {
      const range = resultSet.getRange({ start, end: start + pageSize });
      if (!range.length) break;

      range.forEach((row) => {
        results.push({
          id: parseInt(row.getValue({ name: 'internalid' }) as string, 10),
          name: row.getValue({ name: 'entity' }) as string,
          status: row.getValue({ name: 'status' }) as string
        });
      });

      start += pageSize;
      if (start > pageStart + pageSize) break;
    }

    return results.slice(pageStart, pageStart + pageSize);
  }
}
"@

Set-Content -Path (Join-Path $Ruta "$domainRoot\Infrastructure\persistence\$Dominio.repository.ts") -Value $repoImplContent -NoNewline

# RESTlet
$restletContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType Restlet
 */
import { EntryPoints } from 'N/types';
import { ${Dominio}Service } from '../../${domainRoot}/Application/services/${Dominio}.service';
import { ${Dominio}Repository } from '../../${domainRoot}/Infrastructure/persistence/${Dominio}.repository';
import { ${Dominio}Validator } from '../../${domainRoot}/validations/${Dominio}.validation';

const repository = new ${Dominio}Repository();
const service = new ${Dominio}Service(repository);
const validator = new ${Dominio}Validator();

export let get: EntryPoints.Restlet.get = async (context) => {
  const id = context.request.parameters.id;
  const action = context.request.parameters.action;

  if (action === 'list') {
    const filters = context.request.parameters;
    const results = await service.list({
      status: filters.status,
      name: filters.name,
      pageSize: parseInt(filters.pageSize || '100', 10),
      page: parseInt(filters.page || '1', 10)
    });
    return { success: true, data: results };
  }

  if (id) {
    const result = await service.read(parseInt(id, 10));
    return result || { error: 'Registro no encontrado' };
  }

  return { message: 'Use POST para crear, PUT para actualizar' };
};

export let post: EntryPoints.Restlet.post = async (context) => {
  const data = JSON.parse(context.request.body || '{}');
  const validation = validator.validateForCreate(data);

  if (!validation.valid) {
    return { success: false, errors: validation.errors };
  }

  return await service.create(data);
};

export let put: EntryPoints.Restlet.put = async (context) => {
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

  return await service.update(data);
};

export let delete: EntryPoints.Restlet.delete = async (context) => {
  const id = context.request.parameters.id;
  if (!id) {
    return { success: false, error: 'ID requerido para eliminar' };
  }

  const deleted = await service.delete(parseInt(id, 10));
  return { success: deleted };
};
"@

Set-Content -Path (Join-Path $Ruta "Interface\Restlets\${Prefijo}_${Dominio}_restlet.ts") -Value $restletContent -NoNewline

# Suitelet
$suiteletContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType Suitelet
 */
import { EntryPoints } from 'N/types';
import { ${Dominio}Service } from '../../${domainRoot}/Application/services/${Dominio}.service';
import { ${Dominio}Repository } from '../../${domainRoot}/Infrastructure/persistence/${Dominio}.repository';

const repository = new ${Dominio}Repository();
const service = new ${Dominio}Service(repository);

export let onRequest: EntryPoints.Suitelet.onRequest = async (context) => {
  const response = context.response;
  const request = context.request;
  const method = request.method;

  if (method === 'GET') {
    const id = request.parameters.id;
    const data = id ? await service.read(parseInt(id, 10)) : { message: 'Use POST para crear' };

    response.write({
      body: JSON.stringify(data),
      contentType: 'application/json'
    });
  } else if (method === 'POST') {
    const data = JSON.parse(request.body || '{}');
    const result = await service.create(data);
    response.write({ body: JSON.stringify(result) });
  }
};
"@

Set-Content -Path (Join-Path $Ruta "Interface\Suitelets\${Prefijo}_${Dominio}_suitelet.ts") -Value $suiteletContent -NoNewline

# UserEvent
$ueContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType UserEventScript
 */
import { EntryPoints } from 'N/types';
import { ${Dominio}Service } from '../../${domainRoot}/Application/services/${Dominio}.service';
import { ${Dominio}Repository } from '../../${domainRoot}/Infrastructure/persistence/${Dominio}.repository';

const repository = new ${Dominio}Repository();
const service = new ${Dominio}Service(repository);

export let beforeSubmit: EntryPoints.UserEvent.beforeSubmit = async (context) => {
  if (context.type === context.UserEventType.CREATE || context.type === context.UserEventType.UPDATE) {
    const rec = context.newRecord;
    const name = rec.getValue({ fieldId: 'entity' }) as string;

    if (!name) {
      throw new Error('El campo entity es requerido');
    }
  }
};

export let afterSubmit: EntryPoints.UserEvent.afterSubmit = async (context) => {
  if (context.type === context.UserEventType.CREATE) {
    const rec = context.newRecord;
    console.log(`Nuevo ${Dominio} creado: ${rec.id}`);
  }
};

export let beforeLoad: EntryPoints.UserEvent.beforeLoad = async (context) => {
  if (context.type === context.UserEventType.VIEW) {
    console.log(`Visualizando ${Dominio}: ${context.newRecord.id}`);
  }
};
"@

Set-Content -Path (Join-Path $Ruta "Interface\UserEvents\${Prefijo}_${Dominio}_ue.ts") -Value $ueContent -NoNewline

# Scheduled Script
$scheduledContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType ScheduledScript
 */
import { EntryPoints } from 'N/types';
import { ${Dominio}Service } from '../../${domainRoot}/Application/services/${Dominio}.service';
import { ${Dominio}Repository } from '../../${domainRoot}/Infrastructure/persistence/${Dominio}.repository';

const repository = new ${Dominio}Repository();
const service = new ${Dominio}Service(repository);

export let execute: EntryPoints.Scheduled.execute = async (context) => {
  console.log(`Iniciando Scheduled Script: ${context.scriptId}`);

  const results = await service.list({ pageSize: 100, page: 1 });

  console.log(`Procesando ${results.length} registros`);

  for (const item of results) {
    console.log(`Procesando: ${item.name} (${item.id})`);
  }

  console.log('Scheduled Script completado');
};
"@

Set-Content -Path (Join-Path $Ruta "Interface\Scheduled\${Prefijo}_${Dominio}_sc.ts") -Value $scheduledContent -NoNewline

# MapReduce Script
$mrContent = @"
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType MapReduceScript
 */
import { EntryPoints } from 'N/types';
import search from 'N/search';

export let getInputData: EntryPoints.MapReduce.getInputData = (context) => {
  const searchObj = search.create({
    type: search.Type.INVOICE,
    filters: [],
    columns: ['internalid', 'entity', 'status']
  });

  return searchObj;
};

export let map: EntryPoints.MapReduce.map = (context) => {
  const id = context.value;
  const name = context.newRecord.getValue({ fieldId: 'entity' }) as string;

  context.write({
    key: id,
    value: { id, name, processed: false }
  });
};

export let reduce: EntryPoints.MapReduce.reduce = (context) => {
  const key = context.key;
  const values = context.values.map(v => JSON.parse(v));

  const total = values.length;
  console.log(`Reducer: ${key} - ${total} items`);

  context.write({
    key: key,
    value: { count: total, processed: true }
  });
};

export let summarize: EntryPoints.MapReduce.summarize = (context) => {
  console.log('=== MapReduce Summary ===');

  const errors = context.errors || [];
  if (errors.length > 0) {
    console.log(`Errors: ${errors.length}`);
    errors.forEach(e => console.log(e));
  }

  console.log('MapReduce completado');
};
"@

Set-Content -Path (Join-Path $Ruta "Interface\MapReduce\${Prefijo}_${Dominio}_mr.ts") -Value $mrContent -NoNewline

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
  private static readonly MAX_NAME_LENGTH = 100;
  private static readonly VALID_STATUSES = ['pending', 'active', 'completed', 'cancelled'];

  validate(data: any): ${Dominio}ValidationResult {
    const errors: string[] = [];

    if (!data.name || data.name.trim() === '') {
      errors.push('El campo name es requerido');
    }

    if (data.name && data.name.length > ${Dominio}Validator.MAX_NAME_LENGTH) {
      errors.push(`El campo name no puede exceder ${Dominio}Validator.MAX_NAME_LENGTH} caracteres`);
    }

    if (data.status && !${Dominio}Validator.VALID_STATUSES.includes(data.status)) {
      errors.push(`El status debe ser uno de: ${${Dominio}Validator.VALID_STATUSES.join(', ')}`);
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

    if (typeof data.id !== 'number') {
      errors.push('El ID debe ser un número');
    }

    return { valid: errors.length === 0, errors: [...baseValidation.errors, ...errors] };
  }
}
"@

Set-Content -Path (Join-Path $Ruta "$domainRoot\validations\$Dominio.validation.ts") -Value $validationContent -NoNewline

Write-Success "Archivos creados"

# Crear config de OrkidNS
$configContent = @"
{
  "version": "1.0",
  "project": {
    "name": "$Nombre",
    "prefix": "$Prefijo",
    "type": "grande",
    "domains": ["$Dominio"]
  }
}
"@

Set-Content -Path (Join-Path $Ruta "orkidns.config.json") -Value $configContent -NoNewline

Write-Success "orkidns.config.json creado"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  ✅ Proyecto GRANDE creado exitosamente!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Estructura creada:" -ForegroundColor Cyan
Write-Host "  Modules/$Dominio/"
Write-Host "    Domain/ (entities, value-objects, events)"
Write-Host "    Application/ (use-cases, ports, services)"
Write-Host "    Infrastructure/ (persistence, adapters)"
Write-Host "    validations/"
Write-Host "  Interface/"
Write-Host "    Restlets/, Suitelets/, UserEvents/"
Write-Host "    Scheduled/, MapReduce/"
Write-Host "  Shared/ (domain, utils, constants)"
Write-Host ""