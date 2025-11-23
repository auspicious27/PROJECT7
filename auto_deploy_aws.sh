#!/bin/bash

# Automatic AWS Deployment Script
# Ye script automatically EC2 instance create karega aur sab deploy karega

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
echo "║     Automatic AWS Deployment - MLOps Pipeline       ║"
echo "║     EC2 Instance Create + Auto Deploy                 ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# AWS Credentials - Set your credentials here
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-YOUR_AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-YOUR_AWS_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

echo -e "${GREEN}✓ AWS Credentials configured${NC}"
echo ""

# Check/Install AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${YELLOW}Installing AWS CLI...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
        sudo installer -pkg AWSCLIV2.pkg -target /
        rm AWSCLIV2.pkg
    else
        # Linux
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
    fi
fi

# Configure AWS CLI
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile default
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile default
aws configure set default.region "$AWS_DEFAULT_REGION" --profile default

echo -e "${GREEN}✓ AWS CLI configured${NC}"
echo ""

# Get current directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create user data script
USER_DATA_SCRIPT=$(cat <<'EOF'
#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=========================================="
echo "Starting MLOps Pipeline Deployment"
echo "=========================================="

# Update system
yum update -y

# Install git
yum install -y git

# Clone repository
cd /home/ec2-user
git clone https://github.com/JibbranAli/devops-project-7.git
cd devops-project-7

# Make scripts executable
chmod +x *.sh

# Run installation
sudo ./install.sh

# Train models
python3 app/train_model.py

# Start services
./run_demo.sh

# Wait for services
sleep 10

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Create URLs file
cat > /home/ec2-user/service_urls.txt <<URLS
╔════════════════════════════════════════════════════════╗
║     MLOps Pipeline - Service URLs                     ║
╚════════════════════════════════════════════════════════╝

Instance IP: $PUBLIC_IP
Deployment Time: $(date)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 Web UI (Streamlit):
   http://$PUBLIC_IP:8501

🔌 API (Flask):
   http://$PUBLIC_IP:5000

📊 Prometheus (Monitoring):
   http://$PUBLIC_IP:9090

🔄 Jenkins (CI/CD):
   http://$PUBLIC_IP:8080

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Test API:
curl -X POST http://$PUBLIC_IP:5000/predict \\
  -H "Content-Type: application/json" \\
  -d '{"features": [5.1, 3.5, 1.4, 0.2]}'

URLS

echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo "Service URLs saved to: /home/ec2-user/service_urls.txt"
echo "Public IP: $PUBLIC_IP"
EOF
)

# Base64 encode user data
USER_DATA_ENCODED=$(echo "$USER_DATA_SCRIPT" | base64)

# Get latest Amazon Linux 2 AMI
echo -e "${YELLOW}[1/5] Getting latest Amazon Linux 2 AMI...${NC}"
AMI_ID=$(aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" "Name=state,Values=available" \
    --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
    --output text \
    --region us-east-1)

if [ -z "$AMI_ID" ] || [ "$AMI_ID" == "None" ]; then
    # Fallback to known AMI
    AMI_ID="ami-0c55b159cbfafe1f0"
    echo -e "${YELLOW}Using fallback AMI: $AMI_ID${NC}"
else
    echo -e "${GREEN}✓ Found AMI: $AMI_ID${NC}"
fi

# Create security group
echo ""
echo -e "${YELLOW}[2/5] Creating security group...${NC}"
SG_NAME="mlops-pipeline-sg-$(date +%s)"

SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "Security group for MLOps Pipeline" \
    --region us-east-1 \
    --query 'GroupId' \
    --output text 2>/dev/null || echo "")

