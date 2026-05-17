/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @description UseCase template for OrkidNS
 */
import { {{ENTITY_NAME}}Entity } from '../../../Domain/entities/{{FILE_NAME}}.entity';
import { {{ENTITY_NAME}}RepositoryPort } from '../../ports/outbound/{{FILE_NAME}}.repository.port';
import { {{ENTITY_NAME}}InputDTO } from '../../dtos/{{FILE_NAME}}.input.dto';

export class Create{{ENTITY_NAME}}UseCase {
  constructor(private readonly repository: {{ENTITY_NAME}}RepositoryPort) {}

  async execute(input: {{ENTITY_NAME}}InputDTO): Promise<{ success: boolean; id?: number; error?: string }> {
    const entityResult = {{ENTITY_NAME}}Entity.create(input);
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