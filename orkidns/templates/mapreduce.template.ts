/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType MapReduceScript
 */

import { EntryPoints } from 'N/types';
import search from 'N/search';
import { {{EntityName}}Service } from '../../{{domain}}/Application/services/{{entityName}}.service';
import { {{EntityName}}Repository } from '../../{{domain}}/Infrastructure/persistence/{{entityName}}.repository';

const repository = new {{EntityName}}Repository();
const service = new {{EntityName}}Service(repository);

export let getInputData: EntryPoints.MapReduce.getInputData = (context) => {
  if (context.mode === context.Mode.INIT) {
    console.log('MapReduce: Fase INIT');
  }

  const searchFilters: string[][] = [];
  const searchColumns = [
    'internalid',
    'entity',
    'status',
    'trandate',
    'amount'
  ];

  const searchObj = search.create({
    type: search.Type.INVOICE,
    filters: searchFilters,
    columns: searchColumns.map(name => search.createColumn({ name }))
  });

  console.log('MapReduce: Obteniendo datos de búsqueda');
  return searchObj;
};

export let map: EntryPoints.MapReduce.map = (context) => {
  if (context.mode === context.Mode.MAP) {
    console.log('MapReduce: Fase MAP');
  }

  const value = context.value;
  const newRecord = context.newRecord;

  const id = newRecord.getValue({ name: 'internalid' }) as string;
  const entity = newRecord.getValue({ name: 'entity' }) as string;
  const status = newRecord.getValue({ name: 'status' }) as string;
  const amount = newRecord.getValue({ name: 'amount' }) as string;

  console.log(`Procesando registro: ${id} - ${entity}`);

  if (status === 'Pending') {
    context.write({
      key: 'pending',
      value: {
        id,
        entity,
        amount: parseFloat(amount || '0'),
        processed: false
      }
    });
  } else if (status === 'Paid') {
    context.write({
      key: 'paid',
      value: {
        id,
        entity,
        amount: parseFloat(amount || '0'),
        processed: true
      }
    });
  } else {
    context.write({
      key: 'other',
      value: {
        id,
        entity,
        amount: parseFloat(amount || '0'),
        processed: false
      }
    });
  }
};

export let reduce: EntryPoints.MapReduce.reduce = (context) => {
  if (context.mode === context.Mode.REDUCE) {
    console.log('MapReduce: Fase REDUCE');
  }

  const key = context.key;
  const values = context.values;

  console.log(`Reduce: Procesando ${values.length} registros para key: ${key}`);

  let totalAmount = 0;
  const processedItems: any[] = [];

  for (const val of values) {
    const item = JSON.parse(val);
    totalAmount += item.amount;
    processedItems.push(item);
  }

  const result = {
    key,
    count: processedItems.length,
    totalAmount,
    processed: true,
    items: processedItems
  };

  console.log(`Reduce Result: ${result.count} items, Total: ${totalAmount}`);

  context.write({
    key: key,
    value: JSON.stringify(result)
  });
};

export let summarize: EntryPoints.MapReduce.summarize = (context) => {
  console.log('========================================');
  console.log('MapReduce: Fase SUMMARY');
  console.log('========================================');

  console.log(`Total keys processadas: ${context.output.length}`);

  if (context.errors && context.errors.length > 0) {
    console.log(`Errores encontrados: ${context.errors.length}`);
    for (const error of context.errors) {
      console.error(`Error: ${error}`);
    }
  }

  const results: { key: string; value: string }[] = [];

  for (const output of context.output) {
    try {
      const parsed = JSON.parse(output.value);
      console.log(`${output.key}: ${parsed.count} items, Total: ${parsed.totalAmount}`);
    } catch (e) {
      console.log(`${output.key}: ${output.value}`);
    }
  }

  console.log('========================================');
  console.log('MapReduce completado');
  console.log('========================================');
};