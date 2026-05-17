/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @description Validation template for OrkidNS
 */
export class {{ENTITY_NAME}}Validation {
  static validateCreate(input: unknown): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    if (!input || typeof input !== 'object') {
      errors.push('Input debe ser un objeto');
      return { valid: false, errors };
    }
    const data = input as Record<string, unknown>;
    if (!data.name) errors.push('name es requerido');
    if (data.name && typeof data.name !== 'string') errors.push('name debe ser string');
    if (data.name && (data.name as string).length < 3) errors.push('name debe tener al menos 3 caracteres');
    return { valid: errors.length === 0, errors };
  }

  static validateUpdate(input: unknown): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    if (!input || typeof input !== 'object') {
      errors.push('Input debe ser un objeto');
      return { valid: false, errors };
    }
    const data = input as Record<string, unknown>;
    if (data.name !== undefined && typeof data.name !== 'string') {
      errors.push('name debe ser string');
    }
    return { valid: errors.length === 0, errors };
  }

  static validateStatus(status: string): { valid: boolean; error?: string } {
    const validStatuses = ['pending', 'active', 'completed', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return { valid: false, error: `Status inválido. Debe ser uno de: ${validStatuses.join(', ')}` };
    }
    return { valid: true };
  }
}