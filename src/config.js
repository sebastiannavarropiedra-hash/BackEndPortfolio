/**
 * ============================================================
 * ENVIRONMENT CONFIGURATION
 * ============================================================
 * This file loads environment variables from the .env file
 * and exports them as a configuration object.
 * 
 * All sensitive information (passwords, API keys) should be stored
 * in the .env file and NEVER hardcoded in the source code.
 * 
 * The .env file should be in the project root and is automatically
 * ignored by .gitignore to prevent committing secrets to version control.
 */

import { config } from "dotenv";

/**
 * Load Environment Variables
 * Reads .env file and populates process.env with all variables
 * Example .env file:
 * 
 *   PORT=3000
 *   DATABASE_URL=postgresql://user:password@host:port/database
 *   DB_USER=postgres
 *   DB_PASSWORD=mysecretpassword
 *   DB_SERVER=db.example.supabase.co
 *   DB_DATABASE=postgres
 */
config();

/**
 * Export Configuration Object
 * This object is imported in app.js to configure the Express server
 * 
 * Key properties:
 * - port: Server port (used in app.js and index.js)
 * - dbUser: Database username (for potential future use)
 * - dbPassword: Database password (for potential future use)
 * - dbServer: Database server host (for potential future use)
 * - dbDatabase: Database name (for potential future use)
 * 
 * Current Implementation:
 * The database connection uses DATABASE_URL instead (connection.js)
 * These are kept for reference and future use if needed
 */
export default {
  port: process.env.PORT,
  dbUser: process.env.DB_USER,
  dbPassword: process.env.DB_PASSWORD,
  dbServer: process.env.DB_SERVER,
  dbDatabase: process.env.DB_DATABASE,
};