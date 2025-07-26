# =============================================================================
# Documenso Staging Environment - Terraform Backend Configuration
# =============================================================================
# 
# This file configures the S3 backend for Terraform state storage.
# The backend provides:
# - Remote state storage in S3
# - State locking with DynamoDB
# - Encryption for security
# - Versioning for state history
#
# Before using this backend, run: ./setup-backend.sh
# =============================================================================

terraform {
  backend "s3" {
    bucket         = "documenso-terraform-state"
    key            = "staging/terraform.tfstate"
    region         = "ca-central-1"
    encrypt        = true
    dynamodb_table = "documenso-terraform-locks"
  }
} 