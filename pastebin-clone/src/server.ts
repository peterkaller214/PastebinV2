import express from 'express';
import mongoose from 'mongoose';
import { json } from 'body-parser';
import { setPasteRoutes } from './routes/paste.routes';
import { setAuthRoutes } from './routes/auth.routes';
import { connectDB } from './db';
import { authMiddleware } from './middleware/auth.middleware';
import { config } from './config';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(json());
app.use(authMiddleware);

// Connect to the database
connectDB()
    .then(() => {
        console.log('Database connected successfully');
    })
    .catch((error) => {
        console.error('Database connection error:', error);
        process.exit(1);
    });

// Set up routes
setPasteRoutes(app);
setAuthRoutes(app);

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});