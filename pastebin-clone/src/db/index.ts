import { MongoClient } from 'mongodb';
import { config } from '../config';

let db: any;

export const connectToDatabase = async () => {
    if (db) {
        return db;
    }

    const client = new MongoClient(config.dbUri, { useNewUrlParser: true, useUnifiedTopology: true });

    try {
        await client.connect();
        db = client.db(config.dbName);
        console.log('Connected to database');
        return db;
    } catch (error) {
        console.error('Database connection error:', error);
        throw error;
    }
};

export const getDatabase = () => {
    if (!db) {
        throw new Error('Database not initialized. Call connectToDatabase first.');
    }
    return db;
};