if [ -z "$SG_ID" ]; then
    # Try to find existing security group
    SG_ID=$(aws ec2 describe-security-groups \
        --filters "Name=group-name,Values=$SG_NAME" \
        --query 'SecurityGroups[0].GroupId' \
        --output text \
        --region us-east-1 2>/dev/null || echo "")
    
    if [ -z "$SG_ID" ] || [ "$SG_ID" == "None" ]; then
        echo -e "${RED}✗ Failed to create security group${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ Using existing security group: $SG_ID${NC}"
    fi
else
    echo -e "${GREEN}✓ Security group created: $SG_ID${NC}"
fi

# Add security group rules
echo -e "${YELLOW}Adding security group rules...${NC}"

PORTS=(22 5000 8501 9090 8080)
for PORT in "${PORTS[@]}"; do
    aws ec2 authorize-security-group-ingress \
        --group-id "$SG_ID" \
        --protocol tcp \
        --port "$PORT" \
        --cidr 0.0.0.0/0 \
        --region us-east-1 2>/dev/null || echo "Port $PORT rule may already exist"
done

echo -e "${GREEN}✓ Security group rules added${NC}"

# Create EC2 instance
echo ""
echo -e "${YELLOW}[3/5] Creating EC2 instance...${NC}"

# Try different instance types
INSTANCE_TYPES=("t3.micro" "t2.micro" "t3.small")
INSTANCE_ID=""
INSTANCE_STATE=""

for INSTANCE_TYPE in "${INSTANCE_TYPES[@]}"; do
    echo -e "${YELLOW}  Trying instance type: $INSTANCE_TYPE...${NC}"
    INSTANCE_OUTPUT=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type "$INSTANCE_TYPE" \
        --security-group-ids "$SG_ID" \
        --user-data "$USER_DATA_ENCODED" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=mlops-pipeline-instance}]" \
        --region us-east-1 \
        --query 'Instances[0].[InstanceId,State.Name]' \
        --output text 2>&1)
    
    if [[ $INSTANCE_OUTPUT == *"InstanceId"* ]] || [[ $INSTANCE_OUTPUT =~ ^i- ]]; then
        INSTANCE_ID=$(echo "$INSTANCE_OUTPUT" | awk '{print $1}')
        INSTANCE_STATE=$(echo "$INSTANCE_OUTPUT" | awk '{print $2}')
        echo -e "${GREEN}  ✓ Successfully created with $INSTANCE_TYPE${NC}"
        break
    else
        echo -e "${YELLOW}  ✗ $INSTANCE_TYPE failed, trying next...${NC}"
    fi
done

INSTANCE_ID=$(echo "$INSTANCE_OUTPUT" | awk '{print $1}')
INSTANCE_STATE=$(echo "$INSTANCE_OUTPUT" | awk '{print $2}')

if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" == "None" ]; then
    echo -e "${RED}✗ Failed to create EC2 instance${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Instance created: $INSTANCE_ID${NC}"
echo -e "${GREEN}✓ Instance state: $INSTANCE_STATE${NC}"

# Wait for instance to be running
echo ""
echo -e "${YELLOW}[4/5] Waiting for instance to be running...${NC}"
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region us-east-1
echo -e "${GREEN}✓ Instance is running${NC}"

# Get public IP
echo ""
echo -e "${YELLOW}[5/5] Getting public IP address...${NC}"

# Wait a bit for public IP to be assigned
sleep 10

PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --region us-east-1 \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

# Retry if IP not available
if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" == "None" ]; then
    echo -e "${YELLOW}Waiting for public IP assignment...${NC}"
    for i in {1..10}; do
        sleep 5
        PUBLIC_IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --region us-east-1 \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
        
        if [ -n "$PUBLIC_IP" ] && [ "$PUBLIC_IP" != "None" ]; then
            break
        fi
    done
fi

if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" == "None" ]; then
    echo -e "${RED}✗ Could not get public IP${NC}"
    echo "Instance ID: $INSTANCE_ID"
    echo "Please check AWS Console for the IP address"
    exit 1
fi

echo -e "${GREEN}✓ Public IP: $PUBLIC_IP${NC}"

