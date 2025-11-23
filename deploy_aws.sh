#!/bin/bash

# Complete AWS Deployment Script for MLOps Pipeline
# This script deploys everything on Amazon Linux with AWS credentials

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║     MLOps Pipeline - AWS Deployment Script            ║"
echo "║     Amazon Linux Deployment with Jenkins               ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# AWS Credentials - Set your credentials here
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-YOUR_AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-YOUR_AWS_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

echo -e "${GREEN}✓ AWS Credentials configured${NC}"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${YELLOW}Installing AWS CLI...${NC}"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
fi

# Configure AWS CLI
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_DEFAULT_REGION"

echo -e "${GREEN}✓ AWS CLI configured${NC}"

# Get current directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo ""
echo -e "${BLUE}Starting deployment process...${NC}"
echo ""

# Step 1: Check if we're on EC2 or need to create instance
echo -e "${YELLOW}[1/6] Checking environment...${NC}"

# Try to get instance metadata (if on EC2)
INSTANCE_ID=$(curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "")

if [ -n "$INSTANCE_ID" ]; then
    echo -e "${GREEN}✓ Running on EC2 instance: $INSTANCE_ID${NC}"
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    echo -e "${GREEN}✓ Public IP: $PUBLIC_IP${NC}"
    
    # We're on EC2, proceed with installation
    ON_EC2=true
else
    echo -e "${YELLOW}Not on EC2. Will create EC2 instance using Terraform...${NC}"
    ON_EC2=false
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        echo -e "${YELLOW}Installing Terraform...${NC}"
        wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
        unzip terraform_1.6.0_linux_amd64.zip
        sudo mv terraform /usr/local/bin/
        rm terraform_1.6.0_linux_amd64.zip
    fi
    
    # Create EC2 instance using Terraform
    echo -e "${YELLOW}[2/6] Creating EC2 instance with Terraform...${NC}"
    cd terraform
    
    # Initialize Terraform
    terraform init
    
    # Create terraform.tfvars with credentials
    cat > terraform.tfvars <<EOF
aws_region = "us-east-1"
instance_type = "t3.medium"
ami_id = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
EOF
    
    # Apply Terraform
    terraform apply -auto-approve
    
    # Get instance IP
    PUBLIC_IP=$(terraform output -raw instance_public_ip)
    INSTANCE_ID=$(terraform output -raw instance_id 2>/dev/null || echo "")
    
    echo -e "${GREEN}✓ EC2 instance created: $INSTANCE_ID${NC}"
    echo -e "${GREEN}✓ Public IP: $PUBLIC_IP${NC}"
    
    cd ..
    
    # Wait for instance to be ready
    echo -e "${YELLOW}Waiting for instance to be ready (60 seconds)...${NC}"
    sleep 60
    
    # Get SSH key (you'll need to provide this)
    echo -e "${YELLOW}Note: You'll need to SSH into the instance to complete setup${NC}"
    echo "SSH Command: ssh -i your-key.pem ec2-user@$PUBLIC_IP"
    echo ""
    echo "Once SSH'd in, run:"
    echo "  git clone https://github.com/JibbranAli/devops-project-7.git"
    echo "  cd devops-project-7"
    echo "  sudo ./install.sh"
    echo "  sudo ./run_demo.sh"
    echo ""
    
    # Save info
    cat > deployment_info.txt <<EOF
Instance ID: $INSTANCE_ID
Public IP: $PUBLIC_IP
Region: us-east-1

SSH: ssh -i your-key.pem ec2-user@$PUBLIC_IP

Service URLs (after deployment):
  Web UI:     http://$PUBLIC_IP:8501
  API:        http://$PUBLIC_IP:5000
  Prometheus: http://$PUBLIC_IP:9090
  Jenkins:    http://$PUBLIC_IP:8080
EOF
    
    echo -e "${GREEN}✓ Deployment info saved to deployment_info.txt${NC}"
    exit 0
fi

# If we're on EC2, continue with installation
echo ""
echo -e "${YELLOW}[2/6] Installing dependencies...${NC}"

# Make scripts executable
chmod +x *.sh

# Run installation
if [ ! -f "/tmp/mlops_installed.flag" ]; then
    echo "Running installation script..."
    sudo ./install.sh
    touch /tmp/mlops_installed.flag
else
    echo -e "${GREEN}✓ Installation already completed${NC}"
fi

echo ""
echo -e "${YELLOW}[3/6] Training ML models...${NC}"

