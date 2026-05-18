#!/bin/bash

# Script para crear proyecto NetSuite completo desde template
# Uso: create-project.sh "ruta" "nombre" "dominio" "tipo"
# Ejemplo: ./create-project.sh "C:\proyectos\mi-proyecto" "mi-proyecto" "Sales" "pequeño"

RUTA=$1
NOMBRE=$2
DOMINIO=$3
TIPO=$4

TEMPLATE_REPO="https://github.com/gildder/netsuite-ts-sdf-template.git"

if [ -z "$RUTA" ] || [ -z "$NOMBRE" ] || [ -z "$DOMINIO" ] || [ -z "$TIPO" ]; then
    echo "Error: Faltan parámetros"
    echo "Uso: create-project.sh \"ruta\" \"nombre\" \"dominio\" \"tipo\""
    echo "tipo: pequeño, mediano-sin-modules, mediano-con-modules, grande"
    exit 1
fi

echo "=========================================="
echo "Creando proyecto NetSuite: $NOMBRE"
echo "Dominio: $DOMINIO"
echo "Tipo: $TIPO"
echo "Ruta: $RUTA"
echo "=========================================="
echo ""

# 1. Clonar el repositorio template (directamente en la carpeta raíz)
echo "📦 1. Clonando repositorio template..."
if [ -d "$RUTA" ]; then
    echo "   La carpeta ya existe. Limpiando..."
    rm -rf "$RUTA"
fi
mkdir -p "$RUTA"
cd "$RUTA"
git clone "$TEMPLATE_REPO" .
echo "   ✓ Template clonado directamente en $RUTA"
echo ""

# 2. Actualizar package.json
echo "📝 2. Actualizando package.json..."
cd "$RUTA"
sed -i "s/\"name\": \"netsuite-ts-sdf-template\"/\"name\": \"$NOMBRE\"/g" package.json
sed -i "s/\"displayName\": \"NetSuite TypeScript SDF Project Template\"/\"displayName\": \"NetSuite $DOMINIO Project\"/g" package.json
sed -i "s/\"description\": \"A high-integrity foundation for TypeScript-based SuiteScript 2.1 development and deployment via SDF.\"/\"description\": \"NetSuite TypeScript project for $DOMINIO - $TIPO\"/g" package.json
echo "   ✓ package.json actualizado"
echo ""

# 3. Actualizar tsconfig.json
echo "⚙️  3. Actualizando tsconfig.json..."
sed -i "s|src/TypeScripts/idev-engineering-netsuite|src/TypeScripts/$NOMBRE|g" tsconfig.json
sed -i "s|src/FileCabinet/SuiteScripts/idev-engineering-netsuite|src/FileCabinet/SuiteScripts/$NOMBRE|g" tsconfig.json
sed -i "s|src/TypeScripts/idev-engineering-netsuite/\*\*|src/TypeScripts/$NOMBRE/**|g" tsconfig.json
# CORRECCIÓN 1: Eliminar esModuleInterop que contamina output AMD
sed -i 's/"esModuleInterop": true,//g' tsconfig.json
echo "   ✓ tsconfig.json actualizado (sin esModuleInterop)"
echo ""

# 4. Corregir biome.json (patrón de include + overrides para JS compilados)
echo "🔧 4. Corrigiendo biome.json..."
# Corregir patrón de include (Windows fix)
sed -i 's/\*\.{ts,json}/\*.ts", "\*.json/g' biome.json
# Agregar archivos JS compilados al include
sed -i "s|src/FileCabinet/SuiteScripts/\[PROJECT_NAME\]|src/FileCabinet/SuiteScripts/$NOMBRE|g" biome.json
# Agregar overrides para src/FileCabinet (desactivar linter, mantener formatter)
sed -i '/"ignore": \["node_modules\/\*\*"\]/a\  },\n  "overrides": [\n    {\n      "include": ["src\/FileCabinet\/**"],\n      "linter": { "enabled": false },\n      "organizeImports": { "enabled": false }\n    }\n  ]' biome.json
echo "   ✓ biome.json corregido (include + overrides)"
echo ""

# 5. Copiar script prepend-headers.js para inyección de JSDoc
echo "📄 5. Copiando script prepend-headers.js..."
SCRIPT_PATH="C:\Users\gguerrero\Documents\000 desarrollo\netsuite-architecture-skill\scripts\prepend-headers.js"
mkdir -p "$RUTA/scripts"
cp "$SCRIPT_PATH" "$RUTA/scripts/prepend-headers.js"
echo "   ✓ Script prepend-headers.js copiado"
echo ""

# 6. Actualizar package.json para incluir build completo (tsc + JSDoc + format)
echo "📝 6. Actualizando package.json (build completo)..."
sed -i "s|\"build\": \"tsc\"|\"build\": \"tsc \\&\\& node scripts/prepend-headers.js \\&\\& biome format --write src/FileCabinet/SuiteScripts/$NOMBRE\"|g" package.json
# También corregir el script de lint
sed -i "s|\"lint\": \"biome check \.\"|\"lint\": \"biome check src/TypeScripts/$NOMBRE\"|g" package.json
# Agregar script format si no existe
if ! grep -q '"format":' package.json; then
    sed -i 's|"lint:fix": "biome check --write ."|"format": "biome format --write src/FileCabinet/SuiteScripts/'$NOMBRE'",\n    "lint:fix": "biome check --write src/TypeScripts/'$NOMBRE'"|g' package.json
fi
echo "   ✓ package.json actualizado (build: tsc + prepend-headers + biome format)"
echo ""

