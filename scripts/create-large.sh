#!/bin/bash

# Script para crear proyecto NETSUITE GRANDE (con carpeta Modules)
# Uso: create-large.sh "ruta" "nombre" "dominio"
# Ejemplo: ./create-large.sh "src/TypeScripts/NuevoSales" "NuevoSales" "Sales"

RUTA=$1
NOMBRE=$2
DOMINIO=$3

if [ -z "$RUTA" ] || [ -z "$NOMBRE" ] || [ -z "$DOMINIO" ]; then
    echo "Error: Faltan parámetros"
    echo "Uso: create-large.sh \"ruta\" \"nombre\" \"dominio\""
    exit 1
fi

echo "Creando proyecto GRANDE: $NOMBRE"
echo "Dominio: $DOMINIO"
echo "Ruta: $RUTA"
echo ""

# Crear estructura completa con Modules
mkdir -p "$RUTA/Modules/$DOMINIO/Domain/entities"
mkdir -p "$RUTA/Modules/$DOMINIO/Domain/value-objects"
mkdir -p "$RUTA/Modules/$DOMINIO/Domain/events"
mkdir -p "$RUTA/Modules/$DOMINIO/Domain/services"
mkdir -p "$RUTA/Modules/$DOMINIO/Application/use-cases"
mkdir -p "$RUTA/Modules/$DOMINIO/Application/ports/inbound"
mkdir -p "$RUTA/Modules/$DOMINIO/Application/ports/outbound"
mkdir -p "$RUTA/Modules/$DOMINIO/Application/dtos"
mkdir -p "$RUTA/Modules/$DOMINIO/Application/services"
mkdir -p "$RUTA/Modules/$DOMINIO/Application/transforms"
mkdir -p "$RUTA/Modules/$DOMINIO/Infrastructure/persistence"
mkdir -p "$RUTA/Modules/$DOMINIO/Infrastructure/adapters"
mkdir -p "$RUTA/Modules/$DOMINIO/validations"
mkdir -p "$RUTA/Interface/Restlets"
mkdir -p "$RUTA/Interface/Suitelets"
mkdir -p "$RUTA/Interface/UserEvents"
mkdir -p "$RUTA/Interface/Scheduled"
mkdir -p "$RUTA/Interface/MapReduce"
mkdir -p "$RUTA/Shared/domain"
mkdir -p "$RUTA/Shared/utils"
mkdir -p "$RUTA/Shared/constants"

echo "Carpetas creadas:"
echo "  Modules/$DOMINIO/Domain/entities"
echo "  Modules/$DOMINIO/Domain/value-objects"
echo "  Modules/$DOMINIO/Domain/events"
echo "  Modules/$DOMINIO/Domain/services"
echo "  Modules/$DOMINIO/Application/use-cases"
echo "  Modules/$DOMINIO/Application/ports/inbound"
echo "  Modules/$DOMINIO/Application/ports/outbound"
echo "  Modules/$DOMINIO/Application/dtos"
echo "  Modules/$DOMINIO/Application/services"
echo "  Modules/$DOMINIO/Application/transforms"
echo "  Modules/$DOMINIO/Infrastructure/persistence"
echo "  Modules/$DOMINIO/Infrastructure/adapters"
echo "  Modules/$DOMINIO/validations"
echo "  Interface/*"
echo "  Shared/*"

# Crear archivos con arquitectura hexagonal completa

# Domain/Entities
cat > "$RUTA/Modules/$DOMINIO/Domain/entities/$DOMINIO.entity.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export class ${DOMINIO}Entity {
  private readonly data: ${DOMINIO}Data;

  constructor(data: ${DOMINIO}Data) {
    this.data = data;
  }

  get id(): number | undefined {
    return this.data.id;
  }

  get name(): string {
    return this.data.name;
  }

  canBeCreated(): boolean {
    return this.isValid();
  }

  private isValid(): boolean {
    return !!this.data.name && this.data.name.length > 0;
  }

  validate(): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    if (!this.data.name) errors.push('name es requerido');
    if (this.data.name && this.data.name.length < 3) errors.push('name debe tener al menos 3 caracteres');
    return { valid: errors.length === 0, errors };
  }

  static create(data: ${DOMINIO}Data): { success: boolean; entity?: ${DOMINIO}Entity; error?: string } {
    const entity = new ${DOMINIO}Entity(data);
    const validation = entity.validate();
    if (!validation.valid) {
      return { success: false, error: validation.errors.join(', ') };
    }
    return { success: true, entity };
  }
}

