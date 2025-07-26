# Documenso Staging Environment

This directory contains all the necessary files to deploy Documenso in a staging environment on Amazon Linux EC2 using a private Docker Hub repository.

## Overview

The staging environment includes:
- **Documenso Application**: The main Remix application (pulled from Docker Hub)
- **PostgreSQL Database**: For data persistence
- **Redis**: For caching and session storage
- **Docker & Docker Compose**: For containerization

## Docker Hub Workflow

### 1. Build and Push to Docker Hub

```bash
# Build the image locally for Amazon Linux EC2
./build-local.sh

# Or build and push in one step
./push-to-dockerhub.sh
```

### 2. Docker Hub Authentication

Before pushing to Docker Hub, you need to authenticate:

```bash
# Login to Docker Hub
docker login

# Or use the push script which will prompt for login
./push-to-dockerhub.sh
```

### 3. Image Details

- **Repository**: `devopsways/sign-quill`
- **Tags**: `staging`, `latest`
- **Platform**: `linux/amd64` (Amazon Linux EC2 compatible)
- **Base Image**: `node:18-alpine`

## Files Structure

```
docker/staging/
├── Dockerfile              # Staging-specific Dockerfile
├── compose.yml             # Docker Compose configuration (uses Docker Hub image)
├── build-local.sh          # Local build script
├── push-to-dockerhub.sh    # Build and push to Docker Hub
├── deploy.sh               # Deployment script (pulls from Docker Hub)
├── env.example             # Environment variables template
├── README.md              # This file
└── terraform/             # Infrastructure as Code
    └── staging/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── user-data.sh
        ├── terraform.tfvars.example
        └── README.md
```

## Quick Start

### Option 1: Local Development

```bash
# Build and push to Docker Hub
./build-local.sh

# Deploy locally
./deploy.sh
```

### Option 2: Infrastructure as Code (Recommended)

Use Terraform to deploy the complete infrastructure:

```bash
# Navigate to Terraform directory
cd terraform/staging

# Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your SSH public key

# Deploy infrastructure
terraform init
terraform plan
terraform apply

# Follow the deployment instructions in the Terraform output
```

## Build Process

### Local Build

The `build-local.sh` script:

1. **Builds for target platform**: Uses `linux/amd64` for Amazon Linux EC2 compatibility
2. **Multi-stage build**: Optimizes image size with proper layering
3. **Production ready**: Uses Node.js 18 Alpine for smaller footprint
4. **Standalone output**: Leverages Next.js standalone output for optimal performance

### Docker Hub Push

The `push-to-dockerhub.sh` script:

1. **Checks Docker Hub authentication**
2. **Builds image if needed**
3. **Pushes both `staging` and `latest` tags**
4. **Provides feedback and links**

## Environment Configuration

### Required Variables

```bash
# Application
PORT=3000
NODE_ENV=staging

# Database
POSTGRES_USER=documenso
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=documenso_staging
NEXT_PRIVATE_DATABASE_URL=postgresql://documenso:your_secure_password@database:5432/documenso_staging
NEXT_PRIVATE_DIRECT_DATABASE_URL=postgresql://documenso:your_secure_password@database:5432/documenso_staging

# Authentication
NEXTAUTH_SECRET=your_secure_secret_key
NEXT_PRIVATE_ENCRYPTION_KEY=your_encryption_key
NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY=your_secondary_encryption_key

# URLs
NEXT_PUBLIC_WEBAPP_URL=http://your-domain.com
NEXT_PRIVATE_INTERNAL_WEBAPP_URL=http://localhost:3000
```

### Optional Variables

```bash
# SMTP Configuration
NEXT_PRIVATE_SMTP_TRANSPORT=smtp-auth
NEXT_PRIVATE_SMTP_HOST=smtp.example.com
NEXT_PRIVATE_SMTP_PORT=587
NEXT_PRIVATE_SMTP_USERNAME=your_username
NEXT_PRIVATE_SMTP_PASSWORD=your_password
NEXT_PRIVATE_SMTP_FROM_NAME=Documenso Staging
NEXT_PRIVATE_SMTP_FROM_ADDRESS=noreply@your-domain.com

# Google OAuth
NEXT_PRIVATE_GOOGLE_CLIENT_ID=your_google_client_id
NEXT_PRIVATE_GOOGLE_CLIENT_SECRET=your_google_client_secret

# S3 Storage (optional)
NEXT_PUBLIC_UPLOAD_TRANSPORT=s3
NEXT_PRIVATE_UPLOAD_ENDPOINT=https://s3.amazonaws.com
NEXT_PRIVATE_UPLOAD_REGION=us-east-1
NEXT_PRIVATE_UPLOAD_BUCKET=your-staging-bucket
NEXT_PRIVATE_UPLOAD_ACCESS_KEY_ID=your_access_key
NEXT_PRIVATE_UPLOAD_SECRET_ACCESS_KEY=your_secret_key
```

