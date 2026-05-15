#!/bin/bash

# Script para crear proyecto NETSUITE MEDIANO (con o sin carpeta Modules)
# Uso: create-medium.sh "ruta" "nombre" "dominio" "modules"
# Ejemplo: ./create-medium.sh "src/TypeScripts/NuevoSales" "NuevoSales" "Sales" "no"

RUTA=$1
NOMBRE=$2
DOMINIO=$3
MODULES=$4

if [ -z "$RUTA" ] || [ -z "$NOMBRE" ] || [ -z "$DOMINIO" ]; then
    echo "Error: Faltan parámetros"
    echo "Uso: create-medium.sh \"ruta\" \"nombre\" \"dominio\" \"modules\""
    echo "modules: 'yes' o 'no'"
    exit 1
fi

USE_MODULES="false"
if [ "$MODULES" = "yes" ]; then
    USE_MODULES="true"
fi

echo "Creando proyecto MEDIANO: $NOMBRE"
echo "Dominio: $DOMINIO"
echo "Con Modules: $USE_MODULES"
echo ""

# Función para crear estructura con modules
create_with_modules() {
    mkdir -p "$RUTA/Modules/$DOMINIO/Domain/entities"
    mkdir -p "$RUTA/Modules/$DOMINIO/Application/services"
    mkdir -p "$RUTA/Modules/$DOMINIO/Application/transforms"
    mkdir -p "$RUTA/Modules/$DOMINIO/Infrastructure/repositories"
    mkdir -p "$RUTA/Modules/$DOMINIO/validations"
    mkdir -p "$RUTA/Interface/Restlets"
    mkdir -p "$RUTA/Interface/UserEvents"
    mkdir -p "$RUTA/Interface/Suitelets"
    mkdir -p "$RUTA/Shared/utils"
    mkdir -p "$RUTA/Shared/constants"
    echo "Estructura con Modules creada"
}

# Función para crear estructura sin modules
create_without_modules() {
    mkdir -p "$RUTA/$DOMINIO/Domain/entities"
    mkdir -p "$RUTA/$DOMINIO/Application/services"
    mkdir -p "$RUTA/$DOMINIO/Application/transforms"
    mkdir -p "$RUTIA/$DOMINIO/Infrastructure/repositories"
    mkdir -p "$RUTA/$DOMINIO/validations"
    mkdir -p "$RUTA/Interface/Restlets"
    mkdir -p "$RUTA/Interface/UserEvents"
    mkdir -p "$RUTA/Interface/Suitelets"
    mkdir -p "$RUTA/Shared/utils"
    mkdir -p "$RUTA/Shared/constants"
    echo "Estructura sin Modules creada"
}

if [ "$USE_MODULES" = "true" ]; then
    create_with_modules
    PREFIX="Modules/$DOMINIO"
else
    create_without_modules
    PREFIX="$DOMINIO"
fi

# Crear archivos del dominio

cat > "$RUTA/$PREFIX/Domain/entities/$DOMINIO.entity.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export class ${DOMINIO}Entity {
  private data: ${DOMINIO}Data;

  constructor(data: ${DOMINIO}Data) {
    this.data = data;
  }

  canBeCreated(): boolean {
    return !!this.data.name;
  }

  validate(): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    if (!this.data.name) errors.push('name es requerido');
    return { valid: errors.length === 0, errors };
  }

  static create(data: ${DOMINIO}Data): ${DOMINIO}Entity {
    return new ${DOMINIO}Entity(data);
  }
}

interface ${DOMINIO}Data {
  name: string;
  id?: number;
}
EOF

cat > "$RUTA/$PREFIX/Application/services/$DOMINIO.service.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
import record from 'N/record';
import { ${DOMINIO}Entity } from '../../Domain/entities/${DOMINIO}.entity';
import { ${DOMINIO}Repository } from '../../Infrastructure/repositories/${DOMINIO}.repository';

export class ${DOMINIO}Service {
  private repository: ${DOMINIO}Repository;

  constructor() {
    this.repository = new ${DOMINIO}Repository();
  }

  create(data: ${DOMINIO}Input): { success: boolean; id?: number; error?: string } {
    const entity = ${DOMINIO}Entity.create(data);
    const validation = entity.validate();
    if (!validation.valid) {
      return { success: false, error: validation.errors.join(', ') };
    }

    try {
      const rec = record.create({ type: record.Type.INVOICE });
      rec.setValue({ fieldId: 'entity', value: data.name });
      const id = rec.save();
      return { success: true, id };
    } catch (e) {
      return { success: false, error: e.message };
    }
  }

  read(id: number): ${DOMENIO}Output | null {
    return this.repository.findById(id);
  }

  update(id: number, data: ${DOMINIO}Input): { success: boolean; error?: string } {
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

interface ${DOMINIO}Input {
  name: string;
}

interface ${DOMINIO}Output {
  id: number;
  name: string;
}
EOF

cat > "$RUTA/$PREFIX/Infrastructure/repositories/$DOMINIO.repository.ts" << 'EOF'
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
      range.forEach((row) => { // eslint-disable-line @typescript-eslint/no-explicit-any
        results.push({
          id: parseInt(row.getValue({ name: 'internalid' }) as string),
          name: row.getValue({ name: 'entity' }) as string
        });
      });
      start += 1000;
    }
    return results;
  }

  findById(id: number): ${DOMINIO}Output | null {
    const results = this.findAll([['internalid', 'is', id]]);
    return results.length > 0 ? results[0] : null;
  }
}

interface ${DOMINIO}Output {
  id: number;
  name: string;
}
EOF

echo ""
echo "Proyecto $NOMBRE creado exitosamente!"
echo "Ubicación: $RUTA"