interface ${DOMINIO}Data {
  id?: number;
  name: string;
  status?: string;
  metadata?: Record<string, unknown>;
}
EOF

# Domain/ValueObjects
cat > "$RUTA/Modules/$DOMINIO/Domain/value-objects/$DOMINIO.id.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export class ${DOMINIO}Id {
  private readonly value: number;

  constructor(value: number) {
    if (value <= 0) {
      throw new Error('${DOMINIO}Id debe ser mayor a 0');
    }
    this.value = value;
  }

  getValue(): number {
    return this.value;
  }

  equals(other: ${DOMINIO}Id): boolean {
    return this.value === other.value;
  }
}
EOF

# Domain/Services
cat > "$RUTA/Modules/$DOMINIO/Domain/services/$DOMINIO.domain.service.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import { ${DOMINIO}Entity } from '../entities/${DOMINIO}.entity';

export class ${DOMINIO}DomainService {
  canTransition(entity: ${DOMINIO}Entity, newStatus: string): boolean {
    const currentStatus = entity['data'].status || 'pending';
    const allowedTransitions: Record<string, string[]> = {
      pending: ['active', 'cancelled'],
      active: ['completed', 'cancelled'],
      completed: [],
      cancelled: []
    };
    return allowedTransitions[currentStatus]?.includes(newStatus) || false;
  }

  calculateHash(entity: ${DOMINIO}Entity): string {
    const data = JSON.stringify(entity['data']);
    let hash = 0;
    for (let i = 0; i < data.length; i++) {
      const char = data.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash).toString(16);
  }
}
EOF

# Application/Ports/Inbound
cat > "$RUTA/Modules/$DOMINIO/Application/ports/inbound/$DOMINIO.input.port.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import { ${DOMINIO}InputDTO } from '../../dtos/${DOMINIO}.input.dto';

export interface ${DOMINIO}InputPort {
  create(input: ${DOMINIO}InputDTO): Promise<{ success: boolean; id?: number; error?: string }>;
  read(id: number): Promise<${DOMINIO}OutputDTO | null>;
  update(id: number, input: ${DOMINIO}InputDTO): Promise<{ success: boolean; error?: string }>;
  delete(id: number): Promise<{ success: boolean; error?: string }>;
  list(filters?: object): Promise<${DOMINIO}OutputDTO[]>;
}

export interface ${DOMINIO}OutputDTO {
  id: number;
  name: string;
  status?: string;
}
EOF

# Application/Ports/Outbound
cat > "$RUTA/Modules/$DOMINIO/Application/ports/outbound/$DOMINIO.repository.port.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export interface ${DOMINIO}RepositoryPort {
  save(data: object): Promise<number>;
  findById(id: number): Promise<object | null>;
  update(id: number, data: object): Promise<boolean>;
  remove(id: number): Promise<boolean>;
  findAll(filters?: object[]): Promise<object[]>;
}
EOF

cat > "$RUTA/Modules/$DOMINIO/Application/ports/outbound/$DOMINIO.adapter.port.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export interface ${DOMINIO}AdapterPort {
  adapt(input: unknown): { success: boolean; data?: object; error?: string };
  serialize(output: object): unknown;
}
EOF

# Application/UseCases
cat > "$RUTA/Modules/$DOMINIO/Application/use-cases/create-${DOMINIO}.usecase.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import { ${DOMINIO}Entity } from '../../Domain/entities/${DOMINIO}.entity';
import { ${DOMINIO}RepositoryPort } from '../ports/outbound/${DOMINIO}.repository.port';
import { ${DOMINIO}InputDTO } from '../dtos/${DOMINIO}.input.dto';

