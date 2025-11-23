#!/bin/bash
# Complete Setup and Run Script - Sab kuch automatically setup karega

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║     MLOps Pipeline - Complete Setup & Run             ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || echo "localhost")

echo "Instance IP: $PUBLIC_IP"
echo ""

# Step 1: Setup
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[1/7] Setting up environment..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd /home/ec2-user

# Clone repo if not exists
if [ ! -d "devops-project-7" ]; then
    echo "Cloning repository..."
    git clone https://github.com/JibbranAli/devops-project-7.git
    echo "✅ Repository cloned"
else
    echo "✅ Repository already exists"
fi

cd devops-project-7

# Fix requirements
echo ""
echo "Fixing requirements.txt for Python 3.7..."
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
echo "✅ Requirements fixed"

# Make scripts executable
chmod +x *.sh

# Step 2: Install dependencies
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[2/7] Installing dependencies..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

pip3 install --user --upgrade pip || true
pip3 install --user -r requirements.txt || pip3 install --user flask==2.3.3 scikit-learn==1.3.2 numpy==1.24.3 pandas==2.0.3 streamlit==1.28.0 prometheus-client==0.19.0 requests==2.31.0 pytest==7.4.3 joblib==1.3.2
echo "✅ Python dependencies installed"

# Step 3: Install Docker
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[3/7] Installing Docker..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v docker &> /dev/null; then
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    echo "✅ Docker installed and started"
else
    sudo systemctl start docker || true
    echo "✅ Docker already installed"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

sleep 5

# Step 4: Train models
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[4/7] Training ML models..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -f "app/models/model_v1.pkl" ] || [ ! -f "app/models/model_v2.pkl" ]; then
    python3 app/train_model.py
    echo "✅ Models trained"
else
    echo "✅ Models already exist"
fi

# Step 5: Start services
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[5/7] Building and starting Docker services..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

sudo docker-compose down 2>/dev/null || true
sudo docker-compose build || (echo "Retrying build..." && sleep 5 && sudo docker-compose build)
sudo docker-compose up -d
echo "✅ Services started"

# Wait for services
echo ""
echo "Waiting for services to initialize..."
sleep 20

# Step 6: Check status
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[6/7] Checking service status..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

sudo docker-compose ps

# Step 7: Get Jenkins password and print URLs
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[7/7] Getting Jenkins password and final URLs..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get Jenkins password
JENKINS_PASSWORD=""
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
fi

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || echo "localhost")

# Print final output
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║           ✅ SETUP COMPLETE!                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 SERVICE URLs:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Streamlit Dashboard URL:"
echo "   http://$PUBLIC_IP:8501"
echo ""
echo "🔄 Jenkins Dashboard URL:"
echo "   http://$PUBLIC_IP:8080"
echo ""
echo "📊 Prometheus Monitoring URL:"
echo "   http://$PUBLIC_IP:9090"
echo ""
echo "🔌 Flask API URL:"
echo "   http://$PUBLIC_IP:5000"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔑 JENKINS FIRST LOGIN:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -n "$JENKINS_PASSWORD" ]; then
    echo "Initial Admin Password:"
    echo "  $JENKINS_PASSWORD"
    echo ""
    echo "Steps:"
    echo "  1. Open: http://$PUBLIC_IP:8080"
    echo "  2. Enter password: $JENKINS_PASSWORD"
    echo "  3. Click 'Install Suggested Plugins'"
    echo "  4. Create admin user"
    echo "  5. Jenkins ready!"
else
    echo "⚠️  Jenkins password not available yet."
    echo "   Wait a few minutes and run:"
    echo "   sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 TEST COMMANDS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Test API Health"
echo "curl http://$PUBLIC_IP:5000/health"
echo ""
echo "# Make Prediction"
echo "curl -X POST http://$PUBLIC_IP:5000/predict \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"features\": [5.1, 3.5, 1.4, 0.2]}'"
echo ""
echo "# Run Tests"
echo "cd /home/ec2-user/devops-project-7"
echo "./test_everything.sh"
echo ""
echo "# Run Demo"
echo "./run_demo.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All services are running!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

