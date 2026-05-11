/**
 * ============================================================
 * DATABASE CONNECTION POOL
 * ============================================================
 * This file establishes and exports a connection pool to the PostgreSQL database
 * hosted on Supabase.
 * 
 * Why a Connection Pool?
 * - Reuses connections instead of creating new ones for each query
 * - Improves performance and reduces resource usage
 * - Handles connection recycling and error recovery automatically
 * - Allows multiple concurrent queries
 * 
 * Database: PostgreSQL (via Supabase)
 * Authentication: Connection string with embedded credentials from DATABASE_URL
 * SSL: Enabled with rejectUnauthorized: false (required for Supabase)
 */

import pkg from "pg";

// Destructure Pool from the pg package
// Pool is a class that manages multiple database connections
const { Pool } = pkg;

/**
 * Create Database Connection Pool
 * 
 * Configuration:
 * - connectionString: Full PostgreSQL connection URL from environment variables
 *   Format: postgresql://user:password@host:port/database
 *   Example: postgresql://postgres:mypassword@db.supabase.co:5432/postgres
 * 
 * - ssl: Enable SSL encryption for secure database communication
 *   rejectUnauthorized: false allows self-signed certificates (required for Supabase)
 * 
 * The connectionString should be defined in the .env file as:
 *   DATABASE_URL=postgresql://user:password@host:port/database
 */
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: {
        rejectUnauthorized: false,
    },
});

/**
 * Pool Event Listeners (Optional but recommended for production)
 * Uncomment these to monitor pool behavior and troubleshoot connection issues
 */
// pool.on('error', (err) => {
//     console.error('Unexpected error on idle client', err);
// });
//
// pool.on('connect', () => {
//     console.log('New connection established');
// });

/**
 * Export the Connection Pool
 * This pool is imported in controller.js to execute all database queries
 * 
 * Usage in other files:
 *   import pool from "../models/connection.js";
 *   const result = await pool.query("SELECT * FROM table_name", [params]);
 */
export default pool;