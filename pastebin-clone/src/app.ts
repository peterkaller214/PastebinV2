import express from 'express';
import { json, urlencoded } from 'body-parser';
import { setPasteRoutes } from './routes/paste.routes';
import { setAuthRoutes } from './routes/auth.routes';
import { errorHandler } from './middleware/error.middleware';
import { connectToDatabase } from './db/index';
import { config } from './config/index';

const app = express();

// Middleware for parsing request bodies
app.use(json());
app.use(urlencoded({ extended: true }));

// Connect to the database
connectToDatabase();

// Set up routes
setPasteRoutes(app);
setAuthRoutes(app);

// Error handling middleware
app.use(errorHandler);

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});