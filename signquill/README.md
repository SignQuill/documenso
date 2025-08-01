# SignQuill Production-Like Development Environment

This folder contains a production-like Docker configuration for running Documenso with SignQuill branding, using the same structure as the production environment.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Node.js 22+ (for local development)
- OpenSSL (for certificate generation)

### Running SignQuill

1. **Quick Start (Recommended):**
   ```bash
   cd signquill
   ./quick-start.sh
   ```

2. **Manual Start:**
   ```bash
   cd signquill
   # Copy environment template
   cp env.production .env
   # Generate certificate
   ./generate-cert.sh
   # Customize .env if needed
   docker compose up
   ```

3. **Access the application:**
   - Main app: http://localhost:3000
   - MinIO Console: http://localhost:9001
   - Email testing: http://localhost:9000

4. **Stop the environment:**
   ```bash
   docker compose down
   ```

## 📁 Files Overview

### `docker-compose.yml`
- Production-like environment structure
- Uses environment variables from `.env` file
- Includes PostgreSQL, MinIO, Redis, and email testing
- All branding environment variables configured
- Mounts development certificate for PDF signing

### `Dockerfile`
- Multi-stage production build process
- Includes branding processing during build
- Based on Node.js 22 Alpine
- Optimized for production deployment

### `start.sh`
- Production-like startup script
- Processes branding files at runtime
- Runs database migrations
- Starts production server

### `env.production`
- Comprehensive environment template
- All production variables included
- SignQuill branding pre-configured
- Copy to `.env` to customize

### `quick-start.sh`
- Automated setup script
- Creates `.env` from template
- Generates development certificate
- Starts all services
- Provides helpful output

### `generate-cert.sh`
- Generates self-signed development certificate
- Creates PKCS#12 format for application use
- Sets proper file permissions
- Includes certificate details and warnings

## 🔐 Certificate Configuration

The SignQuill setup includes PDF signing functionality with a development certificate:

### **Certificate Details**
- **Type**: Self-signed development certificate
- **Organization**: SignQuill
- **Common Name**: signquill.local
- **Validity**: 365 days
- **Password**: signquill
- **Format**: PKCS#12 (.p12)

### **Certificate Files**
```
certificates/
├── signquill.key    # Private key
├── signquill.crt    # Certificate
├── signquill.csr    # Certificate signing request
└── signquill.p12    # PKCS#12 bundle (used by app)
```

### **Environment Variables**
```bash
NEXT_PRIVATE_SIGNING_LOCAL_FILE_PATH=/opt/documenso/cert.p12
NEXT_PRIVATE_SIGNING_PASSPHRASE=signquill
```

### **Security Notes**
- ⚠️ **Development Only**: This is a self-signed certificate for development
- ⚠️ **Not for Production**: Do not use in production environments
- ⚠️ **Auto-Generated**: Certificate is generated automatically by the quick start script
- ✅ **Git Ignored**: Certificate files are excluded from version control

## 🎨 Branding Configuration

The SignQuill setup includes all branding environment variables in the `.env` file:

### Core Branding
```bash
NEXT_PUBLIC_APP_NAME=SignQuill
NEXT_PUBLIC_APP_SHORT_NAME=SignQuill
```

### Email Branding
```bash
NEXT_PRIVATE_SMTP_FROM_NAME=SignQuill
NEXT_PRIVATE_SMTP_FROM_ADDRESS=noreply@signquill.local
NEXT_PRIVATE_SERVICE_USER_EMAIL=serviceaccount@signquill.local
```

### Authentication Branding
```bash
NEXT_PRIVATE_AUTH_ISSUER=SignQuill
NEXT_PRIVATE_AUTH_RP_NAME=SignQuill
```

### Webhook Branding
```bash
NEXT_PRIVATE_WEBHOOK_SECRET_HEADER=X-SignQuill-Secret
```

### Signing Branding
```bash
NEXT_PRIVATE_SIGNING_CERTIFICATE_TEXT=Signed by SignQuill
```

### Analytics Branding
```bash
NEXT_PRIVATE_ANALYTICS_DOMAIN=signquill.com
```

### Company Branding
```bash
NEXT_PUBLIC_COMPANY_NAME=SignQuill, Inc.
NEXT_PUBLIC_COMPANY_NAME_NO_COMMA=SignQuill Inc.
```

