#!/bin/bash

# Script para normalizar TypeScript al formato NetSuite
# Uso: normalize-ts.sh "ruta/al/archivo.ts"

ARCHIVO=$1

if [ -z "$ARCHIVO" ]; then
    echo "Error: Falta la ruta del archivo"
    echo "Uso: normalize-ts.sh \"ruta/al/archivo.ts\""
    exit 1
fi

if [ ! -f "$ARCHIVO" ]; then
    echo "Error: El archivo no existe: $ARCHIVO"
    exit 1
fi

echo "📝 Normalizando: $ARCHIVO"
echo ""

# Leer el contenido actual
CONTENIDO=$(cat "$ARCHIVO")

# Detectar tipo de script basándose en funciones
SCRIPT_TYPE="Suitelet"
if echo "$CONTENIDO" | grep -q "pageInit"; then
    SCRIPT_TYPE="ClientScript"
elif echo "$CONTENIDO" | grep -q "beforeSubmit\|afterSubmit"; then
    SCRIPT_TYPE="UserEventScript"
elif echo "$CONTENIDO" | grep -q "getInputData\|map\|reduce\|summarize"; then
    SCRIPT_TYPE="MapReduceScript"
elif echo "$CONTENIDO" | grep -q "execute"; then
    SCRIPT_TYPE="ScheduledScript"
fi

echo "✅ Tipo de script detectado: $SCRIPT_TYPE"

# Agregar JSDoc si no existe
if ! echo "$CONTENIDO" | grep -q "@NApiVersion"; then
    CONTENIDO=$(echo "$CONTENIDO" | sed '1s/^/\/**\n * @NApiVersion 2.1\n * @NModuleScope Public\n * @NScriptType '"$SCRIPT_TYPE"'\n *\/\n\n/')
    echo "✅ Agregado JSDoc con @NApiVersion 2.1 y @NScriptType $SCRIPT_TYPE"
fi

# Agregar import de EntryPoints si hay export de funciones NetSuite
if echo "$CONTENIDO" | grep -q "export.*onRequest\|export.*pageInit\|export.*beforeSubmit\|export.*afterSubmit"; then
    if ! echo "$CONTENIDO" | grep -q "from 'N/types'"; then
        # Agregar el import después del último import
        CONTENIDO=$(echo "$CONTENIDO" | sed "/from 'N\//a import { EntryPoints } from 'N/types';")
        echo "✅ Agregado import de EntryPoints"
    fi
fi

# Escribir el archivo modificado
echo "$CONTENIDO" > "$ARCHIVO"

echo "✅ Archivo normalizado: $ARCHIVO"
echo ""
echo "Verificaciones realizadas:"
echo "  - JSDoc con @NApiVersion 2.1"
echo "  - @NModuleScope Public"
echo "  - @NScriptType $SCRIPT_TYPE"
echo "  - EntryPoints import (si aplica)"