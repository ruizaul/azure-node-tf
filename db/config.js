const sql = require("mssql");
const { DefaultAzureCredential } = require("@azure/identity");
const { SecretClient } = require("@azure/keyvault-secrets");

// Función asíncrona para obtener los secretos de Key Vault
async function getDbCredentials() {
  try {
    // Verificar si estamos en un entorno de desarrollo local
    if (process.env.NODE_ENV === "development") {
      return {
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
      };
    }

    // Si estamos en Azure, usamos la identidad administrada
    const credential = new DefaultAzureCredential();
    const keyVaultUrl = process.env.KEYVAULT_URI;
    const secretClient = new SecretClient(keyVaultUrl, credential);

    // Obtener los secretos
    const usernameSecret = await secretClient.getSecret("sql-admin-username");
    const passwordSecret = await secretClient.getSecret("sql-admin-password");

    return {
      user: usernameSecret.value,
      password: passwordSecret.value,
    };
  } catch (error) {
    console.error("Error al obtener credenciales de Key Vault:", error);
    throw error;
  }
}

// Configuración base de la base de datos
async function getDbConfig() {
  const credentials = await getDbCredentials();

  return {
    user: credentials.user,
    password: credentials.password,
    server: process.env.DB_SERVER,
    database: process.env.DB_NAME,
    options: {
      encrypt: true,
      trustServerCertificate: false,
    },
  };
}

// Exportamos una función que crea la conexión
async function createPool() {
  try {
    const config = await getDbConfig();
    const pool = await new sql.ConnectionPool(config).connect();
    console.log("Conectado a Azure SQL Database");
    return pool;
  } catch (err) {
    console.error("Error de conexión a la base de datos:", err);
    throw err;
  }
}

module.exports = {
  sql,
  createPool,
  // Para mantener compatibilidad con código existente, podemos crear el pool de manera asíncrona
  pool: createPool().catch((err) => {
    console.error("Error al inicializar el pool:", err);
  }),
};
