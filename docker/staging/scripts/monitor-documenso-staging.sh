#!/bin/bash

# =============================================================================
# Documenso Staging Monitoring Script
# =============================================================================
# 
# This script provides comprehensive monitoring for the Documenso staging environment.
# It displays:
# - Docker container status and resource usage
# - System resource utilization (CPU, memory, disk)
# - Recent application logs
# - Service health information
#
# Usage: /usr/local/bin/monitor-documenso-staging
# Requirements: Docker, docker-compose, running Documenso staging environment
# =============================================================================

echo "=== Documenso Staging Status ==="
echo ""

echo "Docker containers:"
docker ps --filter "name=documenso-staging" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "System resources:"
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1

echo "Memory Usage:"
free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }'

echo ""
echo "Disk Usage:"
df -h / | awk 'NR==2{print $5}'

echo ""
echo "Application logs (last 10 lines):"
docker-compose -f /opt/documenso/docker/staging/compose.yml logs --tail=10 