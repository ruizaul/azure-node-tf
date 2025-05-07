require("dotenv").config();
const express = require("express");
const swaggerJSDoc = require("swagger-jsdoc");
const swaggerUI = require("swagger-ui-express");

// Inicializar la aplicación Express
const app = express();
const port = process.env.PORT || 3000;

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
        url: `http://localhost:${port}`,
        description: "Servidor de desarrollo",
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

// Usar rutas
app.use("/api", usuariosRoutes);

// Ruta base
app.get("/", (req, res) => {
  res.json({ mensaje: "¡Bienvenido a la API sencilla!" });
});

// Iniciar el servidor
app.listen(port, () => {
  console.log(`Servidor ejecutándose en http://localhost:${port}`);
  console.log(
    `Documentación Swagger disponible en http://localhost:${port}/api-docs`
  );
});
