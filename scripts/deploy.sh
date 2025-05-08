#!/bin/bash

# Script para desplegar la infraestructura con Azure Key Vault

# Directorio actual del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"
cd "$TERRAFORM_DIR"

# Verificar parámetros
if [ "$#" -eq 0 ]; then
    INIT_FLAG=""
elif [ "$1" == "--init" ]; then
    INIT_FLAG="--init"
else
    echo "Uso: $0 [--init]"
    exit 1
fi

# Archivo de variables
VARS_FILE="terraform.tfvars"

if [ ! -f "$VARS_FILE" ]; then
    echo "Archivo de variables $VARS_FILE no encontrado."
    exit 1
fi

# Verificar si el Key Vault ya ha sido creado
KEYVAULT_CREATED_FILE=".keyvault_created"

# Inicializar si se especifica
if [ "$INIT_FLAG" == "--init" ]; then
    echo "Inicializando Terraform..."
    terraform init
fi

# Si el Key Vault aún no se ha creado, necesitamos las credenciales iniciales
if [ ! -f "$KEYVAULT_CREATED_FILE" ]; then
    echo "El Key Vault aún no existe. Necesitamos configurar las credenciales iniciales."
    echo "Estas credenciales solo se usarán para crear el Key Vault y se almacenarán de forma segura."
    echo "IMPORTANTE: Estas credenciales no se almacenan en ningún archivo, solo en Azure Key Vault."
    read -p "Nombre de usuario administrador SQL inicial: " SQL_USER
    read -sp "Contraseña de administrador SQL inicial: " SQL_PASS
    echo ""

    echo "Ejecutando Terraform con credenciales iniciales..."
    terraform apply \
        -var-file="$VARS_FILE" \
        -var="sql_admin_username=$SQL_USER" \
        -var="sql_admin_password=$SQL_PASS"
else
    echo "Key Vault ya existe. Las credenciales se obtendrán automáticamente del Key Vault."
    echo "Ejecutando Terraform..."
    # Ahora que las variables sensibles no tienen valor predeterminado, 
    # tenemos que pasarlas como vacías ya que no se necesitan en posteriores ejecuciones
    terraform apply \
        -var-file="$VARS_FILE" \
        -var="sql_admin_username=" \
        -var="sql_admin_password="
fi

echo "Despliegue completado." 