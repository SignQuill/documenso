#!/bin/bash

# SignQuill Certificate Generation Script
# This script generates a self-signed certificate for development

set -e

echo "🔐 Generating SignQuill development certificate..."

# Create certificates directory if it doesn't exist
mkdir -p certificates

# Generate private key
echo "📝 Generating private key..."
openssl genrsa -out certificates/signquill.key 2048

# Generate certificate signing request
echo "📝 Generating certificate signing request..."
openssl req -new -key certificates/signquill.key -out certificates/signquill.csr -subj "/C=US/ST=Development/L=Development/O=SignQuill/OU=Development/CN=signquill.local"

# Generate self-signed certificate
echo "📝 Generating self-signed certificate..."
openssl x509 -req -days 365 -in certificates/signquill.csr -signkey certificates/signquill.key -out certificates/signquill.crt

# Convert to PKCS#12 format (required by the application)
echo "📝 Converting to PKCS#12 format..."
openssl pkcs12 -export -out certificates/signquill.p12 -inkey certificates/signquill.key -in certificates/signquill.crt -passout pass:signquill

# Set permissions
chmod 600 certificates/signquill.key
chmod 644 certificates/signquill.crt
chmod 600 certificates/signquill.p12

echo "✅ Certificate generated successfully!"
echo ""
echo "📁 Certificate files created:"
echo "   • certificates/signquill.key (private key)"
echo "   • certificates/signquill.crt (certificate)"
echo "   • certificates/signquill.p12 (PKCS#12 bundle)"
echo ""
echo "🔐 Certificate details:"
echo "   • Common Name: signquill.local"
echo "   • Organization: SignQuill"
echo "   • Valid for: 365 days"
echo "   • Password: signquill"
echo ""
echo "⚠️  This is a self-signed certificate for development only!"
echo "   Do not use in production environments." 