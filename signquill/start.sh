#!/bin/sh

set -x

echo "🚀 Starting SignQuill production-like environment..."

# Process branding files with current environment variables
echo "📝 Processing branding files..."
npm run branding:process

# Run database migrations
echo "🗄️ Running database migrations..."
npx prisma migrate deploy --schema ../../packages/prisma/schema.prisma

echo "✅ SignQuill is ready!"

# Start the production server
HOSTNAME=0.0.0.0 node build/server/main.js 