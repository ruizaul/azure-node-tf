const sql = require("mssql");
const { DefaultAzureCredential } = require("@azure/identity");
const { SecretClient } = require("@azure/keyvault-secrets");

// Función asíncrona para obtener los secretos de Key Vault
async function getDbCredentials() {
  try {
    // Verificar si estamos en un entorno de desarrollo local o si tenemos credenciales directas
    if (process.env.NODE_ENV === "development" || process.env.DB_USER) {
      console.log("Usando credenciales de variables de entorno");
      return {
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
      };
    }

    // Si no hay URL de KeyVault, no podemos continuar
    if (!process.env.KEYVAULT_URI) {
      throw new Error(
        "KEYVAULT_URI no está definido en las variables de entorno"
      );
    }

    console.log("Intentando obtener credenciales desde Azure Key Vault");

    // Si estamos en Azure, usamos la identidad administrada
    const credential = new DefaultAzureCredential();
    const keyVaultUrl = process.env.KEYVAULT_URI;

    console.log(`Conectando a Key Vault: ${keyVaultUrl}`);
    const secretClient = new SecretClient(keyVaultUrl, credential);

    // Obtener los secretos
    console.log("Obteniendo secreto: sql-admin-username");
    const usernameSecret = await secretClient.getSecret("sql-admin-username");

    console.log("Obteniendo secreto: sql-admin-password");
    const passwordSecret = await secretClient.getSecret("sql-admin-password");

    console.log("Credenciales obtenidas correctamente");
    return {
      user: usernameSecret.value,
      password: passwordSecret.value,
    };
  } catch (error) {
    console.error("Error al obtener credenciales:", error.message);

    // En caso de error, intentar usar credenciales de variables de entorno como fallback
    if (process.env.DB_USER && process.env.DB_PASSWORD) {
      console.log("Usando credenciales de fallback desde variables de entorno");
      return {
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
      };
    }

    throw error;
  }
}

// Configuración base de la base de datos
async function getDbConfig() {
  // Verificar que los parámetros de conexión necesarios estén disponibles
  if (!process.env.DB_SERVER) {
    throw new Error("DB_SERVER no está definido en las variables de entorno");
  }

  if (!process.env.DB_NAME) {
    throw new Error("DB_NAME no está definido en las variables de entorno");
  }

  try {
    const credentials = await getDbCredentials();

    console.log(
      `Configurando conexión a servidor: ${process.env.DB_SERVER}, BD: ${process.env.DB_NAME}`
    );

    return {
      user: credentials.user,
      password: credentials.password,
      server: process.env.DB_SERVER,
      database: process.env.DB_NAME,
      options: {
        encrypt: true,
        trustServerCertificate: false,
        connectTimeout: 30000, // 30 segundos para el timeout de conexión
        requestTimeout: 30000, // 30 segundos para el timeout de solicitudes
      },
    };
  } catch (error) {
    console.error("Error al obtener configuración de BD:", error);
    throw error;
  }
}

// Exportamos una función que crea la conexión
async function createPool() {
  try {
    console.log("Creando pool de conexión a la base de datos...");
    const config = await getDbConfig();

    // Log de información básica (sin credenciales)
    console.log(`Conectando a ${config.server} / ${config.database}`);

    const pool = await new sql.ConnectionPool(config).connect();
    console.log("Conectado exitosamente a Azure SQL Database");
    return pool;
  } catch (err) {
    console.error("Error de conexión a la base de datos:", err.message);

    // Si estamos en desarrollo, mostrar información adicional
    if (process.env.NODE_ENV === "development") {
      console.error("Detalles del error:", err);
    }

    throw err;
  }
}

// Crear el pool de manera controlada
let poolPromise;
function getPool() {
  if (!poolPromise) {
    console.log("Inicializando pool de conexión por primera vez");
    poolPromise = createPool().catch((err) => {
      console.error("Error al inicializar el pool:", err.message);
      poolPromise = null; // Resetear para intentar en la próxima llamada
      throw err;
    });
  }
  return poolPromise;
}

module.exports = {
  sql,
  createPool,
  // Exportamos una función que devuelve el pool (o lo crea si no existe)
  pool: getPool(),
};
