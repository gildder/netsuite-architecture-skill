/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType ScheduledScript
 */

import { EntryPoints } from 'N/types';
import search from 'N/search';
import { {{EntityName}}Service } from '../../{{domain}}/Application/services/{{entityName}}.service';
import { {{EntityName}}Repository } from '../../{{domain}}/Infrastructure/persistence/{{entityName}}.repository';

const repository = new {{EntityName}}Repository();
const service = new {{EntityName}}Service(repository);

export let execute: EntryPoints.Scheduled.execute = async (context) => {
  console.log('========================================');
  console.log(`Scheduled Script iniciado: ${context.scriptId}`);
  console.log(`Deployment ID: ${context.deploymentId}`);
  console.log('========================================');

  if (context.type === context.ContextType.ADMIN) {
    console.log('Ejecución iniciada por Administrador');
  } else if (context.type === context.ContextType.USER_INTERFACE) {
    console.log('Ejecución iniciada desde UI');
  } else if (context.type === context.ContextType.SCHEDULED) {
    console.log('Ejecución programada');
  }

  const params = context.request?.parameters || {};

  console.log('Parámetros:', JSON.stringify(params));

  try {
    console.log('Obteniendo registros pendientes...');

    const searchObj = search.create({
      type: search.Type.INVOICE,
      filters: [
        ['status', 'is', 'Pending'],
        'AND',
        ['dateCreated', 'within', 'last30days']
      ],
      columns: [
        'internalid',
        'entity',
        'status',
        'trandate',
        'amount'
      ]
    });

    const resultSet = searchObj.run();
    const allResults: any[] = [];

    let start = 0;
    while (true) {
      const range = resultSet.getRange({ start, end: start + 1000 });
      if (!range || range.length === 0) break;

      for (const row of range) {
        allResults.push({
          id: parseInt(row.getValue({ name: 'internalid' }) as string, 10),
          entity: row.getValue({ name: 'entity' }) as string,
          status: row.getValue({ name: 'status' }) as string,
          trandate: row.getValue({ name: 'trandate' }) as string,
          amount: parseFloat(row.getValue({ name: 'amount' }) as string || '0')
        });
      }

      start += 1000;
      console.log(`Procesados ${allResults.length} registros...`);
    }

    console.log(`Total de registros encontrados: ${allResults.length}`);

    let processed = 0;
    let errors = 0;

    for (const record of allResults) {
      try {
        console.log(`Procesando registro ${record.id} - ${record.entity}`);

        const result = await service.read(record.id);

        if (result) {
          console.log(`  ✓ Registro ${record.id} procesado exitosamente`);
          processed++;
        } else {
          console.log(`  ⚠ Registro ${record.id} no encontrado`);
        }

      } catch (e) {
        console.error(`  ✗ Error procesando registro ${record.id}: ${e.message}`);
        errors++;
      }
    }

    console.log('========================================');
    console.log(`Resumen:`);
    console.log(`  - Total registros: ${allResults.length}`);
    console.log(`  - Procesados: ${processed}`);
    console.log(`  - Errores: ${errors}`);
    console.log('========================================');

  } catch (e) {
    console.error(`Error en Scheduled Script: ${e.message}`);
    console.error(e.stack);
    throw e;
  }

  console.log('Scheduled Script completado');
};