## Management Commands

### Deployment

```bash
# Deploy the application (pulls from Docker Hub)
/usr/local/bin/deploy-documenso-staging

# Or manually
cd /opt/documenso
docker-compose -f docker/staging/compose.yml down --remove-orphans
docker-compose -f docker/staging/compose.yml up -d
```

### Monitoring

```bash
# Check application status
/usr/local/bin/monitor-documenso-staging

# View logs
docker-compose -f /opt/documenso/docker/staging/compose.yml logs -f

# Check service status
docker-compose -f /opt/documenso/docker/staging/compose.yml ps
```

### Backup

```bash
# Create backup
/usr/local/bin/backup-documenso-staging
```

### Service Management

```bash
# Start services
docker-compose -f /opt/documenso/docker/staging/compose.yml up -d

# Stop services
docker-compose -f /opt/documenso/docker/staging/compose.yml down

# Restart services
docker-compose -f /opt/documenso/docker/staging/compose.yml restart

# View logs
docker-compose -f /opt/documenso/docker/staging/compose.yml logs -f
```

> **Note**: When using Terraform deployment, all management scripts are automatically installed on the EC2 instance.

## Systemd Service

The Terraform user data script creates a systemd service for automatic startup:

```bash
# Enable service (starts on boot)
sudo systemctl enable documenso-staging

# Start service
sudo systemctl start documenso-staging

# Stop service
sudo systemctl stop documenso-staging

# Check status
sudo systemctl status documenso-staging
```

## Security Considerations

### Firewall

The setup script configures the firewall to allow:
- Port 3000: Application
- Port 5432: PostgreSQL (internal)
- Port 6379: Redis (internal)

### SSL/TLS

For production use, consider:
1. Setting up a reverse proxy (nginx) with SSL termination
2. Using AWS Application Load Balancer
3. Configuring CloudFront for CDN

### Database Security

- Use strong passwords for database users
- Consider using AWS RDS for managed PostgreSQL
- Enable encryption at rest
- Configure VPC security groups appropriately

## Troubleshooting

### Common Issues

1. **Image pull fails**
   ```bash
   # Check Docker Hub authentication
   docker login
   
   # Check image exists
   docker pull devopsways/sign-quill:staging
   ```

2. **Application won't start**
   ```bash
   # Check logs
   docker-compose -f /opt/documenso/docker/staging/compose.yml logs
   
   # Check environment variables
   docker-compose -f /opt/documenso/docker/staging/compose.yml config
   ```

3. **Database connection issues**
   ```bash
   # Check database container
   docker exec -it documenso-staging-db psql -U documenso -d documenso_staging
   
   # Check database logs
   docker logs documenso-staging-db
   ```

4. **Port conflicts**
   ```bash
   # Check what's using the port
   sudo netstat -tlnp | grep :3000
   
   # Change port in .env file
   PORT=3001
   ```

### Log Locations

- Application logs: `docker-compose logs -f`
- System logs: `/var/log/messages`
- Docker logs: `journalctl -u docker`

### Performance Monitoring

```bash
# Check resource usage
htop

# Check disk usage
df -h

# Check memory usage
free -h

# Check Docker resource usage
docker stats
```

## Backup and Recovery

### Automated Backups

The backup script creates daily backups including:
- PostgreSQL database dump
- Redis data
- Compressed archive

### Manual Backup

```bash
# Database backup
docker exec documenso-staging-db pg_dump -U documenso documenso_staging > backup.sql

# Redis backup
docker exec documenso-staging-redis redis-cli BGSAVE
docker cp documenso-staging-redis:/data/dump.rdb ./redis_backup.rdb
```

### Restore

```bash
# Restore database
docker exec -i documenso-staging-db psql -U documenso documenso_staging < backup.sql

# Restore Redis
docker cp redis_backup.rdb documenso-staging-redis:/data/dump.rdb
docker restart documenso-staging-redis
```

## Updates

### Application Updates

```bash
# Pull latest changes
cd /opt/documenso
git pull origin main

# Redeploy (will pull latest image from Docker Hub)
/usr/local/bin/deploy-documenso-staging
```

### Image Updates

To update the application image:

1. **Local development**:
   ```bash
   ./build-local.sh
   ./push-to-dockerhub.sh
   ```

2. **On EC2 instance**:
   ```bash
   /usr/local/bin/deploy-documenso-staging
   ```

### System Updates

```bash
# Update system packages
sudo yum update -y

# Restart services if needed
sudo systemctl restart docker
sudo systemctl restart documenso-staging
```

## Support

For issues and questions:
1. Check the logs: `docker-compose -f /opt/documenso/docker/staging/compose.yml logs`
2. Review the [main documentation](https://documenso.com/docs)
3. Open an issue on GitHub
4. Check the troubleshooting section above 