#!/bin/bash

set -e

# Configuration
EC2_USER="ec2-user"
EC2_HOST="15.223.249.208"
EC2_KEY_PATH="/Users/lex/.ssh/id_rsa_documenso_aws"
REMOTE_DIR="/opt/documenso"

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

# Check if required parameters are provided
if [ -z "$EC2_HOST" ] || [ -z "$EC2_KEY_PATH" ]; then
    print_error "Please set EC2_HOST and EC2_KEY_PATH variables at the top of this script"
    echo ""
    echo "Usage:"
    echo "1. Edit this script and set:"
    echo "   EC2_HOST=your-ec2-ip-or-domain"
    echo "   EC2_KEY_PATH=path/to/your/key.pem"
    echo "2. Run: ./deploy-to-ec2.sh"
    exit 1
fi

# Check if key file exists
if [ ! -f "$EC2_KEY_PATH" ]; then
    print_error "SSH key file not found: $EC2_KEY_PATH"
    exit 1
fi

print_step "Deploying Documenso staging to EC2..."
print_status "EC2 Host: $EC2_HOST"
print_status "Remote Directory: $REMOTE_DIR"

# Test SSH connection
print_step "Testing SSH connection..."
if ! ssh -i "$EC2_KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$EC2_USER@$EC2_HOST" "echo 'SSH connection successful'" > /dev/null 2>&1; then
    print_error "Failed to connect to EC2 instance. Please check:"
    print_error "1. EC2_HOST is correct"
    print_error "2. EC2_KEY_PATH is correct"
    print_error "3. Security group allows SSH (port 22)"
    print_error "4. Instance is running"
    exit 1
fi

print_status "SSH connection successful!"

# Check if Docker is installed and running
print_step "Checking Docker installation..."
if ! ssh -i "$EC2_KEY_PATH" "$EC2_USER@$EC2_HOST" "docker --version" > /dev/null 2>&1; then
    print_error "Docker is not installed on the EC2 instance."
    print_error "Please ensure Docker is installed before running this script."
    print_error "You can install Docker using:"
    print_error "sudo yum update -y && sudo yum install -y docker && sudo systemctl start docker && sudo systemctl enable docker"
    exit 1
fi

if ! ssh -i "$EC2_KEY_PATH" "$EC2_USER@$EC2_HOST" "sudo systemctl is-active --quiet docker" > /dev/null 2>&1; then
    print_warning "Docker is installed but not running. Starting Docker..."
    ssh -i "$EC2_KEY_PATH" "$EC2_USER@$EC2_HOST" "sudo systemctl start docker && sudo systemctl enable docker"
fi

print_status "Docker is installed and running!"

# Check if docker-compose is available
print_step "Checking docker-compose..."
if ! ssh -i "$EC2_KEY_PATH" "$EC2_USER@$EC2_HOST" "docker-compose --version" > /dev/null 2>&1; then
    print_warning "docker-compose not found. Installing docker-compose..."
    ssh -i "$EC2_KEY_PATH" "$EC2_USER@$EC2_HOST" "
        sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    "
fi

print_status "docker-compose is available!"

# Create remote directory structure and ensure documenso user exists
print_step "Creating remote directory structure..."
ssh -i "$EC2_KEY_PATH" "$EC2_USER@$EC2_HOST" "
    # Create documenso user if it doesn't exist
    if ! id 'documenso' &>/dev/null; then
        sudo useradd -m -s /bin/bash documenso
        sudo usermod -aG docker documenso
    fi
    
    # Create temporary directory for ec2-user (with proper permissions)
    mkdir -p /tmp/documenso-staging
    chmod 755 /tmp/documenso-staging
    
    # Create final directory structure
    sudo mkdir -p $REMOTE_DIR/docker/staging
    
    # Set proper ownership
    sudo chown -R documenso:documenso $REMOTE_DIR
    sudo chmod 755 $REMOTE_DIR
"

# Copy staging files to temporary location
print_step "Copying staging files to EC2..."

