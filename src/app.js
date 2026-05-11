import express from "express";
import cors from "cors";
import morgan from "morgan";
import config from "./config.js";
import routes from "./routes/routes.js";

// Create the Express application instance.
const app = express();

// settings
// Store the port number in the app settings so the server can read it later.
app.set("port", config.port);

// Middlewares
// Enable CORS so the API can be called from client applications
// running in different domains or ports.
app.use(cors());

// Log HTTP requests in the console for development/debugging.
app.use(morgan("dev"));

// Parse URL-encoded request bodies (form submissions).
app.use(express.urlencoded({ extended: false }));

// Parse JSON request bodies.
app.use(express.json());

// Routes
// Mount the router under /api so all endpoints are prefixed with /api.
app.use("/api", routes);

export default app;