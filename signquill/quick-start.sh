#!/bin/bash

# SignQuill Production-Like Quick Start Script
# This script helps you get started with SignQuill production-like environment

set -e

echo "🚀 SignQuill Production-Like Quick Start"
echo "========================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if we're in the signquill directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Please run this script from the signquill directory."
    echo "   cd signquill"
    echo "   ./quick-start.sh"
    exit 1
fi

# Check if .env file exists, if not copy from template
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from template..."
    cp env.production .env
    echo "✅ .env file created. You can customize it as needed."
fi

# Check if certificate exists, if not generate it
if [ ! -f "certificates/signquill.p12" ]; then
    echo "🔐 Generating development certificate..."
    ./generate-cert.sh
    echo "✅ Certificate generated successfully."
else
    echo "✅ Certificate already exists."
fi

echo "📋 Starting SignQuill production-like environment..."
echo ""

# Start the services
docker compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 15

# Check if services are running
if docker compose ps | grep -q "Up"; then
    echo ""
    echo "✅ SignQuill is now running in production-like mode!"
    echo ""
    echo "🌐 Access your applications:"
    echo "   • Main App:        http://localhost:3000"
    echo "   • MinIO Console:   http://localhost:9001"
    echo "   • Email Testing:   http://localhost:9000"
    echo ""
    echo "📊 View logs:"
    echo "   docker compose logs -f"
    echo ""
    echo "🛑 Stop services:"
    echo "   docker compose down"
    echo ""
    echo "🔄 Restart services:"
    echo "   docker compose restart"
    echo ""
    echo "⚙️  Customize branding:"
    echo "   Edit .env file and restart: docker compose up --build"
else
    echo "❌ Failed to start services. Check logs with:"
    echo "   docker compose logs"
    exit 1
fi 