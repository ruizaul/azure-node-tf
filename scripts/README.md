# Scripts para node-tf

Este directorio contiene los scripts de utilidad para gestionar la infraestructura y la aplicación.

## Scripts disponibles

### deploy.sh

Script para desplegar la infraestructura usando Terraform y Azure Key Vault:

```bash
# Despliegue normal
./deploy.sh

# Para inicializar y luego desplegar (primera vez)
./deploy.sh --init
```

Este script:

1. Navega automáticamente a la carpeta Terraform
2. Verifica si el Key Vault ya existe
   - Si no existe, solicita las credenciales iniciales para crearlo
   - Si ya existe, utiliza las credenciales almacenadas en el Key Vault automáticamente
3. Ejecuta terraform apply con la configuración adecuada

**Nota importante:** Las credenciales solo se solicitan una vez durante la primera ejecución. Las ejecuciones subsecuentes utilizarán automáticamente las credenciales almacenadas en Azure Key Vault de forma segura.

### logs.sh

Script para ver los logs de la aplicación en tiempo real:

```bash
./logs.sh
```

Este script:

1. Obtiene el nombre de la aplicación web desde los outputs de Terraform
2. Muestra los logs en tiempo real usando la CLI de Azure

## Uso

Estos scripts deben ejecutarse desde la carpeta `scripts`:

```bash
cd scripts
./deploy.sh
```

O desde cualquier ubicación especificando la ruta:

```bash
./node-tf/scripts/deploy.sh
```