# Save deployment info
cat > deployment_info.txt <<EOF
╔════════════════════════════════════════════════════════╗
║     AWS Deployment Information                         ║
╚════════════════════════════════════════════════════════╝

Instance ID: $INSTANCE_ID
Public IP: $PUBLIC_IP
Security Group: $SG_ID
Region: us-east-1
AMI: $AMI_ID

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏳ Deployment Status: In Progress
   User data script is installing and deploying services.
   This will take approximately 5-10 minutes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 Service URLs (will be available after deployment):

   Web UI (Streamlit):     http://$PUBLIC_IP:8501
   API (Flask):            http://$PUBLIC_IP:5000
   Prometheus (Monitoring): http://$PUBLIC_IP:9090
   Jenkins (CI/CD):        http://$PUBLIC_IP:8080

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Next Steps:

1. Wait for deployment to complete (5-10 minutes)
2. Check deployment status:
   ssh -i your-key.pem ec2-user@$PUBLIC_IP "tail -f /var/log/user-data.log"

3. Once deployment is complete, test the services:
   curl http://$PUBLIC_IP:5000/health

4. Get Jenkins initial password:
   ssh -i your-key.pem ec2-user@$PUBLIC_IP "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Deployed: $(date)
EOF

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}║        ✓ EC2 Instance Created Successfully!           ║${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}Instance Information:${NC}"
echo "  Instance ID: $INSTANCE_ID"
echo "  Public IP: $PUBLIC_IP"
echo "  Security Group: $SG_ID"
echo ""

echo -e "${YELLOW}⏳ Deployment Status:${NC}"
echo "  User data script is running..."
echo "  This will take approximately 5-10 minutes"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}                    SERVICE URLs                        ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}🌐 Web UI (Streamlit):${NC}"
echo "   http://$PUBLIC_IP:8501"
echo ""
echo -e "${GREEN}🔌 API (Flask):${NC}"
echo "   http://$PUBLIC_IP:5000"
echo ""
echo -e "${GREEN}📊 Prometheus (Monitoring):${NC}"
echo "   http://$PUBLIC_IP:9090"
echo ""
echo -e "${GREEN}🔄 Jenkins (CI/CD):${NC}"
echo "   http://$PUBLIC_IP:8080"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Wait and check deployment status
echo -e "${YELLOW}Waiting for deployment to start (30 seconds)...${NC}"
sleep 30

# Try to check if services are coming up
echo ""
echo -e "${YELLOW}Checking deployment progress...${NC}"
echo "  (This may take a few minutes. Services will be available soon.)"
echo ""

# Create a script to check status
cat > check_deployment_status.sh <<'CHECKSCRIPT'
#!/bin/bash
INSTANCE_ID="$1"
PUBLIC_IP="$2"

echo "Checking deployment status..."
echo ""

# Check if instance is running
STATE=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --region us-east-1 \
    --query 'Reservations[0].Instances[0].State.Name' \
    --output text)

echo "Instance State: $STATE"
echo ""

# Try to check if API is responding
echo "Testing API endpoint..."
for i in {1..5}; do
    if curl -s --connect-timeout 5 "http://$PUBLIC_IP:5000/health" > /dev/null 2>&1; then
        echo "✓ API is responding!"
        break
    else
        echo "  Attempt $i/5: API not ready yet..."
        sleep 10
    fi
done

echo ""
echo "Deployment check complete."
CHECKSCRIPT

chmod +x check_deployment_status.sh

echo -e "${GREEN}✓ Deployment info saved to: deployment_info.txt${NC}"
echo ""
echo -e "${YELLOW}To check deployment status later, run:${NC}"
echo "  ./check_deployment_status.sh $INSTANCE_ID $PUBLIC_IP"
echo ""
echo -e "${GREEN}Deployment initiated! Services will be available in 5-10 minutes.${NC}"
echo ""

