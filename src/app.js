/**
 * ============================================================
 * EXPRESS APPLICATION CONFIGURATION
 * ============================================================
 * This file sets up the Express server with all necessary:
 * - Middleware (CORS, logging, body parsing)
 * - Settings (port configuration)
 * - Route mounting (/api prefix)
 * 
 * The configured app is exported to index.js where it is started on a port.
 */

import express from "express";
import cors from "cors";
import morgan from "morgan";
import config from "./config.js";
import routes from "./routes/routes.js";

/**
 * Create Express Application Instance
 * This is the main application object that handles all HTTP requests
 */
const app = express();

// ============================================================
// APPLICATION SETTINGS
// ============================================================
/**
 * Store the port number in app settings
 * This value comes from config.js and is read from environment variables
 * Example: PORT=3000 in .env
 */
app.set("port", config.port);

// ============================================================
// MIDDLEWARE CONFIGURATION
// ============================================================
/**
 * CORS Middleware
 * Enables Cross-Origin Resource Sharing
 * Allows API to be called from different domains/ports (e.g., frontend on different port)
 * Example: Frontend on localhost:3001 can call API on localhost:3000
 */
app.use(cors());

/**
 * Morgan Middleware
 * HTTP request logger for development/debugging
 * Logs each request to console in "dev" format
 * Example output: "GET /api/usuarios 200 45.320 ms"
 */
app.use(morgan("dev"));

/**
 * URL-Encoded Body Parser
 * Parses request bodies with Content-Type: application/x-www-form-urlencoded
 * Used for form submissions
 * Example: form data from HTML forms
 */
app.use(express.urlencoded({ extended: false }));

/**
 * JSON Body Parser
 * Parses request bodies with Content-Type: application/json
 * Required to access req.body in JSON POST/PUT/PATCH requests
 * Example: POST requests with JSON payload like { "name": "John" }
 */
app.use(express.json());

// ============================================================
// ROUTES MOUNTING
// ============================================================
/**
 * Mount Router with /api Prefix
 * All routes from routes.js are prefixed with /api
 * 
 * Examples:
 * - router.get("/usuarios") becomes GET /api/usuarios
 * - router.post("/usuarios") becomes POST /api/usuarios
 * - router.put("/update") becomes PUT /api/update
 * 
 * This allows for future expansion (e.g., /auth, /products) without conflicts
 */
app.use("/api", routes);

// ============================================================
// EXPORT APP
// ============================================================
/**
 * Export the configured Express app
 * This is imported in index.js and started on a specific PORT
 */
export default app;