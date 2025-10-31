import { Router } from 'express';
import { PasteController } from '../controllers/paste.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();
const pasteController = new PasteController();

export function setPasteRoutes(app: Router) {
    app.post('/api/pastes', authMiddleware, pasteController.createPaste.bind(pasteController));
    app.get('/api/pastes/:id', pasteController.getPaste.bind(pasteController));
    app.delete('/api/pastes/:id', authMiddleware, pasteController.deletePaste.bind(pasteController));
}