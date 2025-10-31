import dotenv from 'dotenv';

dotenv.config();

const config = {
    authKey: process.env.AUTH_KEY || 'default_auth_key',
    db: {
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT || 5432,
        user: process.env.DB_USER || 'user',
        password: process.env.DB_PASSWORD || 'password',
        database: process.env.DB_NAME || 'pastebin_clone',
    },
};

export default config;