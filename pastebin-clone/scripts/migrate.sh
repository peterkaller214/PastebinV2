#!/bin/bash

# Load environment variables from .env file
if [ -f ../.env ]; then
    export $(cat ../.env | xargs)
fi

# Database migration command
DB_NAME=${DB_NAME:-"pastebin_clone"}
DB_USER=${DB_USER:-"root"}
DB_PASSWORD=${DB_PASSWORD:-""}
DB_HOST=${DB_HOST:-"localhost"}

# Run the SQL migration file
if [ -f ../migrations/001_init.sql ]; then
    echo "Running migrations..."
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < ../migrations/001_init.sql
    echo "Migrations completed."
else
    echo "Migration file not found."
    exit 1
fi