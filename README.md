# Infraestructura Azure para API Node.js

Este proyecto contiene la configuración de Terraform para desplegar una infraestructura en Azure con:

- Un grupo de recursos en Canada Central
- Un servidor de SQL Azure con una base de datos
- Un App Service Plan
- Una Web App de Linux para alojar una API Node.js

## Requisitos previos

- [Terraform](https://www.terraform.io/downloads.html) instalado
- [Azure CLI](https://docs.microsoft.com/es-es/cli/azure/install-azure-cli) instalado
- Una cuenta de Azure

## Inicio rápido

1. Iniciar sesión en Azure:

```bash
az login
```

2. Inicializar Terraform:

```bash
terraform init
```

3. Ver los cambios que se aplicarán:

```bash
terraform plan
```

4. Aplicar los cambios:

```bash
terraform apply
```

5. Cuando termines, puedes destruir la infraestructura:

```bash
terraform destroy
```

## Variables

Las variables se encuentran definidas en `variables.tf`. Puedes cambiar sus valores predeterminados creando un archivo `terraform.tfvars` o pasando los valores como argumentos al comando `terraform apply`.

## Conexión a la base de datos

Después de aplicar la configuración, Terraform mostrará la cadena de conexión para la base de datos SQL. Puedes usar esta cadena en tu aplicación Node.js para conectarte a la base de datos.
