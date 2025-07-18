#!/bin/bash

# =============================================================================
# Documenso Staging Build Script
# =============================================================================
# 
# This script builds the Documenso staging environment Docker image.
# It performs the following tasks:
# - Validates Docker and docker-compose are available
# - Sets up environment variables from .env file
# - Builds the Docker image with --no-cache for clean builds
# - Provides helpful output and next steps
#
# Usage: ./build.sh
# Requirements: Docker, docker-compose, .env file in docker/staging/
# =============================================================================

set -e

echo "🚀 Building Documenso Staging Environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if .env file exists, if not create from example
if [ ! -f "docker/staging/.env" ]; then
    print_warning "No .env file found in docker/staging/. Creating from example..."
    if [ -f "docker/staging/env.example" ]; then
        cp docker/staging/env.example docker/staging/.env
        print_status "Created .env file from example. Please review and update the values."
    else
        print_error "env.example file not found. Please create a .env file manually."
        exit 1
    fi
fi

# Load environment variables
if [ -f "docker/staging/.env" ]; then
    print_status "Loading environment variables..."
    export $(grep -v '^#' docker/staging/.env | xargs)
fi

# Build the Docker image
print_status "Building Docker image..."
docker-compose -f docker/staging/compose.yml build --no-cache

print_status "✅ Build completed successfully!"

echo ""
print_status "To start the staging environment, run:"
echo "  docker-compose -f docker/staging/compose.yml up -d"
echo ""
print_status "To view logs, run:"
echo "  docker-compose -f docker/staging/compose.yml logs -f"
echo ""
print_status "To stop the staging environment, run:"
echo "  docker-compose -f docker/staging/compose.yml down" 