# Migración de Base de Datos de Azure SQL

Este directorio contiene los archivos necesarios para configurar y migrar la base de datos SQL de Azure para la aplicación node-tf.

## Archivos

- `config.js`: Configuración de conexión a la base de datos.
- `migration.sql`: Script SQL que define la estructura de la base de datos.
- `migrate.js`: Script JavaScript para ejecutar la migración.

## Requisitos previos

Antes de ejecutar la migración, asegúrate de tener configuradas las siguientes variables de entorno:

```
DB_USER=nombre_de_usuario
DB_PASSWORD=contraseña_del_usuario
DB_SERVER=nombre_servidor.database.windows.net
DB_DATABASE=nombre_de_la_base_de_datos
```

Puedes configurar estas variables en un archivo `.env` en la raíz del proyecto.

## Ejecutar la migración

Para ejecutar la migración, simplemente ejecuta el siguiente comando desde la raíz del proyecto:

```bash
npm run migrate
```

Este comando creará la tabla `Usuarios` si no existe y agregará algunos datos de ejemplo.

## Estructura de la base de datos

La migración crea la siguiente estructura:

### Tabla Usuarios

- `id`: INT (Clave primaria, autoincremento)
- `nombre`: NVARCHAR(100) (No nulo)
- `email`: NVARCHAR(150) (No nulo, único)

## Ampliación del esquema

Si necesitas agregar más tablas o modificar las existentes, edita el archivo `migration.sql` con tus nuevos cambios y ejecuta nuevamente el comando de migración.
