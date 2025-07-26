#!/bin/bash

# =============================================================================
# Documenso Staging EC2 User Data Script
# =============================================================================
# 
# This script runs when the EC2 instance first starts up.
# It performs complete system configuration and prepares the instance
# for the Documenso staging environment, including all management scripts.
#
# This script is executed as root during instance initialization.
# =============================================================================

set -e

# Update system packages
yum update -y

# Install basic utilities
yum install -y \
    git \
    curl \
    wget \
    unzip \
    jq \
    htop \
    tree \
    vim \
    nc \
    telnet

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Create documenso user
useradd -m -s /bin/bash documenso
usermod -aG docker documenso

# Create application directories
mkdir -p /opt/documenso
mkdir -p /opt/documenso/certs
mkdir -p /var/log/documenso
mkdir -p /opt/documenso/backups

# Set proper permissions
chown -R documenso:documenso /opt/documenso
chown -R documenso:documenso /var/log/documenso
chmod 700 /opt/documenso/certs

# Configure firewall (if firewalld is running)
if systemctl is-active --quiet firewalld; then
    firewall-cmd --permanent --add-port=22/tcp
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --permanent --add-port=443/tcp
    firewall-cmd --permanent --add-port=${app_port}/tcp
    firewall-cmd --permanent --add-port=5432/tcp
    firewall-cmd --permanent --add-port=6379/tcp
    firewall-cmd --reload
fi

# Create systemd service file
cat > /etc/systemd/system/documenso-staging.service << 'EOF'
[Unit]
Description=Documenso Staging Environment
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/documenso
ExecStart=/usr/bin/docker-compose -f /opt/documenso/docker/staging/compose.yml up -d
ExecStop=/usr/bin/docker-compose -f /opt/documenso/docker/staging/compose.yml down
User=documenso
Group=documenso

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

# Create deployment script
cat > /usr/local/bin/deploy-documenso-staging << 'EOF'
#!/bin/bash
set -e

cd /opt/documenso

# Pull latest image from Docker Hub
echo "📦 Pulling latest image from Docker Hub..."
docker pull devopsways/sign-quill:staging

# Pull latest changes (if using git)
if [ -d ".git" ]; then
    git pull origin main
fi

# Deploy
docker-compose -f docker/staging/compose.yml down --remove-orphans
docker-compose -f docker/staging/compose.yml up -d

echo "✅ Documenso staging deployment completed!"
EOF

chmod +x /usr/local/bin/deploy-documenso-staging

# Create monitoring script
cat > /usr/local/bin/monitor-documenso-staging << 'EOF'
#!/bin/bash

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
EOF

chmod +x /usr/local/bin/monitor-documenso-staging

# Create backup script
cat > /usr/local/bin/backup-documenso-staging << 'EOF'
#!/bin/bash
set -e

BACKUP_DIR="/opt/documenso/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="documenso_staging_backup_$DATE"

mkdir -p "$BACKUP_DIR"

echo "Creating backup: $${BACKUP_NAME}"

# Backup database
docker exec documenso-staging-db pg_dump -U documenso documenso_staging > "$BACKUP_DIR/$${BACKUP_NAME}_database.sql"

# Backup Redis
docker exec documenso-staging-redis redis-cli BGSAVE
sleep 2
docker cp documenso-staging-redis:/data/dump.rdb "$BACKUP_DIR/$${BACKUP_NAME}_redis.rdb"

# Create archive
tar -czf "$BACKUP_DIR/$${BACKUP_NAME}.tar.gz" \
    -C "$BACKUP_DIR" \
    "$${BACKUP_NAME}_database.sql" \
    "$${BACKUP_NAME}_redis.rdb"

# Clean up individual files
rm "$BACKUP_DIR/$${BACKUP_NAME}_database.sql"
rm "$BACKUP_DIR/$${BACKUP_NAME}_redis.rdb"

echo "✅ Backup created: $BACKUP_DIR/$${BACKUP_NAME}.tar.gz"
EOF

chmod +x /usr/local/bin/backup-documenso-staging

# Create logrotate configuration
cat > /etc/logrotate.d/documenso-staging << 'EOF'
/var/log/documenso/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 documenso documenso
    postrotate
        docker-compose -f /opt/documenso/docker/staging/compose.yml restart
    endscript
}
EOF

# Create a simple health check script
cat > /usr/local/bin/health-check.sh << 'EOF'
#!/bin/bash
echo "Instance is healthy"
echo "Timestamp: $(date)"
echo "Uptime: $(uptime)"
echo "Disk usage: $(df -h / | tail -1)"
echo "Memory usage: $(free -h | grep Mem)"
EOF

chmod +x /usr/local/bin/health-check.sh

# Create a welcome message
cat > /etc/motd << 'EOF'
===============================================================================
Welcome to Documenso Staging Environment
===============================================================================

This instance is managed by Terraform and configured for Documenso staging.

Next steps:
1. Clone the repository: git clone https://github.com/documenso/documenso.git /opt/documenso
2. Configure environment: cp /opt/documenso/docker/staging/env.example /opt/documenso/docker/staging/.env
3. Deploy: /usr/local/bin/deploy-documenso-staging

Useful commands:
- Deploy: /usr/local/bin/deploy-documenso-staging
- Monitor: /usr/local/bin/monitor-documenso-staging
- Backup: /usr/local/bin/backup-documenso-staging
- Health check: /usr/local/bin/health-check.sh
- View logs: docker-compose -f /opt/documenso/docker/staging/compose.yml logs -f

===============================================================================
EOF

# Log the completion
echo "User data script completed successfully at $(date)" >> /var/log/user-data.log

# Signal completion to CloudFormation (if using CloudFormation)
if command -v cfn-signal >/dev/null 2>&1; then
    cfn-signal -e 0 --stack "documenso-staging" --resource "EC2Instance" --region "ca-central-1"
fi 