export class Create${DOMINIO}UseCase {
  constructor(private readonly repository: ${DOMINIO}RepositoryPort) {}

  async execute(input: ${DOMINIO}InputDTO): Promise<{ success: boolean; id?: number; error?: string }> {
    const entityResult = ${DOMINIO}Entity.create(input);
    if (!entityResult.success) {
      return { success: false, error: entityResult.error };
    }

    try {
      const id = await this.repository.save(entityResult.entity['data']);
      return { success: true, id };
    } catch (e) {
      return { success: false, error: e.message };
    }
  }
}
EOF

# Application/DTOs
cat > "$RUTA/Modules/$DOMINIO/Application/dtos/${DOMINIO}.input.dto.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export interface ${DOMINIO}InputDTO {
  name: string;
  status?: string;
  metadata?: Record<string, unknown>;
}
EOF

# Infrastructure/Persistence
cat > "$RUTA/Modules/$DOMINIO/Infrastructure/persistence/${DOMINIO}.repository.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import search from 'N/search';
import record from 'N/record';
import { ${DOMINIO}RepositoryPort } from '../../Application/ports/outbound/${DOMINIO}.repository.port';

export class ${DOMINIO}Repository implements ${DOMINIO}RepositoryPort {
  async save(data: object): Promise<number> {
    const rec = record.create({ type: record.Type.INVOICE });
    rec.setValue({ fieldId: 'entity', value: (data as { name: string }).name });
    return rec.save();
  }

  async findById(id: number): Promise<object | null> {
    try {
      const rec = record.load({ type: record.Type.INVOICE, id });
      return {
        id: rec.id,
        name: rec.getValue({ fieldId: 'entity' })
      };
    } catch {
      return null;
    }
  }

  async update(id: number, data: object): Promise<boolean> {
    try {
      const rec = record.load({ type: record.Type.INVOICE, id });
      rec.setValue({ fieldId: 'entity', value: (data as { name: string }).name });
      rec.save();
      return true;
    } catch {
      return false;
    }
  }

  async remove(id: number): Promise<boolean> {
    try {
      record.delete({ type: record.Type.INVOICE, id });
      return true;
    } catch {
      return false;
    }
  }

  async findAll(filters?: object[]): Promise<object[]> {
    const results: object[] = [];
    const searchObj = search.create({
      type: search.Type.INVOICE,
      filters: filters as search.Filter[],
      columns: ['internalid', 'entity']
    });
    const resultSet = searchObj.run();
    let start = 0;
    while (true) {
      const range = resultSet.getRange({ start, end: start + 1000 });
      if (!range.length) break;
      range.forEach((row) => { // eslint-disable-line @typescript-eslint/no-explicit-any
        results.push({
          id: parseInt(row.getValue({ name: 'internalid' }) as string),
          name: row.getValue({ name: 'entity' }) as string
        });
      });
      start += 1000;
    }
    return results;
  }
}
EOF

# Infrastructure/Adapters
cat > "$RUTA/Modules/$DOMINIO/Infrastructure/adapters/external.adapter.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import { ${DOMINIO}AdapterPort } from '../../Application/ports/outbound/${DOMINIO}.adapter.port';

export class External${DOMINIO}Adapter implements ${DOMINIO}AdapterPort {
  adapt(input: unknown): { success: boolean; data?: object; error?: string } {
    if (!input || typeof input !== 'object') {
      return { success: false, error: 'Input inválido' };
    }
    const data = input as Record<string, unknown>;
    return {
      success: true,
      data: {
        name: data.name || '',
        status: data.status || 'pending',
        metadata: data.metadata || {}
      }
    };
  }

  serialize(output: object): unknown {
    return output;
  }
}
EOF

