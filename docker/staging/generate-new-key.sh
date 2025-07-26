#!/bin/bash

# Script to generate a new RSA key pair for SSL/TLS
# Usage: ./generate-new-key.sh

echo "Generating new RSA key pair for SSL/TLS..."

# Check if we should backup existing files
if [ -f "key.pem" ]; then
    echo "Backing up existing key.pem to key.pem.old"
    mv key.pem key.pem.old
fi

if [ -f "cert.pem" ]; then
    echo "Backing up existing cert.pem to cert.pem.old"
    mv cert.pem cert.pem.old
fi

# Generate new RSA private key
echo "Generating RSA private key..."
openssl genrsa -out key.pem 2048

if [ $? -eq 0 ]; then
    echo "✓ Successfully generated RSA private key"
else
    echo "✗ Failed to generate RSA private key"
    exit 1
fi

# Generate self-signed certificate
echo "Generating self-signed certificate..."
openssl req -new -x509 -key key.pem -out cert.pem -days 365 -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

if [ $? -eq 0 ]; then
    echo "✓ Successfully generated self-signed certificate"
else
    echo "✗ Failed to generate certificate"
    exit 1
fi

# Set proper permissions
chmod 600 key.pem
chmod 644 cert.pem

echo ""
echo "✓ New RSA key pair generated successfully!"
echo "  - Private key: key.pem"
echo "  - Certificate: cert.pem"
echo ""
echo "Note: This is a self-signed certificate for testing."
echo "For production, replace cert.pem with your actual SSL certificate."
echo ""
echo "You can now restart your Docker containers:"
echo "docker-compose down && docker-compose up -d" 