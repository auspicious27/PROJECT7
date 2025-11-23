#!/bin/bash
# Manual script to fix and start all services onstance_ID="i-0238af5edd321923a"
PUBLIC_IP="3.235.173.84"

echo "=========================================="
echo "Fixing and Starting All Services"
echo "Instance: $INSTANCE_ID"
echo "IP: $PUBLIC_IP"
echo "=========================================="

# Commands to run on instance
cat > /tmp/fix_commands.sh <<'FIXEOF'
#!/bin/bash
set -e

cd /home/ec2-user

# Clone repo if not exists
if [ ! -d "devops-project-7" ]; then
    git clone https://github.com/JibbranAli/devops-project-7.git
fi

cd devops-project-7

# Fix requirements for Python 3.7
cat > requirements.txt <<'REQEOF'
flask==2.3.3
scikit-learn==1.3.2
numpy==1.24.3
pandas==2.0.3
streamlit==1.28.0
prometheus-client==0.19.0
requests==2.31.0
pytest==7.4.3
joblib==1.3.2
REQEOF

# Install dependencies
pip3 install --user --upgrade pip || true
pip3 install --user -r requirements.txt || true

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
fi

# Install Docker Compose if not installed
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

# Train models if not exists
if [ ! -f "app/models/model_v1.pkl" ]; then
    python3 app/train_model.py || echo "Model training failed"
fi

# Stop existing services
sudo docker-compose down 2>/dev/null || true

# Build and start services
sudo docker-compose build || echo "Build failed"
sudo docker-compose up -d || echo "Start failed"

# Wait a bit
sleep 10

# Check status
sudo docker-compose ps

# Get Jenkins password if available
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    echo "=========================================="
    echo "JENKINS PASSWORD:"
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    echo "=========================================="
fi

echo "Services started!"
FIXEOF

echo "Commands script created. Now uploading and executing..."

# Try to use EC2 Instance Connect
echo "Attempting to execute commands via EC2 Instance Connect..."

# Since we can't directly SSH, let's create user data that will run this
echo ""
echo "Since direct access is not available, please:"
echo ""
echo "1. Go to AWS Console > EC2 > Instances"
echo "2. Select instance: $INSTANCE_ID"
echo "3. Click 'Connect' > 'EC2 Instance Connect'"
echo "4. Run these commands:"
echo ""
cat /tmp/fix_commands.sh
echo ""