# Validations
cat > "$RUTA/Modules/$DOMINIO/validations/$DOMINIO.validation.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export class ${DOMINIO}Validation {
  static validateCreate(input: unknown): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    if (!input || typeof input !== 'object') {
      errors.push('Input debe ser un objeto');
      return { valid: false, errors };
    }
    const data = input as Record<string, unknown>;
    if (!data.name) errors.push('name es requerido');
    if (data.name && typeof data.name !== 'string') errors.push('name debe ser string');
    return { valid: errors.length === 0, errors };
  }

  static validateUpdate(input: unknown): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    if (!input || typeof input !== 'object') {
      errors.push('Input debe ser un objeto');
      return { valid: false, errors };
    }
    return { valid: errors.length === 0, errors };
  }
}
EOF

# Interface/Restlet
cat > "$RUTA/Interface/Restlets/gw_${DOMINIO}_restlet.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
define(['N/runtime', '../../../Modules/${DOMINIO}/Application/use-cases/create-${DOMINIO}.usecase', '../../../Modules/${DOMINIO}/Infrastructure/persistence/${DOMINIO}.repository'], (runtime, Create${DOMINIO}UseCase, ${DOMINIO}Repository) => {
  const repository = new ${DOMINIO}Repository();
  const createUseCase = new Create${DOMINIO}UseCase(repository);

  return {
    get: (context) => {
      const id = context.request.parameters.id;
      if (id) {
        return repository.findById(parseInt(id));
      }
      return repository.findAll();
    },
    post: async (context) => {
      const body = JSON.parse(context.request.body || '{}');
      return await createUseCase.execute(body);
    },
    put: (context) => {
      const id = context.request.parameters.id;
      const body = JSON.parse(context.request.body || '{}');
      return repository.update(parseInt(id), body);
    },
    delete: (context) => {
      const id = context.request.parameters.id;
      return repository.remove(parseInt(id));
    }
  };
});
EOF

# Shared/Result
cat > "$RUTA/Shared/domain/result.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export class Result<T> {
  private constructor(
    private readonly _isSuccess: boolean,
    private readonly _value?: T,
    private readonly _error?: string
  ) {}

  get isSuccess(): boolean {
    return this._isSuccess;
  }

  get value(): T | undefined {
    return this._value;
  }

  get error(): string | undefined {
    return this._error;
  }

  static ok<T>(value: T): Result<T> {
    return new Result(true, value);
  }

  static fail<T>(error: string): Result<T> {
    return new Result(false, undefined, error);
  }

  map<U>(fn: (value: T) => U): Result<U> {
    if (this._isSuccess && this._value !== undefined) {
      return Result.ok(fn(this._value));
    }
    return Result.fail(this._error || 'Unknown error');
  }

  flatMap<U>(fn: (value: T) => Result<U>): Result<U> {
    if (this._isSuccess && this._value !== undefined) {
      return fn(this._value);
    }
    return Result.fail(this._error || 'Unknown error');
  }
}
EOF

# Shared/Guard
cat > "$RUTA/Shared/domain/guard.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export class Guard {
  static againstNullOrUndefined(value: unknown, name: string): { success: boolean; error?: string } {
    if (value === null || value === undefined) {
      return { success: false, error: `${name} no puede ser null o undefined` };
    }
    return { success: true };
  }

  static againstEmptyString(value: string, name: string): { success: boolean; error?: string } {
    if (!value || value.trim().length === 0) {
      return { success: false, error: `${name} no puede estar vacío` };
    }
    return { success: true };
  }

  static againstInvalidEmail(email: string): { success: boolean; error?: string } {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return { success: false, error: 'Email inválido' };
    }
    return { success: true };
  }

  static composite(...results: { success: boolean; error?: string }[]): { success: boolean; errors: string[] } {
    const errors: string[] = [];
    results.forEach((result) => {
      if (!result.success && result.error) {
        errors.push(result.error);
      }
    });
    return { success: errors.length === 0, errors };
  }
}
EOF

echo ""
echo "Proyecto GRANDE $NOMBRE creado exitosamente!"
echo "Ubicación: $RUTA"
echo ""
echo "Estructura completa con Ports y Use Cases creada"