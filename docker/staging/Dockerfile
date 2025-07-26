FROM node:22-alpine3.20

# Install system dependencies
RUN apk add --no-cache \
    libc6-compat \
    openssl \
    bash \
    git

# Set working directory
WORKDIR /app

# Disable husky from installing hooks
ENV HUSKY 0
ENV DOCKER_OUTPUT 1
ENV NEXT_TELEMETRY_DISABLED 1

# Copy package files first for better caching
COPY package.json ./
COPY turbo.json ./
COPY lingui.config.ts ./

# Copy workspace package.json files
COPY apps/remix/package.json ./apps/remix/
COPY apps/documentation/package.json ./apps/documentation/
COPY apps/openpage-api/package.json ./apps/openpage-api/

# Copy packages package.json files (explicitly list them to avoid conflicts)
COPY packages/api/package.json ./packages/api/
COPY packages/app-tests/package.json ./packages/app-tests/
COPY packages/assets/package.json ./packages/assets/
COPY packages/auth/package.json ./packages/auth/
COPY packages/ee/package.json ./packages/ee/
COPY packages/email/package.json ./packages/email/
COPY packages/eslint-config/package.json ./packages/eslint-config/
COPY packages/lib/package.json ./packages/lib/
COPY packages/prettier-config/package.json ./packages/prettier-config/
COPY packages/prisma/package.json ./packages/prisma/
COPY packages/signing/package.json ./packages/signing/
COPY packages/tailwind-config/package.json ./packages/tailwind-config/
COPY packages/trpc/package.json ./packages/trpc/
COPY packages/tsconfig/package.json ./packages/tsconfig/
COPY packages/ui/package.json ./packages/ui/

# Copy package-lock.json after all package.json files are in place
COPY package-lock.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Generate Prisma client
RUN npm run prisma:generate

# Compile translations
RUN npm run translate:compile

# Expose port
EXPOSE 3000

# Copy start script
COPY docker/staging/start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Default command for development
CMD ["/app/start.sh"] 