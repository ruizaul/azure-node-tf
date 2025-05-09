require("dotenv").config();
const express = require("express");
const swaggerJSDoc = require("swagger-jsdoc");
const swaggerUI = require("swagger-ui-express");
const cors = require("cors");

// Inicializar la aplicación Express
const app = express();
const port = process.env.PORT || 8080;

// Configurar CORS para permitir cualquier origen
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

// Middleware para parsear JSON
app.use(express.json());

// Configuración de Swagger
const swaggerOptions = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "API Sencilla",
      version: "1.0.0",
      description:
        "Una API sencilla con Express y Swagger conectada a Azure SQL",
    },
    servers: [
      {
        url: `/`,
        description: "Servidor",
      },
    ],
  },
  apis: ["./routes/*.js"], // Archivos que contienen anotaciones de Swagger
};

const swaggerSpec = swaggerJSDoc(swaggerOptions);

// Ruta para la documentación de Swagger
app.use("/api-docs", swaggerUI.serve, swaggerUI.setup(swaggerSpec));

// Importar rutas
const usuariosRoutes = require("./routes/usuarios");
const healthRoutes = require("./routes/health");

// Usar rutas
app.use("/api", usuariosRoutes);
app.use("/api", healthRoutes);

// Ruta base para verificación de salud
app.get("/", (req, res) => {
  res.json({
    mensaje: "¡Bienvenido a la API sencilla!",
    entorno: process.env.NODE_ENV,
    dbServer: process.env.DB_SERVER,
    dbName: process.env.DB_NAME,
    keyVaultUri: process.env.KEYVAULT_URI,
  });
});

// Manejo de errores para la aplicación
app.use((err, req, res, next) => {
  console.error("Error no manejado:", err);
  res.status(500).json({
    error: "Error interno del servidor",
    message: err.message,
  });
});

// Iniciar el servidor
app.listen(port, () => {
  console.log(`Servidor ejecutándose en el puerto ${port}`);
  console.log(`Documentación Swagger disponible en /api-docs`);

  // Imprimir variables de entorno (sin mostrar valores sensibles)
  console.log("Variables de entorno disponibles:");
  console.log(`NODE_ENV: ${process.env.NODE_ENV}`);
  console.log(`DB_SERVER: ${process.env.DB_SERVER}`);
  console.log(`DB_NAME: ${process.env.DB_NAME}`);
  console.log(`KEYVAULT_URI: ${process.env.KEYVAULT_URI}`);

  // Indicar que el servidor está listo
  console.log("Servidor listo para recibir solicitudes");
});
