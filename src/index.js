// Import the Express application instance configured in app.js.
import app from "./app.js";

// Start the server on the configured port.
// The port value is set in app.js and retrieved with app.get("port").
app.listen(app.get("port"));

// Log a simple startup message to the console.
console.log('\n API REST - Escuchando en el puerto #', app.get("port"), '\n');