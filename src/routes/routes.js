/**
 * ============================================================
 * EXPRESS ROUTER - USER API ENDPOINTS
 * ============================================================
 * This file defines all API routes for user management operations.
 * Each route maps an HTTP method and path to a controller function.
 * 
 * All routes are prefixed with /api (defined in app.js)
 * So actual endpoints are: /api/usuarios, /api/update, etc.
 * 
 * Available Operations (CRUD):
 * - CREATE: POST /api/usuarios
 * - READ: GET /api/usuarios, GET /api/usuarios/:id
 * - UPDATE: PUT /api/update
 * - DELETE: DELETE /api/usuarios/logico/:id, DELETE /api/usuarios/fisico/:id
 * - REACTIVATE: PUT /api/usuarios/reactivar/:id
 */

import { Router } from "express";
import {
    crearUsuario,
    getData,
    updateUsuario,
    getUsuarios,
    getUsuarioById,
    deleteLogico,
    deleteFisico,
    reactivarUsuario,
} from "../controllers/controller.js";

/**
 * Create a new Express Router
 * Router is used to define grouped routes that share common functionality
 */
const router = Router();

// ============================================================
// HEALTH CHECK / TEST ROUTE
// ============================================================
/**
 * GET /api/test
 * 
 * Purpose: Verify that the server and database connection are working
 * 
 * Response: { test: 1 }
 * 
 * Usage:
 * - Check if API is online
 * - Debug database connectivity issues
 * - Can be called without authentication
 * 
 * Example:
 *   curl http://localhost:3000/api/test
 */
router.get("/test", getData);

// ============================================================
// CREATE USER
// ============================================================
/**
 * POST /api/usuarios
 * 
 * Purpose: Create a new user in the database
 * 
 * Database Function: SP_InsertarUsuario()
 * 
 * Request Body (JSON):
 * {
 *   "Nombre_Usuario": "John Doe",           // Required: User's name
 *   "Credencial_Espacial": "CRED_001",      // Required: User's credential/space credential
 *   "ID_Perfil": 1                          // Required: Foreign key to T_Perfiles_Seguridad
 * }
 * 
 * Response (on success):
 * {
 *   "msj_tipo": "success",
 *   "msj_texto": "Exito al realizar la acción.",
 *   "datos": []
 * }
 * 
 * Validation:
 * - All fields are required and non-empty
 * - ID_Perfil must exist in T_Perfiles_Seguridad table
 * - User is created with Estado = true (active by default)
 * 
 * Example:
 *   curl -X POST http://localhost:3000/api/usuarios \
 *     -H "Content-Type: application/json" \
 *     -d '{"Nombre_Usuario":"John","Credencial_Espacial":"CRED001","ID_Perfil":1}'
 */
router.post("/usuarios", crearUsuario);

// ============================================================
// READ ALL USERS
// ============================================================
/**
 * GET /api/usuarios
 * 
 * Purpose: Retrieve all active users from the database
 * 
 * Database Function: SP_LeerUsuarios()
 * 
 * Query Parameters: None
 * 
 * Response (on success):
 * {
 *   "msj_tipo": "success",
 *   "msj_texto": "Exito al realizar la acción.",
 *   "datos": [
 *     {
 *       "ID_Usuario": 1,
 *       "Nombre_Usuario": "John Doe",
 *       "Credencial_Espacial": "CRED_001",
 *       "ID_Perfil": 1,
 *       "Estado": true
 *     },
 *     ...
 *   ]
 * }
 * 
 * Notes:
 * - Only returns users where Estado = true (active users)
 * - Returns empty array if no active users exist
 * - Data is sorted by insertion order (default PostgreSQL behavior)
 * 
 * Example:
 *   curl http://localhost:3000/api/usuarios
 */
router.get("/usuarios", getUsuarios);

// ============================================================
// READ USER BY ID
// ============================================================
/**
 * GET /api/usuarios/:id
 * 
 * Purpose: Retrieve a single user by their ID
 * 
 * Database Function: SP_LeerUsuariosPorID()
 * 
 * URL Parameters:
 * - id: User's ID (integer, required)
 * 
 * Response (on success):
 * {
 *   "msj_tipo": "success",
 *   "msj_texto": "Usuario encontrado.",
 *   "datos": [
 *     {
 *       "ID_Usuario": 1,
 *       "Nombre_Usuario": "John Doe",
 *       "Credencial_Espacial": "CRED_001",
 *       "ID_Perfil": 1,
 *       "Estado": true
 *     }
 *   ]
 * }
 * 
 * Error Cases:
 * - ID is null or <= 0 → warning message
 * - User not found → warning message
 * 
 * Example:
 *   curl http://localhost:3000/api/usuarios/1
 */
router.get("/usuarios/:id", getUsuarioById);

