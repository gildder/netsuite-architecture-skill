/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 * @NScriptType Portlet
 */

import { EntryPoints } from 'N/types';
import search from 'N/search';

export let render: EntryPoints.Portlet.render = (context) => {
  const portlet = context.portlet;
  const columns = context.columns;

  portlet.addColumn({
    id: 'internalid',
    type: 'text',
    label: 'ID',
    align: 'LEFT'
  });

  portlet.addColumn({
    id: 'entity',
    type: 'text',
    label: 'Cliente',
    align: 'LEFT'
  });

  portlet.addColumn({
    id: 'trandate',
    type: 'date',
    label: 'Fecha',
    align: 'LEFT'
  });

  portlet.addColumn({
    id: 'amount',
    type: 'currency',
    label: 'Monto',
    align: 'RIGHT'
  });

  portlet.addColumn({
    id: 'status',
    type: 'text',
    label: 'Estado',
    align: 'CENTER'
  });

  portlet.addButton({
    id: 'custpage_refresh',
    label: 'Actualizar',
    functionName: 'refreshPortlet()'
  });

  portlet.addButton({
    id: 'custpage_export',
    label: 'Exportar',
    functionName: 'exportData()'
  });

  const searchObj = search.create({
    type: search.Type.INVOICE,
    filters: [
      ['status', 'anyof', ['Pending', 'Partially Paid']],
      'AND',
      ['trandate', 'within', ['last30days']]
    ],
    columns: [
      'internalid',
      'entity',
      'trandate',
      'amount',
      'status'
    ]
  });

  const resultSet = searchObj.run();
  let start = 0;

  while (true) {
    const range = resultSet.getRange({ start, end: start + 50 });
    if (!range || range.length === 0) break;

    for (const row of range) {
      portlet.addRow({
        id: row.getValue({ name: 'internalid' }) as string,
        entity: row.getValue({ name: 'entity' }) as string,
        trandate: row.getValue({ name: 'trandate' }) as string,
        amount: row.getValue({ name: 'amount' }) as string,
        status: row.getValue({ name: 'status' }) as string
      });
    }

    start += 50;

    if (start >= 100) break;
  }

  if (start === 0) {
    portlet.setHtml('<div style="padding:20px;text-align:center;color:#666;">No hay datos para mostrar</div>');
  }
};

export let resize: EntryPoints.Portlet.resize = (context) => {
  console.log('Portlet redimensionado');
};

export let columnClicked: EntryPoints.Portlet.columnClicked = (context) => {
  const columnId = context.columnId;
  console.log(`Columna clickeada: ${columnId}`);
};

export let rowClicked: EntryPoints.Portlet.rowClicked = (context) => {
  const id = context.id;
  const recordType = context.recordType;

  const url = `/app/common/search/searchresults.nl?searchid=-1&recordtype=${recordType}&id=${id}`;
  window.location.href = url;
};

export let refresh: EntryPoints.Portlet.refresh = (context) => {
  console.log('Portlet actualizado');
};