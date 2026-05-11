// Import the official Microsoft SQL Server client for Node.js.
import sql from "mssql";

// Load database configuration values from the shared config file.
import config from "../config.js";

// Database connection settings used by the MSSQL client.
// These values are sourced from config.js so they can be changed
// in one place and not hard-coded in the data access code.
export const dbSettings = {
    user: config.dbUser,
    password: config.dbPassword,
    server: config.dbServer,
    database: config.dbDatabase,
    options: {
        // Encrypt the connection to SQL Server. This is required for
        // Azure SQL and recommended for secure local/remote connections.
        encrypt: true,
        // Allow trusting a self-signed certificate in development.
        trustServerCertificate: true,
    },
};

// Creates and returns a connection pool to the database.
// This is an async function because connection setup may take time.
export const getConnection = async () => {
    try {
        const pool = await sql.connect(dbSettings);
        return pool;
    } catch (error) {
        // Log the error and re-throw it so calling code can handle it.
        console.error(error);
        throw error;
    }
};

// Export the mssql module itself so other modules can use helpers such as
// sql.Request, sql.VarChar, sql.Int, etc. without importing mssql again.
export { sql };