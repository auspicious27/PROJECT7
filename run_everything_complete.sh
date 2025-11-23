#!/bin/bash
# Complete Automated Setup - Sab kuch run karega aur final URLs print karega

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║     MLOps Pipeline - Complete Automated Setup        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || echo "localhost")

echo "Instance IP: $PUBLIC_IP"
echo ""

# Step 1: Setup Environment
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[1/8] Setting up environment..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd /home/ec2-user

if [ ! -d "devops-project-7" ]; then
    echo "Cloning repository..."
    git clone https://github.com/JibbranAli/devops-project-7.git
    echo "✅ Repository cloned"
else
    echo "✅ Repository exists, updating..."
    cd devops-project-7 && git pull && cd ..
fi

cd devops-project-7

# Fix requirements
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

chmod +x *.sh
echo "✅ Environment setup complete"

# Step 2: Install Python Dependencies
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[2/8] Installing Python dependencies..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

pip3 install --user --upgrade pip || true
pip3 install --user -r requirements.txt || pip3 install --user flask==2.3.3 scikit-learn==1.3.2 numpy==1.24.3 pandas==2.0.3 streamlit==1.28.0 prometheus-client==0.19.0 requests==2.31.0 pytest==7.4.3 joblib==1.3.2
echo "✅ Python dependencies installed"

# Step 3: Install Docker
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[3/8] Installing Docker..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v docker &> /dev/null; then
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    echo "✅ Docker installed"
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

# Step 4: Train Models
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[4/8] Training ML models..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ! -f "app/models/model_v1.pkl" ] || [ ! -f "app/models/model_v2.pkl" ]; then
    python3 app/train_model.py
    echo "✅ Models trained"
else
    echo "✅ Models already exist"
fi

# Step 5: Start Services
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[5/8] Building and starting Docker services..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

sudo docker-compose down 2>/dev/null || true
sudo docker-compose build || (echo "Retrying build..." && sleep 5 && sudo docker-compose build)
sudo docker-compose up -d
echo "✅ Services started"

sleep 20

# Step 6: Check Service Status
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[6/8] Checking service status..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

sudo docker-compose ps

# Step 7: Setup Jenkins Pipeline
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[7/8] Setting up Jenkins pipeline..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

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
    echo "✅ Jenkins is ready"
    # Jenkins pipeline will be set up manually via UI
else
    echo "⚠️ Jenkins is still initializing"
fi

# Step 8: Final Output - URLs and Info
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[8/8] Final Output - Service URLs..."
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
echo "📋 FINAL SERVICE URLs:"
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
echo "🔄 JENKINS PIPELINE SETUP:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "After Jenkins login, setup pipeline:"
echo ""
echo "1. Jenkins Dashboard > New Item"
echo "2. Name: mlops-pipeline"
echo "3. Type: Pipeline"
echo "4. Pipeline > Pipeline script from SCM"
echo "5. SCM: Git"
echo "6. Repository URL: https://github.com/JibbranAli/devops-project-7.git"
echo "7. Script Path: Jenkinsfile"
echo "8. Save > Build Now"
echo ""
echo "Or run setup script:"
echo "  sudo ./setup_jenkins_pipeline.sh"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 DEMO & TEST SCRIPTS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Run demo"
echo "./run_demo.sh"
echo ""
echo "# Run tests"
echo "./test_everything.sh"
echo ""
echo "# Test API"
echo "curl http://$PUBLIC_IP:5000/health"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ALL SERVICES RUNNING!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

