#!/bin/bash

echo "=== Certificate and Key File Checker ==="

# Check if files exist
echo "Checking if certificate files exist..."
if [ -f "cert.pem" ]; then
    echo "✓ cert.pem exists"
else
    echo "✗ cert.pem not found"
fi

if [ -f "key.pem" ]; then
    echo "✓ key.pem exists"
else
    echo "✗ key.pem not found"
fi

echo ""
echo "=== Certificate Information ==="
if [ -f "cert.pem" ]; then
    echo "Certificate details:"
    openssl x509 -in cert.pem -text -noout | head -20
fi

echo ""
echo "=== Private Key Information ==="
if [ -f "key.pem" ]; then
    echo "Private key format:"
    head -1 key.pem
    
    echo ""
    echo "Checking key format..."
    if grep -q "BEGIN RSA PRIVATE KEY" key.pem; then
        echo "✓ Key is in RSA format (compatible with Nginx)"
    elif grep -q "BEGIN OPENSSH PRIVATE KEY" key.pem; then
        echo "⚠ Key is in OpenSSH format (needs conversion for Nginx)"
        echo "   Run: ./convert-key.sh to convert to RSA format"
    elif grep -q "BEGIN PRIVATE KEY" key.pem; then
        echo "⚠ Key is in PKCS#8 format (may need conversion)"
    elif grep -q "BEGIN EC PRIVATE KEY" key.pem; then
        echo "⚠ Key is in EC format (may need conversion)"
    else
        echo "✗ Unknown key format"
        echo "   First line of key file:"
        head -1 key.pem
    fi
fi

echo ""
echo "=== File Permissions ==="
if [ -f "cert.pem" ]; then
    ls -la cert.pem
fi
if [ -f "key.pem" ]; then
    ls -la key.pem
fi

echo ""
echo "=== Conversion Instructions ==="
if [ -f "key.pem" ] && grep -q "BEGIN OPENSSH PRIVATE KEY" key.pem; then
    echo "To convert OpenSSH key to RSA format:"
    echo "1. Run: ./convert-key.sh"
    echo "2. Restart Docker containers: docker-compose down && docker-compose up -d"
fi 