#!/bin/bash

# =============================================================================
# Documenso Staging Deployment Script (System-wide)
# =============================================================================
# 
# This script deploys the Documenso staging environment from the system-wide location.
# It performs the following tasks:
# - Changes to the application directory
# - Pulls latest git changes (if in git repository)
# - Stops existing containers and removes orphans
# - Builds Docker image with --no-cache
# - Starts all services in detached mode
# - Provides deployment confirmation
#
# Usage: /usr/local/bin/deploy-documenso-staging
# Requirements: Docker, docker-compose, git repository in /opt/documenso
# =============================================================================

set -e

cd /opt/documenso

# Pull latest changes
if [ -d ".git" ]; then
    git pull origin main
fi

# Deploy
docker-compose -f docker/staging/compose.yml down --remove-orphans
docker-compose -f docker/staging/compose.yml build --no-cache
docker-compose -f docker/staging/compose.yml up -d

echo "✅ Documenso staging deployment completed!" 