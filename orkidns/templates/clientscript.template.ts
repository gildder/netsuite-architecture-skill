/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType ClientScript
 */

import { EntryPoints } from 'N/types';
import { {{EntityName}}Service } from '../../{{domain}}/Application/services/{{entityName}}.service';
import { {{EntityName}}Repository } from '../../{{domain}}/Infrastructure/persistence/{{entityName}}.repository';
import { {{EntityName}}Validator } from '../../{{domain}}/validations/{{entityName}}.validation';

const repository = new {{EntityName}}Repository();
const service = new {{EntityName}}Service(repository);
const validator = new {{EntityName}}Validator();

export let pageInit: EntryPoints.ClientScript.pageInit = (context) => {
  const currentRecord = context.currentRecord;
  const mode = context.mode;

  if (mode === 'create') {
    console.log('Inicializando formulario de creación');
  } else if (mode === 'edit') {
    console.log('Cargando registro para edición');
  }
};

export let validateField: EntryPoints.ClientScript.validateField = (context) => {
  const fieldId = context.fieldId;
  const value = context.value;

  if (fieldId === 'entity') {
    if (!value || value.trim() === '') {
      alert('El campo entity es requerido');
      return false;
    }
  }

  return true;
};

export let validateLine: EntryPoints.ClientScript.validateLine = (context) => {
  const sublistId = context.sublistId;

  if (sublistId === 'item') {
    const currentRecord = context.currentRecord;
    const quantity = currentRecord.getCurrentSublistValue({
      sublistId: 'item',
      fieldId: 'quantity'
    });

    if (quantity <= 0) {
      alert('La cantidad debe ser mayor a 0');
      return false;
    }
  }

  return true;
};

export let validateInsert: EntryPoints.ClientScript.validateInsert = (context) => {
  const sublistId = context.sublistId;
  console.log(`Validando inserción en sublist: ${sublistId}`);
  return true;
};

export let validateDelete: EntryPoints.ClientScript.validateDelete = (context) => {
  const sublistId = context.sublistId;
  console.log(`Validando eliminación en sublist: ${sublistId}`);
  return true;
};

export let fieldChanged: EntryPoints.ClientScript.fieldChanged = (context) => {
  const fieldId = context.fieldId;
  const value = context.value;

  if (fieldId === 'entity') {
    console.log(`Entity cambiado: ${value}`);
  }
};

export let postSourcing: EntryPoints.ClientScript.postSourcing = (context) => {
  const fieldId = context.fieldId;
  console.log(`Post-sourcing field: ${fieldId}`);
};

export let sublistChanged: EntryPoints.ClientScript.sublistChanged = (context) => {
  const sublistId = context.sublistId;
  const action = context.operation;

  if (sublistId === 'item' && action === 'change') {
    console.log('Sublista items cambiada');
  }
};

export let lineInit: EntryPoints.ClientScript.lineInit = (context) => {
  const sublistId = context.sublistId;
  const currentRecord = context.currentRecord;

  if (sublistId === 'item') {
    const itemField = currentRecord.getCurrentSublistField({
      sublistId: 'item',
      fieldId: 'item'
    });
    console.log('Inicializando línea de items');
  }
};

export let saveRecord: EntryPoints.ClientScript.saveRecord = (context) => {
  const currentRecord = context.currentRecord;

  const entity = currentRecord.getValue({ fieldId: 'entity' });
  if (!entity) {
    alert('El campo entity es requerido');
    return false;
  }

  console.log('Guardando registro...');
  return true;
};