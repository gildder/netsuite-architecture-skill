/**
 * Script para inyectar JSDoc headers a archivos JavaScript compilados
 * 
 * Problema: tsc en modo AMD no preserva comentarios JSDoc a nivel de archivo
 * Solución: después de compilar, recorrer los archivos .ts de Interface/
 * y copiar su JSDoc al .js compilado si tiene @NScriptType
 * 
 * Uso: node scripts/prepend-headers.js
 */

const fs = require('fs');
const path = require('path');

const ROOT_DIR = process.cwd();
const INTERFACE_DIR = path.join(ROOT_DIR, 'src', 'TypeScripts');

function getFiles(dir, extension) {
  let files = [];
  if (!fs.existsSync(dir)) return files;
  
  const items = fs.readdirSync(dir);
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory()) {
      files = files.concat(getFiles(fullPath, extension));
    } else if (stat.isFile() && item.endsWith(extension)) {
      files.push(fullPath);
    }
  }
  return files;
}

function extractJSDoc(tsContent) {
  const lines = tsContent.split('\n');
  const jsdocLines = [];
  let inJSDoc = false;
  
  for (const line of lines) {
    if (line.trim().startsWith('/**')) {
      inJSDoc = true;
    }
    if (inJSDoc) {
      jsdocLines.push(line);
      if (line.trim() === '*/') break;
    }
  }
  
  return jsdocLines.length > 0 ? jsdocLines.join('\n') : null;
}

function injectJSDoc(jsFilePath, jsdocHeader) {
  if (!jsdocHeader) return false;
  
  let content = fs.readFileSync(jsFilePath, 'utf8');
  
  // Verificar si ya tiene JSDoc con @NApiVersion
  if (content.includes('@NApiVersion')) return false;
  
  // Inject JSDoc al inicio del archivo
  const newContent = jsdocHeader + '\n\n' + content;
  fs.writeFileSync(jsFilePath, newContent, 'utf8');
  return true;
}

console.log('🔧 Injecting JSDoc headers to compiled JavaScript...\n');

const tsFiles = getFiles(INTERFACE_DIR, '.ts');
let processed = 0;
let modified = 0;

for (const tsFile of tsFiles) {
  const jsFile = tsFile
    .replace(INTERFACE_DIR, path.join(ROOT_DIR, 'src', 'FileCabinet', 'SuiteScripts'))
    .replace(/\.ts$/, '.js');
  
  // Solo procesar archivos que tienen @NScriptType en el .ts
  const tsContent = fs.readFileSync(tsFile, 'utf8');
  if (!tsContent.includes('@NScriptType')) continue;
  
  if (!fs.existsSync(jsFile)) continue;
  
  const jsdoc = extractJSDoc(tsContent);
  if (jsdoc && injectJSDoc(jsFile, jsdoc)) {
    const relativePath = path.relative(ROOT_DIR, jsFile);
    console.log(`  ✅ ${relativePath}`);
    modified++;
  }
  processed++;
}

console.log(`\n✅ Done! Processed ${processed} files, modified ${modified} files.`);