// Controller module for user-related database operations.
// This file defines route handlers that call PostgreSQL functions
// in the Supabase database and return standardized JSON responses.
import pool from "../models/connection.js";

const executeJsonFunction = async (query, params = []) => {
    const respuesta = await pool.query(query, params);
    return respuesta.rows[0]?.respuesta || respuesta.rows[0] || null;
};

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
// Create user (function: SP_InsertarUsuario)
// ------------------------------------------------------------
export const crearUsuario = async (request, result) => {
    try {
        const {
            Nombre_Usuario,
            Credencial_Espacial,
            ID_Perfil
        } = request.body;

        const respuesta = await executeJsonFunction(
            "SELECT SP_InsertarUsuario($1, $2, $3) AS respuesta",
            [Nombre_Usuario, Credencial_Espacial, ID_Perfil]
        );

        return result.json(respuesta);
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
// Read all users (function: SP_LeerUsuarios)
// ------------------------------------------------------------
export const getUsuarios = async (request, result) => {
    try {
        const respuesta = await executeJsonFunction(
            "SELECT SP_LeerUsuarios() AS respuesta"
        );

        return result.json(respuesta);
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
// Read a single user by ID (function: SP_LeerUsuariosPorID)
// ------------------------------------------------------------
export const getUsuarioById = async (request, result) => {
    try {
        const { id } = request.params;

        const respuesta = await executeJsonFunction(
            "SELECT SP_LeerUsuariosPorID($1) AS respuesta",
            [id]
        );

        return result.json(respuesta);
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
// Update user (function: SP_ActualizarUsuarios)
// ------------------------------------------------------------
export const updateUsuario = async (request, result) => {
    try {
        const {
            ID_Usuario,
            Nombre_Usuario,
            Credencial_Espacial,
            ID_Perfil
        } = request.body;

        const respuesta = await executeJsonFunction(
            "SELECT SP_ActualizarUsuarios($1, $2, $3, $4) AS respuesta",
            [ID_Usuario, Nombre_Usuario, Credencial_Espacial, ID_Perfil]
        );

        return result.json(respuesta);
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
// Logical delete user (function: SP_EliminarUsuario)
// ------------------------------------------------------------
export const deleteLogico = async (request, result) => {
    try {
        const { id } = request.params;

        const respuesta = await executeJsonFunction(
            "SELECT SP_EliminarUsuario($1) AS respuesta",
            [id]
        );

        return result.json(respuesta);
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
// Physical delete user (function: SP_EliminarUsuarioFisico)
// ------------------------------------------------------------
export const deleteFisico = async (request, result) => {
    try {
        const { id } = request.params;

        const respuesta = await executeJsonFunction(
            "SELECT SP_EliminarUsuarioFisico($1) AS respuesta",
            [id]
        );

        return result.json(respuesta);
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
// Reactivate user (function: SP_ReactivarUsuario)
// ------------------------------------------------------------
export const reactivarUsuario = async (request, result) => {
    try {
        const { id } = request.params;

        const respuesta = await executeJsonFunction(
            "SELECT SP_ReactivarUsuario($1) AS respuesta",
            [id]
        );

        return result.json(respuesta);
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

