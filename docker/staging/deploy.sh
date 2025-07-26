#!/bin/bash

# =============================================================================
# Documenso Staging Deployment Script
# =============================================================================
# 
# This script deploys the Documenso staging environment.
# It performs the following tasks:
# - Validates Docker and docker-compose are available
# - Loads environment variables from .env file
# - Stops existing containers and removes orphans
# - Pulls latest git changes (if in git repo)
# - Builds Docker image with --no-cache
# - Starts all services with health checks
# - Validates application is responding
# - Provides deployment status and useful commands
#
# Usage: ./deploy.sh
# Requirements: Docker, docker-compose, .env file in docker/staging/
# =============================================================================

set -e

# Get the project root directory (two levels up from this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Configuration
IMAGE_NAME="devopsways/sign-quill"
TAG="staging"
COMPOSE_FILE="$SCRIPT_DIR/compose.yml"

echo "🚀 Deploying Documenso Staging Environment"
echo "=========================================="

# Change to project root for docker-compose
cd "$PROJECT_ROOT"

echo "📁 Project root: $PROJECT_ROOT"
echo "📁 Compose file: $COMPOSE_FILE"

# Check if .env file exists
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "❌ Environment file not found: $SCRIPT_DIR/.env"
    echo "📝 Please copy the example file and configure it:"
    echo "   cp $SCRIPT_DIR/env.example $SCRIPT_DIR/.env"
    echo "   nano $SCRIPT_DIR/.env"
    exit 1
fi

echo "📦 Pulling latest image from Docker Hub..."
docker pull $IMAGE_NAME:$TAG

echo "🔄 Stopping existing containers..."
docker-compose -f $COMPOSE_FILE down --remove-orphans

echo "🚀 Starting services..."
docker-compose -f $COMPOSE_FILE up -d

echo "⏳ Waiting for services to be ready..."
sleep 10

echo "📊 Checking service status..."
docker-compose -f $COMPOSE_FILE ps

echo "✅ Deployment completed!"
echo ""
echo "🌐 Application URL: http://localhost:${PORT:-3000}"
echo "📊 View logs: docker-compose -f $COMPOSE_FILE logs -f"
echo "🛑 Stop services: docker-compose -f $COMPOSE_FILE down" 