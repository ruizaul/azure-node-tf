#!/bin/bash
set -e

# Script de inicio para Azure App Service
echo "Iniciando script de startup.sh para la aplicación Node.js"

# Asegurarnos de estar en el directorio correcto
APP_DIR="/home/site/wwwroot"
echo "Cambiando al directorio de la aplicación: $APP_DIR"
cd $APP_DIR

# Verificar permisos
ls -la

# Ver variables de entorno disponibles (sin valores sensibles)
echo "Variables de entorno detectadas:"
echo "NODE_ENV: $NODE_ENV"
echo "DB_SERVER está definido: $(if [ -n "$DB_SERVER" ]; then echo "SÍ"; else echo "NO"; fi)"
echo "DB_NAME está definido: $(if [ -n "$DB_NAME" ]; then echo "SÍ"; else echo "NO"; fi)"
echo "KEYVAULT_URI está definido: $(if [ -n "$KEYVAULT_URI" ]; then echo "SÍ"; else echo "NO"; fi)"
echo "PORT está definido: $(if [ -n "$PORT" ]; then echo "SÍ - $PORT"; else echo "NO - usando 8080 por defecto"; fi)"

# Verificar que Node.js esté instalado correctamente
echo "Versión de Node.js:"
node -v

# Verificar que npm esté instalado correctamente
echo "Versión de npm:"
npm -v

# Instalar dependencias (si es necesario)
echo "Verificando dependencias..."
if [ ! -d "node_modules" ]; then
  echo "Directorio node_modules no encontrado, instalando dependencias..."
  npm install
else
  echo "Dependencias ya instaladas, omitiendo npm install"
fi

# Iniciar la aplicación
echo "Iniciando la aplicación..."
node index.js 