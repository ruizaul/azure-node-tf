# Terraform para node-tf

Este directorio contiene todos los archivos de Terraform necesarios para desplegar la infraestructura de la aplicación node-tf.

## Estructura de archivos

- `main.tf`: Definición principal de recursos
- `variables.tf`: Declaración de variables
- `outputs.tf`: Definición de salidas
- `key_vault.tf`: Configuración de Azure Key Vault
- `key_vault_access.tf`: Políticas de acceso para Key Vault
- `terraform.tfvars`: Variables para la infraestructura

## Cómo desplegar

Para desplegar la infraestructura, utiliza el script `deploy.sh` ubicado en la carpeta `scripts`:

```bash
# Desde la carpeta scripts
cd ../scripts
./deploy.sh

# Para inicializar y luego desplegar (primera vez)
./deploy.sh --init
```

También puedes ejecutar los comandos de Terraform directamente:

```bash
# Desde la carpeta terraform
terraform init
terraform plan
terraform apply
```

## Seguridad

Este proyecto utiliza Azure Key Vault para almacenar de forma segura las credenciales de la base de datos. Las credenciales no se almacenan en el código fuente.

Para más detalles sobre la implementación de Key Vault, consulta el archivo `README-KEY-VAULT.md` en el directorio principal.
