/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType UserEventScript
 */

import { EntryPoints } from 'N/types';
import { {{EntityName}}Service } from '../../{{domain}}/Application/services/{{entityName}}.service';
import { {{EntityName}}Repository } from '../../{{domain}}/Infrastructure/persistence/{{entityName}}.repository';

const repository = new {{EntityName}}Repository();
const service = new {{EntityName}}Service(repository);

export let beforeLoad: EntryPoints.UserEvent.beforeLoad = (context) => {
  const type = context.type;
  const form = context.form;

  if (type === context.UserEventType.VIEW || type === context.UserEventType.EDIT) {
    const record = context.newRecord;
    const id = record.id;

    console.log(`BeforeLoad: Visualizando registro ${id}`);
  }

  if (type === context.UserEventType.CREATE) {
    const field = form.addField({
      id: 'custpage_custom_field',
      type: 'text',
      label: 'Campo Personalizado'
    });
    field.defaultValue = 'Valor inicial';

    const button = form.addButton({
      id: 'custpage_custom_button',
      label: 'Mi Botón',
      functionName: 'myCustomFunction()'
    });
  }
};

export let beforeSubmit: EntryPoints.UserEvent.beforeSubmit = (context) => {
  const type = context.type;
  const newRecord = context.newRecord;

  if (type === context.UserEventType.CREATE || type === context.UserEventType.EDIT) {
    const name = newRecord.getValue({ fieldId: 'entity' });

    if (!name) {
      throw new Error('El campo entity es requerido');
    }

    if (type === context.UserEventType.CREATE) {
      console.log(`BeforeSubmit: Creando nuevo registro`);
    } else {
      console.log(`BeforeSubmit: Actualizando registro ${newRecord.id}`);
    }
  }

  if (type === context.UserEventType.DELETE) {
    const id = context.oldRecord.id;
    console.log(`BeforeSubmit: Eliminando registro ${id}`);
  }
};

export let afterSubmit: EntryPoints.UserEvent.afterSubmit = (context) => {
  const type = context.type;
  const newRecord = context.newRecord;
  const oldRecord = context.oldRecord;

  if (type === context.UserEventType.CREATE) {
    const id = newRecord.id;
    console.log(`AfterSubmit: Registro creado con ID ${id}`);

    try {
      const result = service.read(id);
      if (result) {
        console.log(`Registro leído exitosamente: ${result.name}`);
      }
    } catch (e) {
      console.error(`Error al procesar registro creado: ${e.message}`);
    }
  }

  if (type === context.UserEventType.EDIT) {
    const id = newRecord.id;
    console.log(`AfterSubmit: Registro ${id} actualizado`);

    if (oldRecord) {
      const oldName = oldRecord.getValue({ fieldId: 'entity' });
      const newName = newRecord.getValue({ fieldId: 'entity' });

      if (oldName !== newName) {
        console.log(`Nombre cambiado de "${oldName}" a "${newName}"`);
      }
    }
  }

  if (type === context.UserEventType.DELETE) {
    const id = oldRecord.id;
    console.log(`AfterSubmit: Registro ${id} eliminado`);
  }
};