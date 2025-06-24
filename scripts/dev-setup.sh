#!/bin/bash

set -e

echo "🚀 Setting up Documenso development environment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed. Please install it and try again."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cat > .env << EOF
# Database Configuration
DATABASE_URL="postgresql://documenso:password@localhost:54320/documenso"
NEXT_PRIVATE_DATABASE_URL="postgresql://documenso:password@localhost:54320/documenso"
NEXT_PRIVATE_DIRECT_DATABASE_URL="postgresql://documenso:password@localhost:54320/documenso"

# App Configuration
NEXT_PUBLIC_APP_URL="http://localhost:3000"
NEXT_PUBLIC_API_URL="http://localhost:3000"

# Encryption Keys (for development only)
NEXT_PRIVATE_ENCRYPTION_KEY="CAFEBABE"
NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY="DEADBEEF"

# S3/MinIO Configuration
NEXT_PRIVATE_S3_ENDPOINT="http://localhost:9002"
NEXT_PRIVATE_S3_ACCESS_KEY="documenso"
NEXT_PRIVATE_S3_SECRET_KEY="password"
NEXT_PRIVATE_S3_BUCKET="documenso"
NEXT_PRIVATE_S3_REGION="us-east-1"

# SMTP Configuration (Inbucket)
NEXT_PRIVATE_SMTP_HOST="localhost"
NEXT_PRIVATE_SMTP_PORT="2500"
NEXT_PRIVATE_SMTP_USER="documenso"
NEXT_PRIVATE_SMTP_PASSWORD="password"
NEXT_PRIVATE_SMTP_FROM="noreply@documenso.local"

# Redis Configuration (optional)
REDIS_URL="redis://localhost:6379"

# Authentication
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="your-secret-key-here"

# Feature Flags
NEXT_PUBLIC_FEATURE_FLAG_BILLING="true"
NEXT_PUBLIC_FEATURE_FLAG_TEAMS="true"

# Development Settings
NODE_ENV="development"
EOF
    echo "✅ .env file created"
else
    echo "✅ .env file already exists"
fi

# Build and start the development environment
echo "🐳 Building and starting Docker containers..."
docker-compose -f docker-compose.dev.yml up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Run database migrations
echo "🗄️  Running database migrations..."
docker-compose -f docker-compose.dev.yml exec app npm run prisma:migrate-dev

# Seed the database
echo "🌱 Seeding the database..."
docker-compose -f docker-compose.dev.yml exec app npm run prisma:seed

echo "🎉 Development environment is ready!"
echo ""
echo "📱 Application: http://localhost:3000"
echo "📧 Email Testing: http://localhost:9000"
echo "🗄️  MinIO Console: http://localhost:9001"
echo "🗄️  Database: localhost:54320"
echo ""
echo "🔧 Useful commands:"
echo "  - View logs: docker-compose -f docker-compose.dev.yml logs -f"
echo "  - Stop services: docker-compose -f docker-compose.dev.yml down"
echo "  - Restart app: docker-compose -f docker-compose.dev.yml restart app"
echo "  - Access app shell: docker-compose -f docker-compose.dev.yml exec app sh" 