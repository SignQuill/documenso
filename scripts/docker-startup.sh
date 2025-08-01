#!/bin/bash

set -e

echo "🚀 Starting SignQuill development environment..."

# Process branding files with current environment variables
echo "📝 Processing branding files..."
npm run branding:process

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
until npm run prisma:migrate-dev > /dev/null 2>&1; do
    echo "Database not ready, waiting..."
    sleep 5
done

echo "✅ Database migrations completed"

# Seed the database (creates admin user and sample data)
echo "🌱 Seeding the database..."
npm run prisma:seed

echo "✅ Database seeded"

# Start the development server
echo "🚀 Starting development server..."
npm run dev 