#!/bin/bash

# Obtener información desde los outputs de Terraform
WEBAPP_NAME=$(terraform output -raw webapp_url | cut -d'/' -f3 | cut -d'.' -f1)
RESOURCE_GROUP=$(terraform output -raw resource_group_id | cut -d'/' -f5)

echo "=== Información de la aplicación ==="
echo "Nombre: $WEBAPP_NAME"
echo "Grupo de recursos: $RESOURCE_GROUP"

# Verificar si la aplicación está en ejecución
echo -e "\n=== Estado de la aplicación ==="
az webapp show --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --query "{Estado:state,URL:defaultHostName}" -o table

# Verificar configuración
echo -e "\n=== Configuración de la aplicación ==="
az webapp config show --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --query "{NodeVersion:linuxFxVersion,AlwaysOn:alwaysOn}" -o table

# Mostrar variables de entorno configuradas
echo -e "\n=== Variables de entorno ==="
az webapp config appsettings list --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --query "[].{Nombre:name,Valor:value}" -o table 