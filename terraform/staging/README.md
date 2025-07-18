# Documenso Staging Environment - Terraform Configuration

This directory contains the Terraform configuration to deploy the complete infrastructure for the Documenso staging environment on AWS.

## Overview

The Terraform configuration creates:
- **VPC** with public and private subnets across multiple availability zones
- **Security Groups** with proper access controls
- **EC2 Instance** with Amazon Linux 2 and Docker
- **Elastic IP** for stable public access
- **IAM Roles** for EC2 instance permissions
- **Key Pair** for SSH access

## File Structure

```
terraform/staging/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output values
├── user-data.sh              # EC2 instance initialization script
├── terraform.tfvars.example  # Example variables file
└── README.md                 # This file
```

## Prerequisites

1. **Terraform** (version >= 1.0)
2. **AWS CLI** configured with appropriate credentials
3. **SSH Key Pair** for EC2 access

## Quick Start

### 1. Configure AWS Credentials

```bash
# Configure AWS CLI
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 2. Generate SSH Key Pair

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/documenso-staging -N ""

# Display public key to copy to terraform.tfvars
cat ~/.ssh/documenso-staging.pub
```

### 3. Configure Variables

```bash
# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit the file with your values
nano terraform.tfvars
```

### 4. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 5. Deploy Application

After the infrastructure is deployed, follow the instructions in the Terraform output to deploy the Documenso application.

## Configuration

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region to deploy resources | `us-east-1` |
| `project_name` | Name of the project | `documenso` |
| `environment` | Environment name | `staging` |
| `vpc_cidr` | CIDR block for VPC | `10.0.0.0/16` |
| `instance_type` | EC2 instance type | `t3.medium` |
| `app_port` | Application port | `3000` |
| `ssh_public_key` | SSH public key | Required |
| `allowed_ssh_cidr_blocks` | SSH access CIDR blocks | `["0.0.0.0/0"]` |

### Security Groups

The configuration creates security groups with the following rules:

**EC2 Security Group:**
- SSH (22): From specified CIDR blocks
- HTTP (80): From anywhere
- HTTPS (443): From anywhere
- Application Port (3000): From anywhere
- All outbound traffic

## Infrastructure Components

### VPC and Networking
- **VPC**: `10.0.0.0/16` with DNS support enabled
- **Public Subnets**: 2 subnets across different AZs
- **Private Subnets**: 2 subnets across different AZs
- **Internet Gateway**: For public internet access
- **Route Tables**: Proper routing for public subnets

### EC2 Instance
- **AMI**: Latest Amazon Linux 2
- **Instance Type**: t3.medium (configurable)
- **Storage**: 20GB GP3 encrypted volume
- **IAM Role**: With CloudWatch Logs permissions
- **User Data**: Automated initialization script

### Security
- **Key Pair**: SSH access with specified public key
- **Security Groups**: Proper access controls
- **Encrypted Storage**: Root volume encryption enabled
- **IAM Roles**: Least privilege access

## User Data Script

The EC2 instance runs a user data script that:
1. Updates system packages
2. Installs Docker and Docker Compose
3. Creates documenso user with proper permissions
4. Sets up application directories
5. Configures firewall rules
6. Creates health check scripts

## Outputs

After successful deployment, Terraform will output:
- **Instance Information**: ID, public/private IPs
- **Network Information**: VPC ID, subnet IDs
- **Access Information**: SSH command, application URL
- **Deployment Instructions**: Step-by-step guide

## Management

### View Infrastructure Status

```bash
# Show current state
terraform show

# List resources
terraform state list
```

### Update Infrastructure

```bash
# Plan changes
terraform plan

# Apply changes
terraform apply
```

### Destroy Infrastructure

```bash
# Destroy all resources
terraform destroy
```

## Monitoring and Logging

### CloudWatch Integration
The EC2 instance has IAM permissions for CloudWatch Logs, allowing you to:
- Send application logs to CloudWatch
- Create log groups and streams
- Monitor application performance

### Health Checks
The user data script creates a health check script at `/usr/local/bin/health-check.sh` that can be used for monitoring.

## Security Considerations

### Network Security
- **Public Subnets**: Only for load balancers and bastion hosts
- **Private Subnets**: For application servers (future use)
- **Security Groups**: Restrictive access controls
- **SSH Access**: Configurable CIDR blocks

### Instance Security
- **Encrypted Storage**: Root volume encryption
- **IAM Roles**: Least privilege access
- **User Permissions**: Non-root user for application
- **Firewall Rules**: OS-level firewall configuration

### Production Recommendations
1. **Restrict SSH Access**: Limit to specific IP ranges
2. **Use Private Subnets**: Move application to private subnets
3. **Add Load Balancer**: For high availability
4. **Enable CloudTrail**: For audit logging
5. **Use AWS Secrets Manager**: For sensitive configuration
6. **Add Monitoring**: CloudWatch alarms and dashboards

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   ```bash
   # Check security group rules
   aws ec2 describe-security-groups --group-ids <sg-id>
   
   # Verify key pair
   ssh -i ~/.ssh/documenso-staging -v ec2-user@<public-ip>
   ```

2. **Application Not Accessible**
   ```bash
   # Check application status
   ssh -i ~/.ssh/documenso-staging ec2-user@<public-ip>
   docker ps
   docker-compose -f /opt/documenso/docker/staging/compose.yml logs
   ```

3. **Terraform Errors**
   ```bash
   # Validate configuration
   terraform validate
   
   # Check state
   terraform state list
   ```

### Logs and Debugging

```bash
# View user data logs
ssh -i ~/.ssh/documenso-staging ec2-user@<public-ip>
sudo cat /var/log/user-data.log

# View system logs
sudo journalctl -f

# View Docker logs
docker logs <container-name>
```

## Cost Optimization

### Instance Sizing
- **Development**: t3.small or t3.medium
- **Staging**: t3.medium (current)
- **Production**: t3.large or larger

### Storage Optimization
- **Root Volume**: 20GB (sufficient for staging)
- **Volume Type**: GP3 (cost-effective)

### Network Optimization
- **Elastic IP**: Free when attached to running instance
- **Data Transfer**: Monitor and optimize

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review Terraform documentation
3. Check AWS CloudTrail for API errors
4. Open an issue on GitHub

## License

This Terraform configuration is part of the Documenso project and follows the same license terms. 