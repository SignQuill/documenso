#!/bin/bash
set -e

# Configuration
IMAGE_NAME="devopsways/sign-quill"
TAG="staging"
PLATFORM="linux/amd64"  # Amazon Linux EC2 uses x86_64

echo "🔨 Building Documenso staging image for Amazon Linux EC2..."

# Get the project root directory (two levels up from this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "📁 Project root: $PROJECT_ROOT"
echo "📁 Dockerfile: $SCRIPT_DIR/Dockerfile"

# Change to project root for build context
cd "$PROJECT_ROOT"

# Build the image for the target platform
docker buildx build \
  --platform $PLATFORM \
  --tag $IMAGE_NAME:$TAG \
  --tag $IMAGE_NAME:latest \
  --file docker/staging/Dockerfile \
  --build-arg NODE_ENV=staging \
  --build-arg PLATFORM=$PLATFORM \
  .

echo "✅ Image built successfully!"

# Ask user if they want to push to Docker Hub
read -p "Do you want to push the image to Docker Hub? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Pushing image to Docker Hub..."
    docker push $IMAGE_NAME:$TAG
    docker push $IMAGE_NAME:latest
    echo "✅ Image pushed successfully!"
    echo "📦 Image: $IMAGE_NAME:$TAG"
    echo "📦 Image: $IMAGE_NAME:latest"
else
    echo "ℹ️  Image built locally but not pushed."
    echo "📦 Local image: $IMAGE_NAME:$TAG"
fi 