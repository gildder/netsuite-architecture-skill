/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @description Repository template for OrkidNS
 */
import search from 'N/search';
import record from 'N/record';
import { {{ENTITY_NAME}}RepositoryPort } from '../../Application/ports/outbound/{{FILE_NAME}}.repository.port';

export class {{ENTITY_NAME}}Repository implements {{ENTITY_NAME}}RepositoryPort {
  async save(data: Record<string, unknown>): Promise<number> {
    const rec = record.create({ type: record.Type.INVOICE });
    if (data.name) rec.setValue({ fieldId: 'entity', value: data.name });
    if (data.status) rec.setValue({ fieldId: 'status', value: data.status });
    return rec.save();
  }

  async findById(id: number): Promise<Record<string, unknown> | null> {
    try {
      const rec = record.load({ type: record.Type.INVOICE, id });
      return {
        id: rec.id,
        entity: rec.getValue({ fieldId: 'entity' }),
        status: rec.getValue({ fieldId: 'status' })
      };
    } catch {
      return null;
    }
  }

  async update(id: number, data: Record<string, unknown>): Promise<boolean> {
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

  async remove(id: number): Promise<boolean> {
    try {
      record.delete({ type: record.Type.INVOICE, id });
      return true;
    } catch {
      return false;
    }
  }

  async findAll(filters?: Record<string, unknown>[]): Promise<Record<string, unknown>[]> {
    const results: Record<string, unknown>[] = [];
    const searchObj = search.create({
      type: search.Type.INVOICE,
      filters: filters as search.Filter[],
      columns: ['internalid', 'entity', 'status']
    });
    const resultSet = searchObj.run();
    let start = 0;
    while (true) {
      const range = resultSet.getRange({ start, end: start + 1000 });
      if (!range.length) break;
      range.forEach((row) => {
        results.push({
          id: parseInt(row.getValue({ name: 'internalid' }) as string),
          entity: row.getValue({ name: 'entity' }),
          status: row.getValue({ name: 'status' })
        });
      });
      start += 1000;
    }
    return results;
  }
}