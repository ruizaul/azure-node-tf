require("dotenv").config();
const fs = require("fs");
const path = require("path");
const { sql, pool } = require("./config");

async function runMigration() {
  try {
    console.log("Iniciando migración de la base de datos...");

    // Leer el archivo de migración SQL
    const migrationFilePath = path.join(__dirname, "migration.sql");
    const migrationScript = fs.readFileSync(migrationFilePath, "utf8");

    // Conectar a la base de datos y ejecutar el script
    const poolConnection = await pool;

    console.log("Ejecutando script de migración...");
    await poolConnection.request().batch(migrationScript);

    console.log("¡Migración completada exitosamente!");
    console.log(
      "La estructura de la base de datos ha sido creada/actualizada."
    );

    // Cerrar la conexión después de ejecutar la migración
    poolConnection.close();
    process.exit(0);
  } catch (error) {
    console.error("Error durante la migración:", error);
    process.exit(1);
  }
}

// Ejecutar la migración
runMigration();
