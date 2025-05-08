# Implementación de Azure Key Vault en node-tf

Este documento describe cómo se ha implementado Azure Key Vault para gestionar de forma segura las credenciales y secretos en el proyecto.

## Arquitectura de la solución

1. **Azure Key Vault**: Almacena las credenciales de la base de datos y otros secretos.
2. **Identidades Administradas**: La App Service tiene asignada una identidad administrada que le permite acceder al Key Vault.
3. **Terraform**: Gestiona toda la infraestructura, incluyendo el Key Vault y las políticas de acceso.

## Seguridad de credenciales

Esta implementación sigue las mejores prácticas de seguridad:

- **Variables sensibles** (como contraseñas) están marcadas como `sensitive = true` en Terraform
- **No hay valores predeterminados** para credenciales en el código
- **No se almacenan credenciales** en archivos de variables ni en el estado de Terraform
- **Las credenciales solo se ingresan** durante la primera ejecución

## Flujo de trabajo

La implementación sigue este flujo:

1. **Primera ejecución**:

   - Se solicitan credenciales iniciales una única vez
   - Se crea el Key Vault y se almacenan los secretos
   - Se crea un archivo marcador `.keyvault_created` para indicar que el Key Vault existe

2. **Ejecuciones posteriores**:
   - Se detecta que el Key Vault ya existe
   - Terraform obtiene automáticamente las credenciales del Key Vault
   - No se requiere volver a ingresar credenciales manualmente

## Configuración de Terraform

Los archivos principales que gestionan la implementación de Key Vault están en la carpeta `terraform/`:

- **terraform/key_vault.tf**: Define el recurso Key Vault y los secretos.
- **terraform/key_vault_access.tf**: Configura las políticas de acceso para la App Service.
- **terraform/main.tf**: Configuración para acceder a los secretos del Key Vault.
- **terraform/variables.tf**: Define las variables, sin valores predeterminados para las sensibles.

## Cómo funciona

1. **Despliegue**: Al ejecutar Terraform la primera vez, se crea el Key Vault y se almacenan los secretos.
2. **Identidad Administrada**: La App Service recibe una identidad administrada para acceder al Key Vault.
3. **Acceso a Secretos**: La aplicación Node.js usa la biblioteca `@azure/identity` para autenticarse con el Key Vault y recuperar los secretos.

## Desarrollo local

Para desarrollo local, puedes usar un archivo `.env` con las variables necesarias. Hay un archivo `env.example` que puedes copiar:

```bash
cp env.example .env
```

En modo desarrollo (NODE_ENV=development), la aplicación usará las variables de entorno locales en lugar de intentar acceder al Key Vault.

## Acceso a Key Vault desde local (opcional)

Si necesitas probar el acceso a Key Vault desde tu entorno local:

1. Registra una aplicación en Azure AD.
2. Otorga permisos a esta aplicación para acceder al Key Vault.
3. Configura las variables AZURE_TENANT_ID, AZURE_CLIENT_ID y AZURE_CLIENT_SECRET en tu archivo `.env`.

## Ventajas de esta implementación

1. **Seguridad mejorada**: Las credenciales no se almacenan en el código ni en variables de entorno.
2. **Sin modificación manual**: No es necesario configurar manualmente los secretos en cada ejecución de Terraform.
3. **Control de acceso**: Políticas de acceso bien definidas que siguen el principio de mínimo privilegio.
4. **Facilidad de rotación**: Los secretos pueden rotarse sin necesidad de actualizar el código o reiniciar aplicaciones.

## Despliegue con la nueva estructura

Usa el script de despliegue que maneja automáticamente las credenciales:

```bash
cd scripts
./deploy.sh
```

## Consideraciones

- Las credenciales iniciales solo se requieren la primera vez para crear el Key Vault.
- Las credenciales nunca se almacenan en el código ni en archivos, solo en Azure Key Vault.
- Para una implementación completamente segura, considera usar un pipeline de CI/CD que proporcione estas credenciales iniciales de forma segura.
