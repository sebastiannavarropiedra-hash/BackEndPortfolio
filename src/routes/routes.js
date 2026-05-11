// Express router configuration for the user API endpoints.
// Each route maps an HTTP method and path to a controller function.
import { Router } from "express";
import {
    crearUsuario,
    getData,
    updateUsuario,
    getUsuarios,
    getUsuarioById,
    deleteLogico,
    deleteFisico,
} from "../controllers/controller.js";

const router = Router();

// Health check / test route.
// Use this to verify the server and database connection quickly.
router.get("/test", getData);

// Create a new user record.
// Expected request body: Nombre_Usuario, Credencial_Espacial, ID_Perfil
// Example: POST http://localhost:3002/api/usuarios
router.post("/usuarios", crearUsuario);

// Retrieve all users.
// Example: GET http://localhost:3002/api/usuarios
router.get("/usuarios", getUsuarios);

// Retrieve a single user by ID.
// Example: GET http://localhost:3002/api/usuarios/1
router.get("/usuarios/:id", getUsuarioById);

// Update an existing user.
// The controller expects the updated user details in the request body.
// Example: PUT http://localhost:3002/api/update
router.put("/update", updateUsuario);

// Perform a logical delete of a user.
// This typically marks the user as inactive instead of removing the row.
// Example: DELETE http://localhost:3002/api/usuarios/logico/1
router.delete("/usuarios/logico/:id", deleteLogico);

// Perform a physical delete of a user.
// This removes the user row from the database permanently.
// Example: DELETE http://localhost:3002/api/usuarios/fisico/1
router.delete("/usuarios/fisico/:id", deleteFisico);

// Export the configured router so it can be mounted in the main app.
export default router;