#!/bin/bash

# =============================================================================
# Documenso Staging EC2 Setup Script
# =============================================================================
# 
# This script sets up an Amazon Linux EC2 instance for Documenso staging.
# It performs the following tasks:
# - Updates system packages
# - Installs Docker, Docker Compose, and required tools
# - Creates documenso user with proper permissions
# - Sets up application directories and permissions
# - Configures firewall for required ports
# - Creates systemd service for auto-startup
# - Installs management scripts (deploy, monitor, backup)
# - Sets up log rotation and monitoring
#
# Usage: sudo ./setup-ec2.sh
# Requirements: Amazon Linux EC2 instance, root/sudo access
# =============================================================================

set -e

echo "🚀 Setting up Documenso Staging Environment on Amazon Linux EC2..."

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

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (use sudo)"
    exit 1
fi

# Update system packages
print_step "Updating system packages..."
yum update -y

# Install required packages
print_step "Installing required packages..."
yum install -y \
    docker \
    git \
    curl \
    wget \
    unzip \
    jq \
    htop \
    tree

# Start and enable Docker
print_step "Starting and enabling Docker..."
systemctl start docker
systemctl enable docker

# Install Docker Compose
print_step "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create symbolic link for docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify Docker Compose installation
print_step "Verifying Docker Compose installation..."
docker-compose --version

# Create documenso user
print_step "Creating documenso user..."
if ! id "documenso" &>/dev/null; then
    useradd -m -s /bin/bash documenso
    usermod -aG docker documenso
    print_status "Created documenso user"
else
    print_status "documenso user already exists"
fi

# Create application directory
print_step "Setting up application directory..."
APP_DIR="/opt/documenso"
mkdir -p "$APP_DIR"
chown documenso:documenso "$APP_DIR"

# Create certificate directory
print_step "Setting up certificate directory..."
CERT_DIR="/opt/documenso/certs"
mkdir -p "$CERT_DIR"
chown documenso:documenso "$CERT_DIR"
chmod 700 "$CERT_DIR"

# Create log directory
print_step "Setting up log directory..."
LOG_DIR="/var/log/documenso"
mkdir -p "$LOG_DIR"
chown documenso:documenso "$LOG_DIR"

# Configure firewall (if firewalld is running)
if systemctl is-active --quiet firewalld; then
    print_step "Configuring firewall..."
    firewall-cmd --permanent --add-port=3000/tcp
    firewall-cmd --permanent --add-port=5432/tcp
    firewall-cmd --permanent --add-port=6379/tcp
    firewall-cmd --reload
    print_status "Firewall configured"
fi

# Install systemd service file
print_step "Installing systemd service file..."
cp "$SCRIPT_DIR/config/documenso-staging.service" /etc/systemd/system/documenso-staging.service
systemctl daemon-reload

# Copy management scripts
print_step "Installing management scripts..."

# Create scripts directory if it doesn't exist
mkdir -p /usr/local/bin

# Copy deployment script
cp "$SCRIPT_DIR/scripts/deploy-documenso-staging.sh" /usr/local/bin/deploy-documenso-staging
chmod +x /usr/local/bin/deploy-documenso-staging

# Copy monitoring script
cp "$SCRIPT_DIR/scripts/monitor-documenso-staging.sh" /usr/local/bin/monitor-documenso-staging
chmod +x /usr/local/bin/monitor-documenso-staging

# Copy backup script
cp "$SCRIPT_DIR/scripts/backup-documenso-staging.sh" /usr/local/bin/backup-documenso-staging
chmod +x /usr/local/bin/backup-documenso-staging

# Install logrotate configuration
print_step "Setting up log rotation..."
cp "$SCRIPT_DIR/config/documenso-staging" /etc/logrotate.d/documenso-staging

print_status "✅ EC2 setup completed successfully!"

echo ""
print_status "Next steps:"
echo "1. Clone the Documenso repository to /opt/documenso"
echo "2. Copy docker/staging/env.example to docker/staging/.env and configure it"
echo "3. Run: sudo -u documenso /usr/local/bin/deploy-documenso-staging"
echo ""
print_status "Useful commands:"
echo "  Deploy: /usr/local/bin/deploy-documenso-staging"
echo "  Monitor: /usr/local/bin/monitor-documenso-staging"
echo "  Backup: /usr/local/bin/backup-documenso-staging"
echo "  View logs: docker-compose -f /opt/documenso/docker/staging/compose.yml logs -f"
echo "  Stop services: docker-compose -f /opt/documenso/docker/staging/compose.yml down" 