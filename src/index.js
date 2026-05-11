/**
 * ============================================================
 * ENTRY POINT - API REST Backend Portfolio
 * ============================================================
 * This is the main entry point for the Express server.
 * The server runs on a specified PORT and listens for incoming HTTP requests.
 * All requests are routed through the Express app defined in app.js.
 */

// Import the Express application instance from app.js
// This contains all middleware, routes, and settings configured for the API
import app from "./app.js";

/**
 * PORT Configuration
 * - Reads PORT from environment variables (.env file)
 * - Falls back to 3000 if PORT is not defined
 * - On Render deployment, PORT is automatically provided
 */
const PORT = process.env.PORT || 3000;

/**
 * Start the Server
 * - Listens on the specified PORT
 * - Logs a message to the console when the server is running
 * - Ready to receive HTTP requests from clients
 */
app.listen(PORT, () => {
    console.log(`
    ============================================================
    API REST running on port ${PORT}
    ============================================================
    Base URL: http://localhost:${PORT}/api
    ============================================================
    `);
});