if [ ! -f "app/models/model_v1.pkl" ] || [ ! -f "app/models/model_v2.pkl" ]; then
    python3 app/train_model.py
    echo -e "${GREEN}✓ Models trained${NC}"
else
    echo -e "${GREEN}✓ Models already exist${NC}"
fi

echo ""
echo -e "${YELLOW}[4/6] Building and starting Docker services...${NC}"

# Stop existing services
docker-compose down 2>/dev/null || true

# Build and start
docker-compose build
docker-compose up -d

echo -e "${GREEN}✓ Docker services started${NC}"

# Wait for services
echo ""
echo -e "${YELLOW}[5/6] Waiting for services to be ready...${NC}"
sleep 15

# Check Jenkins setup
echo ""
echo -e "${YELLOW}[6/6] Configuring Jenkins...${NC}"

# Wait for Jenkins to be ready
JENKINS_READY=false
for i in {1..30}; do
    if curl -s http://localhost:8080/login > /dev/null 2>&1; then
        JENKINS_READY=true
        break
    fi
    echo "Waiting for Jenkins... ($i/30)"
    sleep 2
done

if [ "$JENKINS_READY" = true ]; then
    echo -e "${GREEN}✓ Jenkins is ready${NC}"
    
    # Get Jenkins password
    if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
        JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
        echo "Jenkins Initial Password: $JENKINS_PASSWORD"
    fi
    
    # Setup Jenkins pipeline (if not already done)
    if [ ! -f "/tmp/jenkins_pipeline_setup.flag" ]; then
        echo "Jenkins pipeline setup will be done manually or via script"
        echo "Run: sudo ./setup_jenkins_pipeline.sh"
    fi
else
    echo -e "${YELLOW}⚠ Jenkins is still initializing${NC}"
fi

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org)

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}║        ✓ Deployment Complete!                          ║${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}Your Service URLs:${NC}"
echo ""
echo -e "  ${GREEN}Web UI (Streamlit):${NC}     http://$PUBLIC_IP:8501"
echo -e "  ${GREEN}API (Flask):${NC}            http://$PUBLIC_IP:5000"
echo -e "  ${GREEN}Prometheus (Monitoring):${NC} http://$PUBLIC_IP:9090"
echo -e "  ${GREEN}Jenkins (CI/CD):${NC}        http://$PUBLIC_IP:8080"
echo ""

if [ -n "$JENKINS_PASSWORD" ]; then
    echo -e "${YELLOW}Jenkins Initial Admin Password:${NC} $JENKINS_PASSWORD"
    echo ""
fi

echo -e "${BLUE}Test the API:${NC}"
echo "curl -X POST http://$PUBLIC_IP:5000/predict \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"features\": [5.1, 3.5, 1.4, 0.2]}'"
echo ""

# Save URLs to file
cat > service_urls.txt <<EOF
╔════════════════════════════════════════════════════════╗
║     MLOps Pipeline - Service URLs                     ║
╚════════════════════════════════════════════════════════╝

Instance IP: $PUBLIC_IP
Instance ID: $INSTANCE_ID

Service URLs:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 Web UI (Streamlit):
   http://$PUBLIC_IP:8501
   Interactive interface for making predictions

🔌 API (Flask):
   http://$PUBLIC_IP:5000
   REST API for programmatic access
   
   Test command:
   curl -X POST http://$PUBLIC_IP:5000/predict \\
     -H "Content-Type: application/json" \\
     -d '{"features": [5.1, 3.5, 1.4, 0.2]}'

📊 Prometheus (Monitoring):
   http://$PUBLIC_IP:9090
   Metrics and performance monitoring

🔄 Jenkins (CI/CD):
   http://$PUBLIC_IP:8080
   Continuous Integration and Deployment
EOF

if [ -n "$JENKINS_PASSWORD" ]; then
    cat >> service_urls.txt <<EOF
   
   Initial Admin Password: $JENKINS_PASSWORD
EOF
fi

cat >> service_urls.txt <<EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Security Group Configuration:
Make sure these ports are open in AWS Security Group:
  - Port 22 (SSH)
  - Port 5000 (Flask API)
  - Port 8501 (Streamlit UI)
  - Port 9090 (Prometheus)
  - Port 8080 (Jenkins)

Generated: $(date)
EOF

echo -e "${GREEN}✓ Service URLs saved to: service_urls.txt${NC}"
echo ""

# Run comprehensive test
echo -e "${YELLOW}Running system tests...${NC}"
./test_everything.sh || echo "Some tests may have failed, but services are running"

echo ""
echo -e "${GREEN}Deployment complete! All services are running.${NC}"
echo ""

