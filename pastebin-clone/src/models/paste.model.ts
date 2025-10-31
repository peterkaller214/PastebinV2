import { Schema, model } from 'mongoose';

const pasteSchema = new Schema({
    title: {
        type: String,
        required: true,
    },
    content: {
        type: String,
        required: true,
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
    expiresAt: {
        type: Date,
        required: false,
    },
    password: {
        type: String,
        required: false,
    },
});

const Paste = model('Paste', pasteSchema);

export default Paste;