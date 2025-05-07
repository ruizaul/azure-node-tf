const express = require("express");
const router = express.Router();
const { sql, pool } = require("../db/config");

/**
 * @swagger
 * components:
 *  schemas:
 *    Usuario:
 *      type: object
 *      required:
 *        - nombre
 *        - email
 *      properties:
 *        id:
 *          type: integer
 *          description: ID del usuario
 *        nombre:
 *          type: string
 *          description: Nombre del usuario
 *        email:
 *          type: string
 *          description: Email del usuario
 *      example:
 *        id: 1
 *        nombre: Juan
 *        email: juan@ejemplo.com
 */

/**
 * @swagger
 * /api/usuarios:
 *  get:
 *    summary: Obtener lista de usuarios
 *    tags: [Usuarios]
 *    responses:
 *      200:
 *        description: Lista de usuarios
 *        content:
 *          application/json:
 *            schema:
 *              type: array
 *              items:
 *                $ref: '#/components/schemas/Usuario'
 *      500:
 *        description: Error del servidor
 */
router.get("/usuarios", async (req, res) => {
  try {
    const poolConnection = await pool;
    const result = await poolConnection
      .request()
      .query("SELECT * FROM Usuarios");
    res.json(result.recordset);
  } catch (error) {
    console.error("Error al obtener usuarios:", error);
    res
      .status(500)
      .json({ mensaje: "Error al obtener usuarios", error: error.message });
  }
});

/**
 * @swagger
 * /api/usuarios/{id}:
 *  get:
 *    summary: Obtener un usuario por su ID
 *    tags: [Usuarios]
 *    parameters:
 *      - in: path
 *        name: id
 *        schema:
 *          type: integer
 *        required: true
 *        description: ID del usuario
 *    responses:
 *      200:
 *        description: Información del usuario
 *        content:
 *          application/json:
 *            schema:
 *              $ref: '#/components/schemas/Usuario'
 *      404:
 *        description: Usuario no encontrado
 *      500:
 *        description: Error del servidor
 */
router.get("/usuarios/:id", async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const poolConnection = await pool;
    const result = await poolConnection
      .request()
      .input("id", sql.Int, id)
      .query("SELECT * FROM Usuarios WHERE id = @id");

    if (result.recordset.length > 0) {
      res.json(result.recordset[0]);
    } else {
      res.status(404).json({ mensaje: "Usuario no encontrado" });
    }
  } catch (error) {
    console.error("Error al obtener usuario por ID:", error);
    res
      .status(500)
      .json({ mensaje: "Error al obtener usuario", error: error.message });
  }
});

/**
 * @swagger
 * /api/usuarios:
 *  post:
 *    summary: Crear un nuevo usuario
 *    tags: [Usuarios]
 *    requestBody:
 *      required: true
 *      content:
 *        application/json:
 *          schema:
 *            $ref: '#/components/schemas/Usuario'
 *    responses:
 *      201:
 *        description: Usuario creado exitosamente
 *        content:
 *          application/json:
 *            schema:
 *              $ref: '#/components/schemas/Usuario'
 *      400:
 *        description: Datos inválidos
 *      500:
 *        description: Error del servidor
 */
router.post("/usuarios", async (req, res) => {
  try {
    const { nombre, email } = req.body;

    if (!nombre || !email) {
      return res.status(400).json({ mensaje: "Nombre y email son requeridos" });
    }

    const poolConnection = await pool;
    const result = await poolConnection
      .request()
      .input("nombre", sql.NVarChar, nombre)
      .input("email", sql.NVarChar, email).query(`
        INSERT INTO Usuarios (nombre, email)
        OUTPUT INSERTED.*
        VALUES (@nombre, @email)
      `);

    res.status(201).json(result.recordset[0]);
  } catch (error) {
    console.error("Error al crear usuario:", error);
    res
      .status(500)
      .json({ mensaje: "Error al crear usuario", error: error.message });
  }
});

module.exports = router;
