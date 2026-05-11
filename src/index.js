// Import Express app
import app from "./app.js";

// Render provides the PORT automatically
const PORT = process.env.PORT || 3000;

// Start server
app.listen(PORT, () => {

    console.log(`
    API REST running on port ${PORT}
    `);

});
