/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @description Entity template for OrkidNS
 */
export class {{ENTITY_NAME}}Entity {
  private readonly data: {{ENTITY_NAME}}Data;

  constructor(data: {{ENTITY_NAME}}Data) {
    this.data = data;
  }

  get id(): number | undefined { return this.data.id; }
  get name(): string { return this.data.name; }

  canBeCreated(): boolean {
    return !!this.data.name && this.data.name.length > 0;
  }

  validate(): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    if (!this.data.name) errors.push('name es requerido');
    return { valid: errors.length === 0, errors };
  }

  static create(data: {{ENTITY_NAME}}Data): { success: boolean; entity?: {{ENTITY_NAME}}Entity; error?: string } {
    const entity = new {{ENTITY_NAME}}Entity(data);
    const validation = entity.validate();
    if (!validation.valid) return { success: false, error: validation.errors.join(', ') };
    return { success: true, entity };
  }
}

interface {{ENTITY_NAME}}Data {
  id?: number;
  name: string;
  status?: string;
  metadata?: Record<string, unknown>;
}