## 🔧 Customization

### Changing Branding
To customize the branding for your own application:

1. **Edit the `.env` file:**
   ```bash
   # Edit branding variables
   NEXT_PUBLIC_APP_NAME=MyApp
   NEXT_PUBLIC_APP_SHORT_NAME=MyApp
   NEXT_PRIVATE_SMTP_FROM_NAME=MyApp
   NEXT_PRIVATE_WEBHOOK_SECRET_HEADER=X-MyApp-Secret
   # ... other branding variables
   ```

2. **Rebuild the containers:**
   ```bash
   docker compose down
   docker compose up --build
   ```

### Environment Variables
The `.env` file includes all production variables:

- **Core Configuration**: PORT, NODE_ENV
- **Database**: PostgreSQL connection strings
- **Storage**: S3/MinIO configuration
- **Email**: SMTP and alternative providers
- **Security**: Encryption keys and secrets
- **Features**: Feature flags and limits
- **Branding**: All SignQuill branding variables
- **Signing**: Certificate path and passphrase

## 🗄️ Services

### PostgreSQL Database
- **Image**: postgres:15
- **User**: signquill (configurable)
- **Database**: signquill (configurable)
- **Health Check**: Enabled

### MinIO (S3 Storage)
- **Console**: http://localhost:9001
- **API**: http://localhost:9002
- **User**: signquill
- **Password**: password

### Email Testing (Inbucket)
- **Web UI**: http://localhost:9000
- **SMTP**: localhost:2500
- **POP3**: localhost:1100

### Redis Cache
- **Port**: 6379
- **Purpose**: Session management

### SignQuill Application
- **Port**: 3000 (configurable)
- **Build**: Multi-stage production build
- **User**: nodejs (non-root)
- **Startup**: Production-like with migrations
- **Certificate**: Mounted for PDF signing

## 🛠️ Development

### Local Development
For local development without Docker:

1. **Set environment variables:**
   ```bash
   export $(cat .env | xargs)
   ```

2. **Process branding:**
   ```bash
   npm run branding:process
   ```

3. **Start development:**
   ```bash
   npm run dev
   ```

### Database Management
```bash
# Run migrations
npm run prisma:migrate-dev

# Seed database
npm run prisma:seed

# Open Prisma Studio
npm run prisma:studio
```

### Certificate Management
```bash
# Generate new certificate
./generate-cert.sh

# View certificate details
openssl pkcs12 -info -in certificates/signquill.p12 -noout

# Regenerate certificate (if needed)
rm -rf certificates/
./generate-cert.sh
```

## 🔍 Troubleshooting

### Common Issues

1. **Port conflicts:**
   - Change `PORT` in `.env` file
   - Stop other services using the same ports

2. **Database connection issues:**
   - Wait for database health check
   - Check PostgreSQL logs: `docker compose logs database`

3. **Branding not applied:**
   - Ensure `.env` file exists and has branding variables
   - Check branding processing: `docker compose logs signquill`

4. **Build issues:**
   - Clear Docker cache: `docker system prune`
   - Rebuild without cache: `docker compose build --no-cache`

5. **Environment variables missing:**
   - Copy template: `cp env.production .env`
   - Check required variables in docker-compose.yml

6. **Certificate issues:**
   - Regenerate certificate: `./generate-cert.sh`
   - Check certificate exists: `ls -la certificates/`
   - Verify certificate format: `file certificates/signquill.p12`

### Logs
```bash
# View all logs
docker compose logs

# View specific service logs
docker compose logs signquill
docker compose logs database
```

### Environment Variables
```bash
# Check current environment
docker compose config

# Validate environment
docker compose config --quiet
```

## 📚 Related Documentation

- [Main Branding Documentation](../BRANDING.md)
- [Production Docker Setup](../docker/production/compose.yml)
- [Production Dockerfile](../docker/Dockerfile)
- [Environment Variables](../turbo.json)

## 🤝 Contributing

When making changes to the SignQuill setup:

1. **Test the changes** with Docker Compose
2. **Update environment template** if needed
3. **Ensure branding** is properly applied
4. **Test all services** work correctly
5. **Update documentation** if needed
6. **Regenerate certificate** if certificate-related changes

## 📄 License

This SignQuill setup is part of the Documenso project and follows the same licensing terms. 