# Docker Development Setup

This guide will help you set up Documenso for local development using Docker.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (version 20.10 or later)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2.0 or later)

## Quick Start

1. **Clone the repository** (if you haven't already):
   ```bash
   git clone https://github.com/documenso/documenso.git
   cd documenso
   ```

2. **Run the setup script**:
   ```bash
   ./scripts/dev-setup.sh
   ```

   This script will:
   - Create a `.env` file with development configuration
   - Build and start all Docker containers
   - Run database migrations
   - Seed the database with initial data

3. **Access the application**:
   - Main app: http://localhost:3000
   - Email testing: http://localhost:9000
   - MinIO console: http://localhost:9001
   - Database: localhost:54320

## Manual Setup

If you prefer to set up manually or the script doesn't work for you:

### 1. Create Environment File

Create a `.env` file in the root directory with the following content:

```env
# Database Configuration
DATABASE_URL="postgresql://documenso:password@localhost:54320/documenso"

# App Configuration
NEXT_PUBLIC_APP_URL="http://localhost:3000"
NEXT_PUBLIC_API_URL="http://localhost:3000"

# Encryption Keys (for development only)
NEXT_PRIVATE_ENCRYPTION_KEY="CAFEBABE"
NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY="DEADBEEF"

# S3/MinIO Configuration
NEXT_PRIVATE_S3_ENDPOINT="http://localhost:9002"
NEXT_PRIVATE_S3_ACCESS_KEY="documenso"
NEXT_PRIVATE_S3_SECRET_KEY="password"
NEXT_PRIVATE_S3_BUCKET="documenso"
NEXT_PRIVATE_S3_REGION="us-east-1"

# SMTP Configuration (Inbucket)
NEXT_PRIVATE_SMTP_HOST="localhost"
NEXT_PRIVATE_SMTP_PORT="2500"
NEXT_PRIVATE_SMTP_USER="documenso"
NEXT_PRIVATE_SMTP_PASSWORD="password"
NEXT_PRIVATE_SMTP_FROM="noreply@documenso.local"

# Redis Configuration (optional)
REDIS_URL="redis://localhost:6379"

# Authentication
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="your-secret-key-here"

# Feature Flags
NEXT_PUBLIC_FEATURE_FLAG_BILLING="true"
NEXT_PUBLIC_FEATURE_FLAG_TEAMS="true"

# Development Settings
NODE_ENV="development"
```

### 2. Start Services

```bash
# Build and start all services
docker-compose -f docker-compose.dev.yml up --build -d

# Wait for services to be ready (about 30 seconds)
sleep 30

# Run database migrations
docker-compose -f docker-compose.dev.yml exec app npm run prisma:migrate-dev

# Seed the database
docker-compose -f docker-compose.dev.yml exec app npm run prisma:seed
```

## Services Overview

The development environment includes the following services:

### 🚀 Application (`app`)
- **Port**: 3000
- **URL**: http://localhost:3000
- **Description**: Main Documenso application with hot reloading

### 🗄️ Database (`database`)
- **Port**: 54320
- **URL**: localhost:54320
- **Description**: PostgreSQL database for storing application data

### 📧 Email Testing (`mailserver`)
- **Port**: 9000 (Web UI), 2500 (SMTP), 1100 (POP3)
- **URL**: http://localhost:9000
- **Description**: Inbucket for testing email functionality

### 📦 Object Storage (`minio`)
- **Port**: 9001 (Console), 9002 (API)
- **URL**: http://localhost:9001
- **Description**: MinIO for S3-compatible file storage

### 🗃️ Cache (`redis`)
- **Port**: 6379
- **Description**: Redis for caching (optional)

## Useful Commands

### View Logs
```bash
# All services
docker-compose -f docker-compose.dev.yml logs -f

# Specific service
docker-compose -f docker-compose.dev.yml logs -f app
```

### Stop Services
```bash
# Stop all services
docker-compose -f docker-compose.dev.yml down

# Stop and remove volumes (⚠️ This will delete all data)
docker-compose -f docker-compose.dev.yml down -v
```

### Restart Services
```bash
# Restart all services
docker-compose -f docker-compose.dev.yml restart

# Restart specific service
docker-compose -f docker-compose.dev.yml restart app
```

### Access Container Shell
```bash
# Access app container
docker-compose -f docker-compose.dev.yml exec app sh

# Access database
docker-compose -f docker-compose.dev.yml exec database psql -U documenso -d documenso
```

### Database Operations
```bash
# Run migrations
docker-compose -f docker-compose.dev.yml exec app npm run prisma:migrate-dev

# Reset database
docker-compose -f docker-compose.dev.yml exec app npm run prisma:migrate-reset

# Seed database
docker-compose -f docker-compose.dev.yml exec app npm run prisma:seed

# Open Prisma Studio
docker-compose -f docker-compose.dev.yml exec app npm run prisma:studio
```

## Development Workflow

### Hot Reloading
The application container is configured with volume mounts that enable hot reloading. Any changes you make to the source code will automatically trigger a rebuild.

### Database Changes
When you modify the Prisma schema:
1. Update the schema file
2. Run migrations: `docker-compose -f docker-compose.dev.yml exec app npm run prisma:migrate-dev`
3. The application will automatically regenerate the Prisma client

### Adding Dependencies
If you need to add new npm packages:
1. Add them to the appropriate `package.json`
2. Rebuild the container: `docker-compose -f docker-compose.dev.yml build app`
3. Restart the service: `docker-compose -f docker-compose.dev.yml restart app`

## Troubleshooting

### Port Conflicts
If you get port conflicts, you can modify the port mappings in `docker-compose.dev.yml`:

```yaml
ports:
  - "3001:3000"  # Change 3000 to 3001
```

### Database Connection Issues
If the app can't connect to the database:
1. Check if the database container is running: `docker-compose -f docker-compose.dev.yml ps`
2. Check database logs: `docker-compose -f docker-compose.dev.yml logs database`
3. Ensure the database is healthy: `docker-compose -f docker-compose.dev.yml exec database pg_isready -U documenso`

### Permission Issues
If you encounter permission issues on Linux/macOS:
```bash
# Fix file permissions
sudo chown -R $USER:$USER .

# Or run the setup script with sudo
sudo ./scripts/dev-setup.sh
```

### Clean Slate
To start completely fresh:
```bash
# Stop and remove everything
docker-compose -f docker-compose.dev.yml down -v
docker system prune -f

# Rebuild and start
./scripts/dev-setup.sh
```

## Production vs Development

This setup is specifically for development. For production deployment, use the existing production Dockerfile in the `docker/` directory.

## Support

If you encounter issues:
1. Check the [main README](../README.md)
2. Look at existing [GitHub issues](https://github.com/documenso/documenso/issues)
3. Create a new issue with details about your problem 