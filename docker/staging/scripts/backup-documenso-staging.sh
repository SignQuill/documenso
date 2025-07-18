#!/bin/bash

# =============================================================================
# Documenso Staging Backup Script
# =============================================================================
# 
# This script creates comprehensive backups of the Documenso staging environment.
# It performs the following tasks:
# - Creates timestamped backup directory
# - Exports PostgreSQL database to SQL dump
# - Backs up Redis data with BGSAVE
# - Creates compressed archive of all backups
# - Cleans up individual backup files
# - Provides backup location confirmation
#
# Usage: /usr/local/bin/backup-documenso-staging
# Requirements: Docker, running Documenso staging environment
# =============================================================================

set -e

BACKUP_DIR="/opt/documenso/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="documenso_staging_backup_$DATE"

mkdir -p "$BACKUP_DIR"

echo "Creating backup: $BACKUP_NAME"

# Backup database
docker exec documenso-staging-db pg_dump -U documenso documenso_staging > "$BACKUP_DIR/${BACKUP_NAME}_database.sql"

# Backup Redis
docker exec documenso-staging-redis redis-cli BGSAVE
sleep 2
docker cp documenso-staging-redis:/data/dump.rdb "$BACKUP_DIR/${BACKUP_NAME}_redis.rdb"

# Create archive
tar -czf "$BACKUP_DIR/${BACKUP_NAME}.tar.gz" \
    -C "$BACKUP_DIR" \
    "${BACKUP_NAME}_database.sql" \
    "${BACKUP_NAME}_redis.rdb"

# Clean up individual files
rm "$BACKUP_DIR/${BACKUP_NAME}_database.sql"
rm "$BACKUP_DIR/${BACKUP_NAME}_redis.rdb"

echo "✅ Backup created: $BACKUP_DIR/${BACKUP_NAME}.tar.gz" 