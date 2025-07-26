#!/bin/bash

echo "Starting Documenso staging environment..."

# Wait for database to be ready
echo "Waiting for database to be ready..."
until npx prisma migrate status --schema=/app/packages/prisma/schema.prisma > /dev/null 2>&1; do
  echo "Database not ready, waiting..."
  sleep 2
done

# Run Prisma migrations
echo "Running Prisma migrations..."
npx prisma migrate deploy --schema=/app/packages/prisma/schema.prisma

# Check if User table exists and has data
echo "Checking database state..."
USER_COUNT=$(npx prisma db execute --schema=/app/packages/prisma/schema.prisma --stdin <<< "SELECT COUNT(*) FROM \"User\";" 2>/dev/null | tail -1 | tr -d ' ' || echo "0")

if [ "$USER_COUNT" = "0" ] || [ "$USER_COUNT" = "" ]; then
    echo "Database appears to be empty or User table missing. Running database reset..."
    npx prisma migrate reset --schema=/app/packages/prisma/schema.prisma --force
    echo "Database reset completed."
else
    echo "Database has $USER_COUNT users. Skipping reset."
fi

# Generate Prisma client (in case it's needed)
echo "Generating Prisma client..."
npx prisma generate --schema=/app/packages/prisma/schema.prisma

# Start the application
echo "Starting application..."
npm run dev 