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

echo "🚀 Deploying Documenso Staging Environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    print_error "docker-compose is not installed. Please install it and try again."
    exit 1
fi

# Set the directory to the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

print_status "Project root: $PROJECT_ROOT"

# Change to project root
cd "$PROJECT_ROOT"

# Check if .env file exists
if [ ! -f "docker/staging/.env" ]; then
    print_error "No .env file found in docker/staging/. Please create one from env.example"
    exit 1
fi

# Load environment variables
print_status "Loading environment variables..."
export $(grep -v '^#' docker/staging/.env | xargs)

# Stop existing containers
print_step "Stopping existing containers..."
docker-compose -f docker/staging/compose.yml down --remove-orphans

# Pull latest changes (if using git)
if [ -d ".git" ]; then
    print_step "Pulling latest changes from git..."
    git pull origin main
fi

# Build the Docker image
print_step "Building Docker image..."
docker-compose -f docker/staging/compose.yml build --no-cache

# Start the services
print_step "Starting services..."
docker-compose -f docker/staging/compose.yml up -d

# Wait for services to be healthy
print_step "Waiting for services to be healthy..."
sleep 10

# Check if services are running
print_step "Checking service status..."
docker-compose -f docker/staging/compose.yml ps

# Check if the application is responding
print_step "Checking application health..."
for i in {1..30}; do
    if curl -f http://localhost:${PORT:-3000}/api/health > /dev/null 2>&1; then
        print_status "✅ Application is healthy and responding!"
        break
    else
        print_warning "Waiting for application to be ready... (attempt $i/30)"
        sleep 5
    fi
done

if [ $i -eq 30 ]; then
    print_error "Application failed to start within the expected time."
    print_status "Checking logs..."
    docker-compose -f docker/staging/compose.yml logs --tail=50
    exit 1
fi

print_status "✅ Deployment completed successfully!"

echo ""
print_status "Application is now running at: http://localhost:${PORT:-3000}"
echo ""
print_status "Useful commands:"
echo "  View logs: docker-compose -f docker/staging/compose.yml logs -f"
echo "  Stop services: docker-compose -f docker/staging/compose.yml down"
echo "  Restart services: docker-compose -f docker/staging/compose.yml restart"
echo "  View service status: docker-compose -f docker/staging/compose.yml ps" 