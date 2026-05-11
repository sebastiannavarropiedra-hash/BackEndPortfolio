import pkg from "pg";
const { Pool } = pkg;

// Load database configuration from environment variables or config.js.
// For Supabase, use the full connection string (e.g., postgresql://user:password@host:port/database).
// Store this securely in an environment variable to avoid hardcoding.
const connectionString = process.env.SUPABASE_CONNECTION_STRING || config.supabaseConnectionString;

// Creates and returns a connection pool to the Supabase database.
// This is an async function because connection setup may take time.
export const getConnection = async () => {
    try {
        const pool = new Pool({
            connectionString,
            ssl: { rejectUnauthorized: false }, // Required for Supabase; adjust if needed for local dev
        });
        return pool;
    } catch (error) {
        // Log the error and re-throw it so calling code can handle it.
        console.error("Error connecting to Supabase:", error);
        throw error;
    }
};

// Export the pg module itself so other modules can use helpers such as
// Pool, Client, etc. without importing pg again.
export { Pool };