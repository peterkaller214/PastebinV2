import { Request, Response } from 'express';
import { PasteService } from '../services/paste.service';

export class PasteController {
    private pasteService: PasteService;

    constructor() {
        this.pasteService = new PasteService();
    }

    public async createPaste(req: Request, res: Response): Promise<void> {
        try {
            const { title, content } = req.body;
            const newPaste = await this.pasteService.createPaste(title, content);
            res.status(201).json(newPaste);
        } catch (error) {
            res.status(500).json({ message: 'Error creating paste', error });
        }
    }

    public async getPaste(req: Request, res: Response): Promise<void> {
        try {
            const { id } = req.params;
            const paste = await this.pasteService.getPaste(id);
            if (paste) {
                res.status(200).json(paste);
            } else {
                res.status(404).json({ message: 'Paste not found' });
            }
        } catch (error) {
            res.status(500).json({ message: 'Error retrieving paste', error });
        }
    }

    public async deletePaste(req: Request, res: Response): Promise<void> {
        try {
            const { id } = req.params;
            const result = await this.pasteService.deletePaste(id);
            if (result) {
                res.status(204).send();
            } else {
                res.status(404).json({ message: 'Paste not found' });
            }
        } catch (error) {
            res.status(500).json({ message: 'Error deleting paste', error });
        }
    }
}