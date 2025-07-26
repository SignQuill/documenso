#!/bin/bash

set -e

echo "🚀 Starting Documenso staging environment..."

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
until npm run prisma:migrate-deploy > /dev/null 2>&1; do
    echo "Database not ready, waiting..."
    sleep 5
done

echo "✅ Database migrations completed"

# Generate Prisma client (with retry logic)
echo "🔧 Generating Prisma client..."
for i in {1..5}; do
    if npm run prisma:generate -w @documenso/prisma; then
        echo "✅ Prisma client generated successfully"
        break
    else
        echo "⚠️  Prisma generation failed, retrying... (attempt $i/5)"
        sleep 2
    fi
done

# Start the production server
echo "🚀 Starting production server..."
cd apps/remix && npm run start 