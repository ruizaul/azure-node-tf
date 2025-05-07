const sql = require("mssql");

// Configuración de la base de datos
const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,
  options: {
    encrypt: true, // Para conexiones seguras a Azure
    trustServerCertificate: false,
  },
};

// Creamos un pool de conexiones para mejor rendimiento
const pool = new sql.ConnectionPool(config)
  .connect()
  .then((pool) => {
    console.log("Conectado a Azure SQL Database");
    return pool;
  })
  .catch((err) => {
    console.error("Error de conexión a la base de datos:", err);
  });

module.exports = {
  sql,
  pool,
};