# Function to copy file with retry
copy_file_with_retry() {
    local local_file="$1"
    local remote_file="$2"
    local max_attempts=3
    
    for attempt in $(seq 1 $max_attempts); do
        # Ensure temporary directory exists
        ssh -i "$EC2_KEY_PATH" "$EC2_USER@$EC2_HOST" "mkdir -p /tmp/documenso-staging && chmod 755 /tmp/documenso-staging"
        
        if scp -i "$EC2_KEY_PATH" "$local_file" "$EC2_USER@$EC2_HOST:/tmp/documenso-staging/"; then
            return 0
        else
            print_warning "Failed to copy $local_file (attempt $attempt/$max_attempts)"
            if [ $attempt -lt $max_attempts ]; then
                sleep 2
            fi
        fi
    done
    
    print_error "Failed to copy $local_file after $max_attempts attempts"
    return 1
}

# Copy all files with retry logic
copy_file_with_retry docker/staging/Dockerfile Dockerfile
copy_file_with_retry docker/staging/compose.yml compose.yml
copy_file_with_retry docker/staging/start.sh start.sh
copy_file_with_retry docker/staging/env.example env.example
copy_file_with_retry docker/staging/deploy.sh deploy.sh
copy_file_with_retry docker/staging/build-local.sh build-local.sh
copy_file_with_retry docker/staging/push-to-dockerhub.sh push-to-dockerhub.sh
copy_file_with_retry docker/staging/README.md README.md

print_status "Files copied successfully!"

# Move files from temporary location to final destination
print_step "Moving files to final destination..."
ssh -i "$EC2_KEY_PATH" "$EC2_USER@$EC2_HOST" "
    # Move all files from temporary location to final destination
    sudo cp -r /tmp/documenso-staging/* $REMOTE_DIR/docker/staging/
    
    # Set proper ownership
    sudo chown -R documenso:documenso $REMOTE_DIR/docker/staging/
    
    # Set proper permissions
    sudo chmod +x $REMOTE_DIR/docker/staging/*.sh
    
    # Clean up temporary directory
    rm -rf /tmp/documenso-staging
"

# Check if .env file exists locally and copy it
if [ -f "docker/staging/.env" ]; then
    print_step "Copying .env file..."
    # Use the same retry function for .env file
    if copy_file_with_retry docker/staging/.env .env; then
        ssh -i "$EC2_KEY_PATH" "$EC2_USER@$EC2_HOST" "
            sudo cp /tmp/documenso-staging/.env $REMOTE_DIR/docker/staging/
            sudo chown documenso:documenso $REMOTE_DIR/docker/staging/.env
            rm -f /tmp/documenso-staging/.env
        "
        print_status ".env file copied"
    else
        print_error "Failed to copy .env file"
        exit 1
    fi
else
    print_warning "No .env file found locally. You'll need to create one on the EC2 instance:"
    print_warning "ssh -i $EC2_KEY_PATH $EC2_USER@$EC2_HOST"
    print_warning "cp $REMOTE_DIR/docker/staging/env.example $REMOTE_DIR/docker/staging/.env"
    print_warning "nano $REMOTE_DIR/docker/staging/.env"
fi

# Deploy the application
print_step "Deploying application..."
ssh -i "$EC2_KEY_PATH" "$EC2_USER@$EC2_HOST" "cd $REMOTE_DIR && sudo -u documenso /usr/local/bin/deploy-documenso-staging"

print_status "Deployment completed!"
echo ""
print_status "Next steps:"
echo "1. SSH into the instance: ssh -i $EC2_KEY_PATH $EC2_USER@$EC2_HOST"
echo "2. Check application status: /usr/local/bin/monitor-documenso-staging"
echo "3. View logs: docker-compose -f $REMOTE_DIR/docker/staging/compose.yml logs -f"
echo "4. Access application: http://$EC2_HOST:3000"
echo ""
print_status "Useful commands on EC2:"
echo "- Deploy: /usr/local/bin/deploy-documenso-staging"
echo "- Monitor: /usr/local/bin/monitor-documenso-staging"
echo "- Backup: /usr/local/bin/backup-documenso-staging"
echo "- Health check: /usr/local/bin/health-check.sh" 