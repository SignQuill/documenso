#!/bin/bash
set -e

# Configuration
IMAGE_NAME="devopsways/sign-quill"
TAG="staging"
PLATFORM="linux/amd64"

echo "🔐 Docker Hub Authentication and Push Script"
echo "============================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if user is logged in to Docker Hub
if ! docker info | grep -q "Username"; then
    echo "🔑 Please log in to Docker Hub:"
    docker login
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Build the image if it doesn't exist
if [[ "$(docker images -q $IMAGE_NAME:$TAG 2> /dev/null)" == "" ]]; then
    echo "🔨 Building image first..."
    cd "$SCRIPT_DIR"
    ./build-local.sh
fi

echo "🚀 Pushing image to Docker Hub..."
echo "📦 Image: $IMAGE_NAME:$TAG"
echo "📦 Image: $IMAGE_NAME:latest"

# Push both tags
docker push $IMAGE_NAME:$TAG
docker push $IMAGE_NAME:latest

echo "✅ Successfully pushed to Docker Hub!"
echo ""
echo "📋 Image details:"
echo "   Repository: $IMAGE_NAME"
echo "   Tags: $TAG, latest"
echo "   Platform: $PLATFORM"
echo ""
echo "🔗 View on Docker Hub: https://hub.docker.com/r/$IMAGE_NAME" 