#!/bin/bash
# Script to fix and deploy services on EC2 instance

INSTANCE_ID="i-074d12f5f2ca17926"
PUBLIC_IP="18.207.136.165"

echo "Fixing and deploying services on instance $INSTANCE_ID..."

# Create a script that will be run on the instance
cat > /tmp/deploy_commands.sh <<'DEPLOY_EOF'
#!/bin/bash
set -e

cd /home/ec2-user

# Clone repository if not exists
if [ ! -d "devops-project-7" ]; then
    git clone https://github.com/JibbranAli/devops-project-7.git
fi

cd devops-project-7

# Fix requirements.txt for Python 3.7 compatibility
cat > requirements.txt <<'REQ_EOF'
flask==2.3.3
scikit-learn==1.3.2
numpy==1.24.3
pandas==2.0.3
streamlit==1.28.0
prometheus-client==0.19.0
requests==2.31.0
pytest==7.4.3
joblib==1.3.2
REQ_EOF

# Make scripts executable
chmod +x *.sh

# Install dependencies if not installed
if ! command -v docker &> /dev/null; then
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
fi

if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

# Install Python dependencies
pip3 install --user --upgrade pip
pip3 install --user -r requirements.txt

# Train models if not exists
if [ ! -f "app/models/model_v1.pkl" ]; then
    python3 app/train_model.py
fi

# Start services
sudo docker-compose down 2>/dev/null || true
sudo docker-compose build
sudo docker-compose up -d

# Wait for services
sleep 10

# Check services
sudo docker-compose ps

echo "Deployment complete!"
DEPLOY_EOF

# The script is ready, but we need to run it on the instance
# Since we don't have SSH key, we'll use AWS Systems Manager
# But first, let's check if SSM agent is installed

echo "Attempting to run commands via AWS Systems Manager..."

# Try to install SSM agent and run commands
aws ec2-instance-connect send-ssh-public-key \
    --instance-id $INSTANCE_ID \
    --availability-zone us-east-1a \
    --instance-os-user ec2-user \
    --ssh-public-key file://~/.ssh/id_rsa.pub 2>/dev/null || echo "SSH key method not available"

# Alternative: Use user data to run the script
echo "Creating user data script to fix and deploy..."

cat > /tmp/user_data_fix.sh <<'USERDATA_EOF'
#!/bin/bash
cd /home/ec2-user
git clone https://github.com/JibbranAli/devops-project-7.git || cd devops-project-7 && git pull
cd devops-project-7

# Fix requirements
cat > requirements.txt <<'REQ_EOF'
flask==2.3.3
scikit-learn==1.3.2
numpy==1.24.3
pandas==2.0.3
streamlit==1.28.0
prometheus-client==0.19.0
requests==2.31.0
pytest==7.4.3
joblib==1.3.2
REQ_EOF

chmod +x *.sh
pip3 install --user --upgrade pip
pip3 install --user -r requirements.txt
python3 app/train_model.py

# Install Docker if needed
sudo yum install -y docker || true
sudo systemctl start docker || true
sudo systemctl enable docker || true
sudo usermod -aG docker ec2-user || true

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || true
sudo chmod +x /usr/local/bin/docker-compose || true
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose || true

# Start services
cd /home/ec2-user/devops-project-7
sudo docker-compose down 2>/dev/null || true
sudo docker-compose build
sudo docker-compose up -d

echo "Services started!" > /tmp/deployment_status.txt
USERDATA_EOF

echo "User data script created. You need to run this on the instance."
echo "Since we don't have SSH access, please:"
echo "1. Create an EC2 key pair in AWS Console"
echo "2. Attach it to the instance"
echo "3. Or use AWS Systems Manager Session Manager"
echo ""
echo "Or run these commands manually via AWS Console > EC2 > Connect > Session Manager"

