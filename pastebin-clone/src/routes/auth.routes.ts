import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();
const authController = new AuthController();

export function setAuthRoutes(app: Router) {
    app.post('/register', authController.register);
    app.post('/login', authController.login);
    app.use(authMiddleware);
}