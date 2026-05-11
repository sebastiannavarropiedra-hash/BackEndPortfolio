// Controller module for user-related database operations.
// This file defines route handlers that call stored procedures
// in the PostgreSQL database and return standardized JSON responses.
import pool from "../models/connection.js";

// Basic test endpoint that verifies database connectivity.
// It executes a simple query and returns the result.
export const getData = async (req, res) => {
    try {
        const result = await pool.query("SELECT 1 AS test");
        res.json(result.rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
};

// ------------------------------------------------------------
// Create user (stored procedure: SP_InsertarUsuario)
// ------------------------------------------------------------
export const crearUsuario = async (request, result) => {
    try {
        // Extract required fields from the request body.
        const {
            Nombre_Usuario,
            Credencial_Espacial,
            ID_Perfil
        } = request.body;

        // Call the stored procedure with parameterized query.
        const respuesta = await pool.query(
            "SELECT * FROM SP_InsertarUsuario($1, $2, $3)",
            [Nombre_Usuario, Credencial_Espacial, ID_Perfil]
        );

        // Assuming the function returns a message in the first row.
        const mensaje = respuesta.rows[0];

        return result.json({
            resultado_tipo: mensaje.msj_tipo,
            respuesta_detalle: mensaje.msj_texto,
            datos: [],
            descripcion: "Endpoint que permite crear usuarios"
        });
    } catch (error) {
        console.log(error);
        return result.status(500).json({
            resultado_tipo: "error",
            respuesta_detalle: error.message,
            datos: [],
            descripcion: "Error interno del servidor"
        });
    }
};

// ------------------------------------------------------------
// Read all users (stored procedure: SP_LeerUsuarios)
// ------------------------------------------------------------
export const getUsuarios = async (request, result) => {
    try {
        // Execute the read stored procedure.
        const respuesta = await pool.query("SELECT * FROM SP_LeerUsuarios()");

        const descripcion = "Endpoint que permite consultar todos los usuarios";

        // Assuming the function returns data in rows, and message separately if needed.
        // Adjust based on actual function return.
        return result.json({
            resultado_tipo: "success", // Adjust if function returns type
            respuesta_detalle: "Usuarios obtenidos exitosamente",
            datos: respuesta.rows || [],
            descripcion: descripcion
        });
    } catch (error) {
        console.log(error);
        return result.status(500).json({
            resultado_tipo: "error",
            respuesta_detalle: error.message,
            datos: [],
            descripcion: "Error interno del servidor"
        });
    }
};

// ------------------------------------------------------------
// Read a single user by ID (stored procedure: SP_LeerUsuariosPorID)
// ------------------------------------------------------------
export const getUsuarioById = async (request, result) => {
    try {
        const { id } = request.params;

        const respuesta = await pool.query(
            "SELECT * FROM SP_LeerUsuariosPorID($1)",
            [id]
        );

        const descripcion = "Endpoint que permite consultar usuarios por ID";

        return result.json({
            resultado_tipo: "success", // Adjust based on function
            respuesta_detalle: "Usuario obtenido exitosamente",
            datos: respuesta.rows || [],
            descripcion: descripcion
        });
    } catch (error) {
        // Log the params and error for debugging.
        console.log(request.params);
        console.log(error);

        return result.status(500).json({
            resultado_tipo: "error",
            respuesta_detalle: error.message,
            datos: [],
            descripcion: "Error interno del servidor"
        });
    }
};

// ------------------------------------------------------------
// Update user (stored procedure: SP_ActualizarUsuarios)
// ------------------------------------------------------------
export const updateUsuario = async (request, result) => {
    try {
        const {
            ID_Usuario,
            Nombre_Usuario,
            Credencial_Espacial,
            ID_Perfil
        } = request.body;

        const respuesta = await pool.query(
            "SELECT * FROM SP_ActualizarUsuarios($1, $2, $3, $4)",
            [ID_Usuario, Nombre_Usuario, Credencial_Espacial, ID_Perfil]
        );

        const mensaje = respuesta.rows[0];

        return result.json({
            resultado_tipo: mensaje.msj_tipo,
            respuesta_detalle: mensaje.msj_texto,
            datos: [],
            descripcion: "Endpoint que permite actualizar usuarios"
        });
    } catch (error) {
        console.log(request.body);
        console.log(error);

        return result.status(500).json({
            resultado_tipo: "error",
            respuesta_detalle: error.message,
            datos: [],
            descripcion: "Error interno del servidor"
        });
    }
};

// ------------------------------------------------------------
// Logical delete user (stored procedure: SP_EliminarUsuario)
// ------------------------------------------------------------
export const deleteLogico = async (request, result) => {
    try {
        const { id } = request.params;

        const respuesta = await pool.query(
            "SELECT * FROM SP_EliminarUsuario($1)",
            [id]
        );

        const mensaje = respuesta.rows[0];

        return result.json({
            resultado_tipo: mensaje.msj_tipo,
            respuesta_detalle: mensaje.msj_texto,
            datos: [],
            descripcion: "Endpoint que permite eliminar lógicamente un usuario"
        });
    } catch (error) {
        console.log(request.params);
        console.log(error);

        return result.status(500).json({
            resultado_tipo: "error",
            respuesta_detalle: error.message,
            datos: [],
            descripcion: "Error interno del servidor"
        });
    }
};

// ------------------------------------------------------------
// Physical delete user (stored procedure: SP_EliminarUsuarioFisico)
// ------------------------------------------------------------
export const deleteFisico = async (request, result) => {
    try {
        const { id } = request.params;

        const respuesta = await pool.query(
            "SELECT * FROM SP_EliminarUsuarioFisico($1)",
            [id]
        );

        const mensaje = respuesta.rows[0];

        return result.json({
            resultado_tipo: mensaje.msj_tipo,
            respuesta_detalle: mensaje.msj_texto,
            datos: [],
            descripcion: "Endpoint que permite eliminar físicamente un usuario"
        });
    } catch (error) {
        console.log(request.params);
        console.log(error);

        return result.status(500).json({
            resultado_tipo: "error",
            respuesta_detalle: error.message,
            datos: [],
            descripcion: "Error interno del servidor"
        });
    }
};