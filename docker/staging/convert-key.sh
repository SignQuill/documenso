#!/bin/bash

# Script to convert OpenSSH private key to RSA format for Nginx
# Usage: ./convert-key.sh

echo "Converting OpenSSH private key to RSA format..."

# Check if key file exists
if [ ! -f "key.pem" ]; then
    echo "Error: key.pem not found in current directory"
    exit 1
fi

# Create backup of original key
cp key.pem key.pem.backup

# Check if it's an OpenSSH key
if grep -q "BEGIN OPENSSH PRIVATE KEY" key.pem; then
    echo "Detected OpenSSH private key format"
    
    # Check if the key is encrypted
    if grep -q "bcrypt" key.pem || grep -q "aes256-ctr" key.pem; then
        echo "⚠ OpenSSH key is encrypted with a password"
        echo "   You'll need to provide the passphrase to decrypt it"
        echo ""
        echo "Attempting to decrypt and convert..."
        echo "When prompted, enter the password for your private key:"
        echo ""
        
        # Try to convert with passphrase prompt (interactive)
        ssh-keygen -p -f key.pem -m pem
        
        if [ $? -eq 0 ]; then
            echo "✓ Successfully decrypted and converted OpenSSH key to RSA format"
            echo "Original key backed up as key.pem.backup"
        else
            echo "✗ Failed to decrypt key. Please check your password."
            echo ""
            echo "Alternative solutions:"
            echo "1. Try again with correct password:"
            echo "   ssh-keygen -p -f key.pem -m pem"
            echo ""
            echo "2. Generate a new RSA key pair:"
            echo "   ./generate-new-key.sh"
            echo ""
            echo "3. Use your existing key with password (not recommended for Nginx):"
            echo "   You can manually enter the password each time Nginx starts"
            exit 1
        fi
    else
        # Try to convert unencrypted OpenSSH key to RSA format
        echo "Converting unencrypted OpenSSH key to RSA format..."
        ssh-keygen -p -f key.pem -m pem -N "" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "✓ Successfully converted OpenSSH key to RSA format"
            echo "Original key backed up as key.pem.backup"
        else
            echo "Failed to convert OpenSSH key. Trying alternative method..."
            
            # Alternative: use openssl to convert
            openssl rsa -in key.pem -out key.pem.rsa 2>/dev/null
            
            if [ $? -eq 0 ]; then
                echo "✓ Successfully converted using openssl"
                mv key.pem.rsa key.pem
                echo "Original key backed up as key.pem.backup"
            else
                echo "✗ Could not convert OpenSSH key."
                echo ""
                echo "Debugging information:"
                echo "Key file first few lines:"
                head -3 key.pem
                echo ""
                echo "File permissions:"
                ls -la key.pem
                echo ""
                echo "Manual conversion options:"
                echo "1. If key is encrypted: ssh-keygen -p -f key.pem -m pem"
                echo "2. Generate new RSA key: ./generate-new-key.sh"
                echo "3. Check key format: file key.pem"
                exit 1
            fi
        fi
    fi
else
    echo "Key doesn't appear to be in OpenSSH format. Trying standard conversions..."
    
    # Try to convert the key to RSA format
    echo "Attempting to convert key to RSA format..."
    openssl rsa -in key.pem -out key.pem.rsa 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✓ Successfully converted key to RSA format"
        mv key.pem.rsa key.pem
        echo "Original key backed up as key.pem.backup"
    else
        echo "Failed to convert key. Trying alternative method..."
        
        # Try to convert from PKCS#8 to RSA
        openssl pkcs8 -in key.pem -nocrypt -out key.pem.rsa 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "✓ Successfully converted PKCS#8 key to RSA format"
            mv key.pem.rsa key.pem
            echo "Original key backed up as key.pem.backup"
        else
            echo "✗ Could not convert key. Please check the key format manually."
            echo ""
            echo "Debugging information:"
            echo "Key file first few lines:"
            head -3 key.pem
            echo ""
            echo "File type:"
            file key.pem
            echo ""
            echo "The key should be in RSA format with headers like:"
            echo "-----BEGIN RSA PRIVATE KEY-----"
            echo "-----END RSA PRIVATE KEY-----"
            exit 1
        fi
    fi
fi

echo "Key conversion complete!" 