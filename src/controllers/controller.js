// Controller module for user-related database operations.
// This file defines route handlers that call stored procedures
// in the SQL Server database and return standardized JSON responses.
import { getConnection, sql } from "../models/connection.js";

// Basic test endpoint that verifies database connectivity.
// It executes a simple query and returns the result.
export const getData = async (req, res) => {
    const pool = await getConnection();
    const result = await pool.request().query("SELECT 1 AS test");
    res.json(result.recordset);
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

        // Get a database connection pool.
        const pool = await getConnection();

        // Call the stored procedure with typed input parameters.
        const respuesta = await pool
            .request()
            .input("Nombre_Usuario", sql.NVarChar, Nombre_Usuario)
            .input("Credencial_Espacial", sql.NVarChar, Credencial_Espacial)
            .input("ID_Perfil", sql.Int, ID_Perfil)
            .execute("SP_InsertarUsuario");

        // The stored procedure returns a message in recordsets[0][0].
        const mensaje = respuesta.recordsets[0][0];

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
        const pool = await getConnection();

        // Execute the read stored procedure without input parameters.
        const respuesta = await pool
            .request()
            .execute("SP_LeerUsuarios");

        const descripcion = "Endpoint que permite consultar todos los usuarios";

        return result.json({
            resultado_tipo: respuesta.recordsets[1][0].msj_tipo,
            respuesta_detalle: respuesta.recordsets[1][0].msj_texto,
            datos: respuesta.recordsets[0] || [],
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
        const pool = await getConnection();

        const respuesta = await pool
            .request()
            .input("ID_Usuario", sql.Int, id)
            .execute("SP_LeerUsuariosPorID");

        const descripcion = "Endpoint que permite consultar usuarios por ID";

        return result.json({
            resultado_tipo: respuesta.recordsets[1][0].msj_tipo,
            respuesta_detalle: respuesta.recordsets[1][0].msj_texto,
            datos: respuesta.recordsets[0] || [],
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

        const pool = await getConnection();

        const respuesta = await pool
            .request()
            .input("ID_Usuario", sql.Int, ID_Usuario)
            .input("Nombre_Usuario", sql.NVarChar, Nombre_Usuario)
            .input("Credencial_Espacial", sql.NVarChar, Credencial_Espacial)
            .input("ID_Perfil", sql.Int, ID_Perfil)
            .execute("SP_ActualizarUsuarios");

        const mensaje = respuesta.recordsets[0][0];

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
        const pool = await getConnection();

        const respuesta = await pool
            .request()
            .input("ID_Usuario", sql.Int, id)
            .execute("SP_EliminarUsuario");

        const mensaje = respuesta.recordsets[0][0];

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
        const pool = await getConnection();

        const respuesta = await pool
            .request()
            .input("ID_Usuario", sql.Int, id)
            .execute("SP_EliminarUsuarioFisico");

        const mensaje = respuesta.recordsets[0][0];

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