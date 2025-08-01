#!/bin/sh

set -x

echo "🚀 Starting SignQuill production-like environment..."

# Process branding files with current environment variables
echo "📝 Processing branding files..."
cd /app && npm run branding:process

# Return to the remix directory for the rest of the operations
cd /app/apps/remix

# Run database migrations
echo "🗄️ Running database migrations..."
npx prisma migrate deploy --schema ../../packages/prisma/schema.prisma

echo "✅ SignQuill is ready!"

# Start the production server
HOSTNAME=0.0.0.0 node build/server/main.js 