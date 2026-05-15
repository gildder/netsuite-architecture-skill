#!/bin/bash

# Script para crear proyecto NETSUITE PEQUEÑO (sin carpeta Modules)
# Uso: create-small.sh "ruta" "nombre" "dominio"
# Ejemplo: ./create-small.sh "src/TypeScripts/NuevoSales" "NuevoSales" "Sales"

RUTA=$1
NOMBRE=$2
DOMINIO=$3

if [ -z "$RUTA" ] || [ -z "$NOMBRE" ] || [ -z "$DOMINIO" ]; then
    echo "Error: Faltan parámetros"
    echo "Uso: create-small.sh \"ruta\" \"nombre\" \"dominio\""
    exit 1
fi

echo "Creando proyecto PEQUEÑO: $NOMBRE"
echo "Dominio: $DOMINIO"
echo "Ruta: $RUTA"
echo ""

# Crear estructura de carpetas
mkdir -p "$RUTA/$DOMINIO"
mkdir -p "$RUTA/Interface"
mkdir -p "$RUTA/Shared/utils"

# Crear archivos básicos

# Dominio/types.ts
cat > "$RUTA/$DOMINIO/$DOMINIO.types.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export interface ${DOMINIO}Input {
  id?: number;
  name: string;
}

export interface ${DOMINIO}Output {
  id: number;
  name: string;
}
EOF

# Dominio/service.ts
cat > "$RUTA/$DOMINIO/$DOMINIO.service.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import record from 'N/record';

export class ${DOMINIO}Service {
  create(data: ${DOMINIO}Input): number {
    const rec = record.create({ type: record.Type.INVOICE });
    rec.setValue({ fieldId: 'entity', value: data.name });
    return rec.save();
  }

  read(id: number): ${DOMINIO}Output | null {
    try {
      const rec = record.load({
        type: record.Type.INVOICE,
        id: id
      });
      return {
        id: rec.id,
        name: rec.getValue({ fieldId: 'entity' }) as string
      };
    } catch (e) {
      return null;
    }
  }

  update(id: number, data: ${DOMINIO}Input): boolean {
    try {
      const rec = record.load({
        type: record.Type.INVOICE,
        id: id
      });
      rec.setValue({ fieldId: 'entity', value: data.name });
      rec.save();
      return true;
    } catch (e) {
      return false;
    }
  }

  delete(id: number): boolean {
    try {
      record.delete({ type: record.Type.INVOICE, id: id });
      return true;
    } catch (e) {
      return false;
    }
  }
}
EOF

# Dominio/repository.ts
cat > "$RUTA/$DOMINIO/$DOMINIO.repository.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import search from 'N/search';

export class ${DOMINIO}Repository {
  findAll(filters?: object[]): ${DOMINIO}Output[] {
    const results: ${DOMINIO}Output[] = [];
    const searchObj = search.create({
      type: search.Type.INVOICE,
      filters: filters || [],
      columns: ['internalid', 'entity']
    });
    const resultSet = searchObj.run();
    let start = 0;
    while (true) {
      const range = resultSet.getRange({ start, end: start + 1000 });
      if (!range.length) break;
      range.forEach((row) => {
        results.push({
          id: parseInt(row.getValue({ name: 'internalid' }) as string, // eslint-disable-line @typescript-eslint/no-explicit-any
          name: row.getValue({ name: 'entity' }) as string // eslint-disable-line @typescript-eslint/no-explicit-any
        });
      });
      start += 1000;
    }
    return results;
  }

  findById(id: number): ${DOMINIO}Output | null {
    const results = this.findAll([
      ['internalid', 'is', id]
    ]);
    return results.length > 0 ? results[0] : null;
  }
}
EOF

# Interface/Restlet (ejemplo)
cat > "$RUTA/Interface/gw_${DOMINIO}_restlet.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
define(['./../${DOMINIO}/${DOMINIO}.service'], (/${DOMINIO}Service) => {
  const service = new ${DOMINIO}Service();

  return {
    get: (context) => {
      const id = context.request.parameters.id;
      return id ? service.read(parseInt(id)) : service.findAll();
    },
    post: (context) => {
      return { id: service.create(context.request.body) };
    },
    put: (context) => {
      const id = context.request.parameters.id;
      return { success: service.update(parseInt(id), context.request.body) };
    },
    delete: (context) => {
      const id = context.request.parameters.id;
      return { success: service.delete(parseInt(id)) };
    }
  };
});
EOF

echo "Proyecto $NOMBRE creado exitosamente!"
echo "Ubicación: $RUTA"
echo ""
echo "Estructura creada:"
echo "  $DOMINIO/"
echo "    - $DOMINIO.service.ts"
echo "    - $DOMINIO.repository.ts"
echo "    - $DOMINIO.types.ts"
echo "  Interface/"
echo "    - gw_${DOMINIO}_restlet.ts"
echo "  Shared/"
echo "    - utils/"
echo ""