# 5. Actualizar deploy.xml
echo "📄 4. Actualizando deploy.xml..."
PROJECT_NAME_UPPER=$(echo "$NOMBRE" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
sed -i "s|idev-engineering-netsuite|$NOMBRE|g" src/deploy.xml
echo "   ✓ deploy.xml actualizado"
echo ""

# 5. Actualizar manifest.xml
echo "📄 5. Actualizando manifest.xml..."
sed -i "s|<projectname>.*</projectname>|<projectname>${PROJECT_NAME_UPPER}_Project</projectname>|g" src/manifest.xml
echo "   ✓ manifest.xml actualizado"
echo ""

# 6. Crear estructura TypeScripts según tipo
echo "🏗️  4. Creando estructura TypeScripts..."

case "$TIPO" in
    "pequeño")
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/$DOMINIO"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Interface"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Shared/utils"
        ;;
    "mediano-sin-modules")
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/$DOMINIO/Domain/entities"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/$DOMINIO/Application/services"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/$DOMINIO/Application/transforms"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/$DOMINIO/Infrastructure/repositories"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/$DOMINIO/validations"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Interface/Restlets"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Shared/utils"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Shared/constants"
        ;;
    "mediano-con-modules"|"grande")
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Domain/entities"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Domain/value-objects"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Domain/events"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Domain/services"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Application/use-cases"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Application/ports/inbound"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Application/ports/outbound"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Application/dtos"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Application/services"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Application/transforms"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Infrastructure/persistence"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Infrastructure/adapters"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/validations"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Interface/Restlets"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Interface/Suitelets"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Interface/UserEvents"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Shared/domain"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Shared/utils"
        mkdir -p "$RUTA/src/TypeScripts/$NOMBRE/Shared/constants"
        ;;
esac

echo "   ✓ Estructura creada: $TIPO"
echo ""

# 5. Crear archivos base según tipo
echo "📄 5. Creando archivos base..."

case "$TIPO" in
    "pequeño")
        cat > "$RUTA/src/TypeScripts/$NOMBRE/$DOMINIO/$DOMINIO.types.ts" << 'EOF'
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

        cat > "$RUTA/src/TypeScripts/$NOMBRE/$DOMINIO/$DOMINIO.service.ts" << 'EOF'
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
      const rec = record.load({ type: record.Type.INVOICE, id });
      return { id: rec.id, name: rec.getValue({ fieldId: 'entity' }) as string };
    } catch {
      return null;
    }
  }
}
EOF
        ;;
    "mediano-sin-modules"|"mediano-con-modules")
        cat > "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Domain/entities/$DOMINIO.entity.ts" << 'EOF'
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

  static create(data: ${DOMINIO}Data): { success: boolean; entity?: ${DOMINIO}Entity; error?: string } {
    const entity = new ${DOMINIO}Entity(data);
    const validation = entity.validate();
    if (!validation.valid) return { success: false, error: validation.errors.join(', ') };
    return { success: true, entity };
  }
}

interface ${DOMINIO}Data {
  name: string;
  id?: number;
}
EOF

        cat > "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Application/services/$DOMINIO.service.ts" << 'EOF'
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
    const entityResult = ${DOMINIO}Entity.create(data);
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
}

interface ${DOMINIO}Input { name: string; }
EOF
        ;;
    "grande")
        cat > "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Domain/entities/$DOMINIO.entity.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export class ${DOMINIO}Entity {
  private readonly data: ${DOMINIO}Data;

  constructor(data: ${DOMINIO}Data) {
    this.data = data;
  }

  get name(): string { return this.data.name; }

  canBeCreated(): boolean { return !!this.data.name && this.data.name.length > 0; }

  validate(): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    if (!this.data.name) errors.push('name es requerido');
    return { valid: errors.length === 0, errors };
  }

  static create(data: ${DOMINIO}Data): { success: boolean; entity?: ${DOMINIO}Entity; error?: string } {
    const entity = new ${DOMINIO}Entity(data);
    const validation = entity.validate();
    if (!validation.valid) return { success: false, error: validation.errors.join(', ') };
    return { success: true, entity };
  }
}

interface ${DOMINIO}Data { id?: number; name: string; status?: string; metadata?: Record<string, unknown>; }
EOF

        cat > "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Application/ports/inbound/$DOMINIO.input.port.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export interface ${DOMINIO}InputPort {
  create(input: ${DOMINIO}InputDTO): Promise<{ success: boolean; id?: number; error?: string }>;
  read(id: number): Promise<${DOMINIO}OutputDTO | null>;
}

export interface ${DOMINIO}InputDTO { name: string; status?: string; }
export interface ${DOMINIO}OutputDTO { id: number; name: string; status?: string; }
EOF

        cat > "$RUTA/src/TypeScripts/$NOMBRE/Modules/$DOMINIO/Application/ports/outbound/$DOMINIO.repository.port.ts" << 'EOF'
/**
 * @NApiVersion 2.1
 * @NModuleScope Public
 */
export interface ${DOMINIO}RepositoryPort {
  save(data: object): Promise<number>;
  findById(id: number): Promise<object | null>;
}
EOF
        ;;
esac

echo "   ✓ Archivos base creados"
echo ""

# 6. Instalar dependencias
echo "📥 6. Instalando dependencias..."
cd "$RUTA"
if command -v yarn &> /dev/null; then
    yarn install
elif command -v npm &> /dev/null; then
    npm install
fi
echo "   ✓ Dependencias instaladas"
echo ""

echo "=========================================="
echo "✅ Proyecto $NOMBRE creado exitosamente!"
echo "=========================================="
echo ""
echo "Próximos pasos:"
echo "1. cd $RUTA"
echo "2. yarn setup  (para conectar tu cuenta NetSuite)"
echo "3. yarn build (para compilar TypeScript)"
echo "4. yarn deploy (para desplegar a NetSuite)"
echo ""