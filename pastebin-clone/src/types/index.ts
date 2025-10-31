export interface Paste {
    id: string;
    title: string;
    content: string;
    createdAt: Date;
    updatedAt: Date;
}

export interface User {
    id: string;
    username: string;
    passwordHash: string;
    createdAt: Date;
}

export interface AuthToken {
    token: string;
    expiresIn: number;
}