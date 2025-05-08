const express = require("express");
const router = express.Router();
const { sql, pool } = require("../db/config");

/**
 * @swagger
 * /api/health:
 *  get:
 *    summary: Verificar el estado de la aplicación
 *    tags: [Health]
 *    responses:
 *      200:
 *        description: La aplicación está funcionando correctamente
 *      500:
 *        description: Error del servidor
 */
router.get("/health", async (req, res) => {
  try {
    // Verificar las variables de entorno necesarias
    const envVars = {
      NODE_ENV: process.env.NODE_ENV || "no definido",
      DB_SERVER: process.env.DB_SERVER ? "definido" : "no definido",
      DB_NAME: process.env.DB_NAME ? "definido" : "no definido",
      KEYVAULT_URI: process.env.KEYVAULT_URI ? "definido" : "no definido",
      PORT: process.env.PORT || "8080 (default)",
    };

    // Intentar conexión a la base de datos (sin ejecutar consultas)
    let dbStatus = "pendiente";
    let dbError = null;

    try {
      const poolConnection = await pool;
      if (poolConnection) {
        dbStatus = "conectado";
      } else {
        dbStatus = "error de conexión";
      }
    } catch (error) {
      dbStatus = "error";
      dbError = error.message;
    }

    res.json({
      status: "operativo",
      timestamp: new Date().toISOString(),
      entorno: envVars,
      database: {
        status: dbStatus,
        error: dbError,
        server: process.env.DB_SERVER
          ? process.env.DB_SERVER.split(".")[0]
          : null, // Mostrar solo el nombre, no el FQDN completo
        dbName: process.env.DB_NAME,
      },
      version: process.version,
    });
  } catch (error) {
    console.error("Error en endpoint de health:", error);
    res.status(500).json({
      status: "error",
      mensaje: "Error al verificar el estado",
      error: error.message,
    });
  }
});

/**
 * @swagger
 * /api/ready:
 *  get:
 *    summary: Verificar si la aplicación está lista para recibir tráfico
 *    tags: [Health]
 *    responses:
 *      200:
 *        description: La aplicación está lista para recibir tráfico
 *      503:
 *        description: La aplicación no está lista para recibir tráfico
 */
router.get("/ready", async (req, res) => {
  try {
    // Verificar si la base de datos está disponible
    const poolConnection = await pool;
    // Simple consulta de prueba
    await poolConnection.request().query("SELECT 1 as testValue");

    res.json({ ready: true, timestamp: new Date().toISOString() });
  } catch (error) {
    console.error("Error en endpoint de readiness:", error);
    res.status(503).json({
      ready: false,
      error: error.message,
      timestamp: new Date().toISOString(),
    });
  }
});

module.exports = router;
