# Pastebin Clone

This project is a simple Pastebin clone that allows users to create, retrieve, and delete pastes. It includes user authentication with an authentication key required for certain operations.

## Features

- User registration and login
- Create, retrieve, and delete pastes
- Authentication middleware to protect routes
- Database integration for storing pastes and user information

## Technologies Used

- TypeScript
- Express.js
- MongoDB (or any other database of your choice)
- Docker (for containerization)

## Project Structure

```
pastebin-clone
├── src
│   ├── server.ts               # Entry point of the application
│   ├── app.ts                  # Express application configuration
│   ├── config                   # Configuration settings
│   ├── controllers              # Controllers for handling requests
│   ├── routes                   # Route definitions
│   ├── services                 # Business logic and database interactions
│   ├── middleware               # Middleware functions
│   ├── models                   # Database models
│   ├── db                       # Database connection and management
│   ├── utils                    # Utility functions
│   └── types                    # TypeScript interfaces
├── migrations                   # Database migration files
├── scripts                      # Scripts for running tasks
├── .env.example                 # Example environment variables
├── package.json                 # NPM configuration
├── tsconfig.json               # TypeScript configuration
├── Dockerfile                   # Docker image instructions
└── docker-compose.yml           # Docker services configuration
```

## Setup Instructions

1. **Clone the repository:**

   ```bash
   git clone <repository-url>
   cd pastebin-clone
   ```

2. **Install dependencies:**

   ```bash
   npm install
   ```

3. **Set up environment variables:**

   Copy the `.env.example` to `.env` and fill in the required values.

4. **Run database migrations:**

   Execute the migration script to set up the database schema.

   ```bash
   ./scripts/migrate.sh
   ```

5. **Start the application:**

   You can run the application using:

   ```bash
   npm start
   ```

   Or, if using Docker:

   ```bash
   docker-compose up
   ```

## Usage

- **Register a new user:** POST `/api/auth/register`
- **Login:** POST `/api/auth/login`
- **Create a paste:** POST `/api/paste`
- **Get a paste:** GET `/api/paste/:id`
- **Delete a paste:** DELETE `/api/paste/:id`

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.