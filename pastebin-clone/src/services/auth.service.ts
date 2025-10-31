import { Injectable } from 'nestjs/common';
import { User } from '../models/user.model';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AuthService {
    constructor(
        private readonly jwtService: JwtService,
        private readonly configService: ConfigService,
    ) {}

    async register(userData: Partial<User>): Promise<User> {
        // Logic for registering a user
        // Save user to the database and return the user object
    }

    async login(username: string, password: string): Promise<string> {
        // Logic for user login
        // Validate user credentials and return a JWT token
    }

    generateToken(user: User): string {
        const payload = { username: user.username, sub: user.id };
        return this.jwtService.sign(payload, {
            secret: this.configService.get<string>('AUTH_SECRET'),
            expiresIn: '1h',
        });
    }
}