// ============================================================
// UPDATE USER
// ============================================================
/**
 * PUT /api/update
 * 
 * Purpose: Update an existing user's information
 * 
 * Database Function: SP_ActualizarUsuarios()
 * 
 * Request Body (JSON):
 * {
 *   "ID_Usuario": 1,                        // Required: Which user to update
 *   "Nombre_Usuario": "Jane Doe",           // Required: New name
 *   "Credencial_Espacial": "CRED_002",      // Required: New credential
 *   "ID_Perfil": 2                          // Required: New profile/role
 * }
 * 
 * Response (on success):
 * {
 *   "msj_tipo": "success",
 *   "msj_texto": "Exito al realizar la acción.",
 *   "datos": []
 * }
 * 
 * Validation:
 * - All fields are required and non-empty
 * - ID_Usuario must be > 0
 * - User must exist in database
 * - Cannot update Estado (use deleteLogico/reactivarUsuario instead)
 * 
 * Example:
 *   curl -X PUT http://localhost:3000/api/update \
 *     -H "Content-Type: application/json" \
 *     -d '{"ID_Usuario":1,"Nombre_Usuario":"Jane","Credencial_Espacial":"CRED002","ID_Perfil":2}'
 */
router.put("/update", updateUsuario);

// ============================================================
// LOGICAL DELETE USER
// ============================================================
/**
 * DELETE /api/usuarios/logico/:id
 * 
 * Purpose: Soft delete - Mark a user as inactive (Estado = false)
 * 
 * Database Function: SP_EliminarUsuario()
 * 
 * URL Parameters:
 * - id: User's ID (integer, required)
 * 
 * What happens:
 * - Sets Estado = false
 * - User data remains in database (not actually deleted)
 * - User won't appear in active users list
 * - Can be reactivated later using PUT /api/usuarios/reactivar/:id
 * 
 * Response (on success):
 * {
 *   "msj_tipo": "success",
 *   "msj_texto": "Usuario eliminado correctamente.",
 *   "datos": []
 * }
 * 
 * Use Cases:
 * - User account closure (but data must be retained for compliance)
 * - Temporary account suspension
 * - Testing without permanent data loss
 * 
 * Example:
 *   curl -X DELETE http://localhost:3000/api/usuarios/logico/1
 */
router.delete("/usuarios/logico/:id", deleteLogico);

// ============================================================
// PHYSICAL DELETE USER
// ============================================================
/**
 * DELETE /api/usuarios/fisico/:id
 * 
 * Purpose: Hard delete - Permanently remove a user from database
 * 
 * Database Function: SP_EliminarUsuarioFisico()
 * 
 * URL Parameters:
 * - id: User's ID (integer, required)
 * 
 * What happens:
 * - Permanently removes the entire row from T_Usuarios_Intergalacticos table
 * - All user data is deleted (including Estado, name, credentials, etc.)
 * - Cannot be undone without database backup
 * - Related records in T_Prestamos (loans) may be affected
 * 
 * Response (on success):
 * {
 *   "msj_tipo": "success",
 *   "msj_texto": "Usuario eliminado físicamente.",
 *   "datos": []
 * }
 * 
 * ⚠️ WARNING:
 * - Use with caution - this is irreversible
 * - Check foreign key constraints (T_Prestamos.ID_Usuario)
 * - Consider using logical delete instead for data integrity
 * - Should require admin privileges in production
 * 
 * Example:
 *   curl -X DELETE http://localhost:3000/api/usuarios/fisico/1
 */
router.delete("/usuarios/fisico/:id", deleteFisico);

// ============================================================
// REACTIVATE USER
// ============================================================
/**
 * PUT /api/usuarios/reactivar/:id
 * 
 * Purpose: Reactivate a previously deactivated (logically deleted) user
 * 
 * Database Function: SP_ReactivarUsuario()
 * 
 * URL Parameters:
 * - id: User's ID (integer, required)
 * 
 * What happens:
 * - Sets Estado = true
 * - User becomes active again and appears in user lists
 * - All user data is restored (name, credentials, profile remain unchanged)
 * - Can only reactivate users where Estado = false
 * 
 * Response (on success):
 * {
 *   "msj_tipo": "success",
 *   "msj_texto": "Usuario reactivado correctamente.",
 *   "datos": []
 * }
 * 
 * Use Cases:
 * - Restore a previously suspended account
 * - Undo a logical delete operation
 * - Reactivate inactive users
 * 
 * Error Cases:
 * - ID is null or <= 0
 * - User doesn't exist
 * - User is already active (Estado = true)
 * 
 * Example:
 *   curl -X PUT http://localhost:3000/api/usuarios/reactivar/1
 */
router.put("/usuarios/reactivar/:id", reactivarUsuario);

// ============================================================
// EXPORT ROUTER
// ============================================================
/**
 * Export the configured router
 * This router is imported in app.js and mounted at /api
 * All routes defined above will be prefixed with /api
 * 
 * Usage in app.js:
 *   app.use("/api", routes);
 */
export default router;