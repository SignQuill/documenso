#!/bin/sh

# =============================================================================
# Documenso Staging Application Startup Script
# =============================================================================
# 
# This script starts the Documenso application in the staging environment.
# It performs the following tasks:
# - Runs database migrations using Prisma
# - Generates Prisma client for database access
# - Starts the Remix application on port 3000
# - Handles errors gracefully with set -e
#
# This script is executed inside the Docker container as the entry point.
# It ensures the database is properly migrated before starting the app.
#
# Usage: Called automatically by Docker container
# Requirements: Database connection, Prisma schema
# =============================================================================

set -e

echo "Starting Documenso staging environment..."

# Run database migrations
echo "Running database migrations..."
npx prisma migrate deploy --schema ../../packages/prisma/schema.prisma

# Generate Prisma client
echo "Generating Prisma client..."
npx prisma generate --schema ../../packages/prisma/schema.prisma

# Start the application
echo "Starting application on port 3000..."
HOSTNAME=0.0.0.0 node build/server/main.js 