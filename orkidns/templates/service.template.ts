/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @description Service template for OrkidNS
 */
import record from 'N/record';
import { {{ENTITY_NAME}}Entity } from '../../../Domain/entities/{{FILE_NAME}}.entity';
import { {{ENTITY_NAME}}Repository } from '../../../Infrastructure/persistence/{{FILE_NAME}}.repository';

export class {{ENTITY_NAME}}Service {
  private repository: {{ENTITY_NAME}}Repository;

  constructor() {
    this.repository = new {{ENTITY_NAME}}Repository();
  }

  create(data: {{ENTITY_NAME}}Input): { success: boolean; id?: number; error?: string } {
    const entityResult = {{ENTITY_NAME}}Entity.create(data);
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

  read(id: number): {{ENTITY_NAME}}Output | null {
    return this.repository.findById(id);
  }

  update(id: number, data: {{ENTITY_NAME}}Input): { success: boolean; error?: string } {
    try {
      const rec = record.load({ type: record.Type.INVOICE, id });
      rec.setValue({ fieldId: 'entity', value: data.name });
      rec.save();
      return { success: true };
    } catch (e) {
      return { success: false, error: e.message };
    }
  }

  delete(id: number): { success: boolean; error?: string } {
    try {
      record.delete({ type: record.Type.INVOICE, id });
      return { success: true };
    } catch (e) {
      return { success: false, error: e.message };
    }
  }
}

interface {{ENTITY_NAME}}Input { name: string; status?: string; }
interface {{ENTITY_NAME}}Output { id: number; name: string; status?: string; }