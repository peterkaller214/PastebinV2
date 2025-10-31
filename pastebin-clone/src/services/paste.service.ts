import { Paste } from '../models/paste.model';
import { Database } from '../db/index';

export class PasteService {
    private db: Database;

    constructor() {
        this.db = new Database();
    }

    async createPaste(content: string, userId: string): Promise<Paste> {
        const newPaste = new Paste({ content, userId });
        await this.db.pastes.insert(newPaste);
        return newPaste;
    }

    async getPaste(id: string): Promise<Paste | null> {
        return await this.db.pastes.findById(id);
    }

    async deletePaste(id: string): Promise<boolean> {
        const result = await this.db.pastes.delete(id);
        return result.deletedCount > 0;
    }

    async getAllPastes(): Promise<Paste[]> {
        return await this.db.pastes.findAll();
    }
}