# =============================================================================
# Documenso Staging Environment - Terraform Outputs
# =============================================================================
# 
# This file defines outputs that will be displayed after Terraform apply.
# These outputs provide important information about the deployed infrastructure.
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.staging.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.staging.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.staging.private_ip
}

output "key_pair_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.staging.key_name
}

output "application_url" {
  description = "URL to access the Documenso application"
  value       = "http://${aws_eip.staging.public_ip}:${var.app_port}"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${aws_key_pair.staging.key_name} ec2-user@${aws_eip.staging.public_ip}"
}

output "deployment_instructions" {
  description = "Instructions for deploying the application"
  value = <<-EOT
    ================================================================================
    Documenso Staging Environment Deployment Instructions
    ================================================================================
    
    Infrastructure has been deployed successfully!
    The EC2 instance has been automatically configured with all necessary tools.
    
    Next steps:
    1. SSH into the instance:
       ssh -i ~/.ssh/${aws_key_pair.staging.key_name} ec2-user@${aws_eip.staging.public_ip}
    
    2. Clone the repository:
       sudo -u documenso git clone https://github.com/documenso/documenso.git /opt/documenso
    
    3. Configure environment:
       cp /opt/documenso/docker/staging/env.example /opt/documenso/docker/staging/.env
       nano /opt/documenso/docker/staging/.env
    
    4. Deploy the application:
       sudo -u documenso /usr/local/bin/deploy-documenso-staging
    
    5. Access the application:
       http://${aws_eip.staging.public_ip}:${var.app_port}
    
    Useful commands (already installed):
    - Deploy: /usr/local/bin/deploy-documenso-staging
    - Monitor: /usr/local/bin/monitor-documenso-staging
    - Backup: /usr/local/bin/backup-documenso-staging
    - Health check: /usr/local/bin/health-check.sh
    - View logs: docker-compose -f /opt/documenso/docker/staging/compose.yml logs -f
    
    Note: All management scripts and systemd service have been automatically installed.
    
    ================================================================================
  EOT
} 