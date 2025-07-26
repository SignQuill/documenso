-- Initialize database for Documenso staging environment
-- This script runs when the PostgreSQL container starts for the first time

-- Create the database if it doesn't exist
SELECT 'CREATE DATABASE documenso_staging'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'documenso_staging')\gexec

-- Connect to the new database
\c documenso_staging;

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON DATABASE documenso_staging TO documenso;
GRANT ALL PRIVILEGES ON SCHEMA public TO documenso;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO documenso;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO documenso; 