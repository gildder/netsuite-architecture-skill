/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @description Port template for OrkidNS
 */
export interface {{ENTITY_NAME}}InputPort {
  create(input: {{ENTITY_NAME}}InputDTO): Promise<{ success: boolean; id?: number; error?: string }>;
  read(id: number): Promise<{{ENTITY_NAME}}OutputDTO | null>;
  update(id: number, input: {{ENTITY_NAME}}InputDTO): Promise<{ success: boolean; error?: string }>;
  delete(id: number): Promise<{ success: boolean; error?: string }>;
  list(filters?: Record<string, unknown>): Promise<{{ENTITY_NAME}}OutputDTO[]>;
}

export interface {{ENTITY_NAME}}InputDTO {
  name: string;
  status?: string;
  metadata?: Record<string, unknown>;
}

export interface {{ENTITY_NAME}}OutputDTO {
  id: number;
  name: string;
  status?: string;
  metadata?: Record<string, unknown>;
}