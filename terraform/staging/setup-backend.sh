#!/bin/bash

# =============================================================================
# Documenso Staging - Terraform S3 Backend Setup Script
# =============================================================================
# 
# This script creates the S3 bucket and DynamoDB table required for
# Terraform remote state storage. It sets up:
# - S3 bucket with versioning and encryption
# - DynamoDB table for state locking
# - Proper IAM permissions
# - Bucket policies for security
#
# Usage: ./setup-backend.sh
# Requirements: AWS CLI configured with appropriate permissions
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Configuration
BUCKET_NAME="documenso-terraform-state"
DYNAMODB_TABLE="documenso-terraform-locks"
REGION="us-east-1"

print_step "Setting up Terraform S3 backend..."

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &>/dev/null; then
    print_error "AWS CLI is not configured. Please run 'aws configure' first."
    exit 1
fi

# Create S3 bucket
print_step "Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION" || {
    print_warning "Bucket might already exist or creation failed"
}

# Enable versioning
print_step "Enabling versioning on S3 bucket"
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

# Enable server-side encryption
print_step "Enabling server-side encryption"
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Block public access
print_step "Blocking public access to S3 bucket"
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
        BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Create DynamoDB table for state locking
print_step "Creating DynamoDB table: $DYNAMODB_TABLE"
aws dynamodb create-table \
    --table-name "$DYNAMODB_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region "$REGION" || {
    print_warning "DynamoDB table might already exist or creation failed"
}

# Wait for DynamoDB table to be active
print_step "Waiting for DynamoDB table to be active..."
aws dynamodb wait table-exists --table-name "$DYNAMODB_TABLE" --region "$REGION"

# Create bucket policy for additional security
print_step "Creating S3 bucket policy"
cat > /tmp/bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyUnencryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "AES256"
                }
            }
        },
        {
            "Sid": "DenyIncorrectEncryptionHeader",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "AES256"
                }
            }
        },
        {
            "Sid": "DenyUnencryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*",
            "Condition": {
                "Null": {
                    "s3:x-amz-server-side-encryption": "true"
                }
            }
        }
    ]
}
EOF

aws s3api put-bucket-policy \
    --bucket "$BUCKET_NAME" \
    --policy file:///tmp/bucket-policy.json

# Clean up temporary file
rm /tmp/bucket-policy.json

print_status "✅ S3 backend setup completed successfully!"

echo ""
print_status "Backend Configuration:"
echo "  S3 Bucket: $BUCKET_NAME"
echo "  DynamoDB Table: $DYNAMODB_TABLE"
echo "  Region: $REGION"
echo "  State File: staging/terraform.tfstate"
echo ""
print_status "Next steps:"
echo "1. Run: terraform init"
echo "2. Run: terraform plan"
echo "3. Run: terraform apply"
echo ""
print_status "Note: The backend configuration is already set in main.tf" 