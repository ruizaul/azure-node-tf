#!/bin/bash

# Directorio actual del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"
cd "$TERRAFORM_DIR"

# Obtener el nombre de la aplicación web desde los outputs de Terraform
WEBAPP_NAME=$(terraform output -raw webapp_url | cut -d'/' -f3 | cut -d'.' -f1)

echo "Nombre de la aplicación web: $WEBAPP_NAME"

# Ver los logs en tiempo real
echo "Mostrando logs en tiempo real (Ctrl+C para salir)..."
az webapp log tail --name $WEBAPP_NAME --resource-group $(terraform output -raw resource_group_id | cut -d'/' -f5)

# Otras opciones útiles:
# Ver el estado de la aplicación
# az webapp show --name $WEBAPP_NAME --resource-group $(terraform output -raw resource_group_id | cut -d'/' -f5) --query state

# Ver información de configuración
# az webapp config show --name $WEBAPP_NAME --resource-group $(terraform output -raw resource_group_id | cut -d'/' -f5) 