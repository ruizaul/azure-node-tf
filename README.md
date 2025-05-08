# Infraestructura Azure para API Node.js

Este proyecto contiene la configuración de Terraform para desplegar una infraestructura en Azure con:

- Un grupo de recursos en Canada Central
- Un servidor de SQL Azure con una base de datos
- Un App Service Plan
- Una Web App de Linux para alojar una API Node.js
- Azure Key Vault para almacenar secretos de manera segura

## Estructura del proyecto

- `terraform/`: Contiene todos los archivos de Terraform para desplegar la infraestructura
- `scripts/`: Scripts de utilidad para despliegue y monitoreo
- `db/`: Scripts para la migración de la base de datos
- `routes/`: Rutas de la API Node.js

## Requisitos previos

- [Terraform](https://www.terraform.io/downloads.html) instalado
- [Azure CLI](https://docs.microsoft.com/es-es/cli/azure/install-azure-cli) instalado
- Una cuenta de Azure

## Inicio rápido

1. Iniciar sesión en Azure:

```bash
az login
```

2. Usar el script de despliegue:

```bash
cd node-tf/scripts
./deploy.sh --init  # Para la primera vez (inicialización)
```

**Nota importante:** Las credenciales solo se solicitan una vez durante la primera ejecución. Las ejecuciones subsecuentes utilizarán automáticamente las credenciales almacenadas en Azure Key Vault.

Para despliegues posteriores, simplemente ejecuta:

```bash
cd node-tf/scripts
./deploy.sh
```

3. Para ver los logs de la aplicación:

```bash
cd node-tf/scripts
./logs.sh
```

4. Cuando termines, puedes destruir la infraestructura:

```bash
cd node-tf/terraform
terraform destroy
```

## Variables

Las variables se encuentran definidas en `terraform/variables.tf`. Puedes cambiar sus valores predeterminados en el archivo `terraform/terraform.tfvars`.

## Gestión de secretos

Este proyecto utiliza Azure Key Vault para gestionar secretos de forma segura. Las credenciales sensibles como las contraseñas de la base de datos solo se ingresan una vez durante la creación inicial del Key Vault. Para más detalles sobre esta implementación, consulta [README-KEY-VAULT.md](README-KEY-VAULT.md).

## Conexión a la base de datos

Después de aplicar la configuración, Terraform mostrará la cadena de conexión para la base de datos SQL. La aplicación obtiene las credenciales automáticamente de Azure Key Vault en tiempo de ejecución, sin necesidad de almacenarlas en el código o variables de entorno.
