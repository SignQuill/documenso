# Docker Development Setup

This guide helps you set up Documenso for local development using Docker.

## Quick Start

1. **Run the setup script:**
   ```bash
   ./scripts/dev-setup.sh
   ```

2. **Wait for startup** (takes a few minutes on first run)

3. **Access the application:**
   - **App**: http://localhost:3000
   - **Email Testing**: http://localhost:9000
   - **MinIO Console**: http://localhost:9001

## What Gets Created

### Database Seeding
The setup automatically seeds the database with:

- **Admin User**: `admin@documenso.com` / `password`
- **Example User**: `example@documenso.com` / `password`
- **Sample Documents**: 8 example documents
- **Sample Templates**: 4 templates
- **Organization Settings**: Default signature preferences

### Services
- **PostgreSQL Database** (port 54320)
- **MinIO** (S3-compatible storage, ports 9001/9002)
- **Inbucket** (email testing, port 9000)
- **Redis** (caching, port 6379)
- **Documenso App** (port 3000)

## Admin User

The seeding process creates an admin user with full access:

- **Email**: `admin@documenso.com`
- **Password**: `password`
- **Role**: Admin (can access admin features)

## Signature Settings

The seed creates proper organization and team settings with all signature types enabled:
- ✅ Typed signatures
- ✅ Upload signatures  
- ✅ Draw signatures

This fixes the "Sign Here" field issue in the signup form.

## Development Approach

This setup uses **built code** rather than mounted source code for development. This means:

### Advantages:
- ✅ More stable and production-like environment
- ✅ Faster container startup (no volume mounting)
- ✅ Consistent behavior across different environments
- ✅ Better isolation from host system

### Trade-offs:
- ⚠️ Code changes require rebuilding the container
- ⚠️ No hot reloading of source code changes
- ⚠️ Longer iteration cycle for development

### Making Code Changes:
To apply code changes, you need to rebuild the container:

```bash
# Rebuild and restart the app container
docker-compose -f docker-compose.dev.yml up --build -d app

# Or rebuild all services
docker-compose -f docker-compose.dev.yml up --build -d
```

## Useful Commands

```bash
# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Stop services
docker-compose -f docker-compose.dev.yml down

# Restart app
docker-compose -f docker-compose.dev.yml restart app

# Rebuild app after code changes
docker-compose -f docker-compose.dev.yml up --build -d app

# Access app shell
docker-compose -f docker-compose.dev.yml exec app sh

# View database
docker-compose -f docker-compose.dev.yml exec database psql -U documenso -d documenso
```

## Troubleshooting

### Signup Form Issues
If the "Sign Here" field doesn't work:
1. Ensure the database has been seeded
2. Check that organization settings exist
3. Verify signature type flags are enabled

### Database Connection Issues
- Check if PostgreSQL container is running
- Verify environment variables in `.env`
- Check logs: `docker-compose -f docker-compose.dev.yml logs database`

### Email Issues
- Check Inbucket at http://localhost:9000
- Verify SMTP settings in environment variables

### Code Changes Not Reflecting
- Rebuild the container: `docker-compose -f docker-compose.dev.yml up --build -d app`
- Check that the build completed successfully
- Verify the new code is in the container

## Manual Setup

If you prefer manual setup:

1. **Create environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Start services:**
   ```bash
   docker-compose -f docker-compose.dev.yml up -d
   ```

3. **Run migrations and seed:**
   ```bash
   docker-compose -f docker-compose.dev.yml exec app npm run prisma:migrate-dev
   docker-compose -f docker-compose.dev.yml exec app npm run prisma:seed
   ```

## Environment Variables

Key environment variables for development:

```bash
# Database
DATABASE_URL="postgresql://documenso:password@database:5432/documenso"
NEXT_PRIVATE_DATABASE_URL="postgresql://documenso:password@database:5432/documenso"
NEXT_PRIVATE_DIRECT_DATABASE_URL="postgresql://documenso:password@database:5432/documenso"

# App
NEXT_PUBLIC_APP_URL="http://localhost:3000"
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="your-secret-key-here"

# Storage
NEXT_PRIVATE_S3_ENDPOINT="http://minio:9000"
NEXT_PRIVATE_S3_ACCESS_KEY="documenso"
NEXT_PRIVATE_S3_SECRET_KEY="password"

# Email
NEXT_PRIVATE_SMTP_HOST="mailserver"
NEXT_PRIVATE_SMTP_PORT="2500"
NEXT_PRIVATE_SMTP_FROM="noreply@documenso.local"

# Jobs
NEXT_PRIVATE_JOBS_PROVIDER="local"
NEXT_PRIVATE_INTERNAL_WEBAPP_URL="http://localhost:3000"
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