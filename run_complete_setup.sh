#!/bin/bash
# Complete automated setup script - Copy this to EC2 Instance Connect terminal

set -e

echo "=========================================="
echo "Starting Complete MLOps Setup"
echo "=========================================="

cd /home/ec2-user

# Step 1: Clone repository
echo ""
echo "[1/8] Cloning repository..."
if [ ! -d "devops-project-7" ]; then
    git clone https://github.com/JibbranAli/devops-project-7.git
    echo "✅ Repository cloned"
else
    cd devops-project-7
    git pull
    echo "✅ Repository updated"
fi

cd devops-project-7

# Step 2: Fix requirements
echo ""
echo "[2/8] Fixing requirements.txt..."
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

# Step 3: Install Python dependencies
echo ""
echo "[3/8] Installing Python dependencies..."
pip3 install --user --upgrade pip || true
pip3 install --user -r requirements.txt || pip3 install --user flask==2.3.3 scikit-learn==1.3.2 numpy==1.24.3 pandas==2.0.3 streamlit==1.28.0 prometheus-client==0.19.0 requests==2.31.0 pytest==7.4.3 joblib==1.3.2
echo "✅ Python dependencies installed"

# Step 4: Install Docker
echo ""
echo "[4/8] Installing Docker..."
if ! command -v docker &> /dev/null; then
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
fi

# Step 5: Install Docker Compose
echo ""
echo "[5/8] Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

# Wait for Docker
sleep 5

# Step 6: Train models
echo ""
echo "[6/8] Training ML models..."
if [ ! -f "app/models/model_v1.pkl" ]; then
    python3 app/train_model.py || echo "⚠️ Model training had issues, continuing..."
    echo "✅ Models trained"
else
    echo "✅ Models already exist"
fi

# Step 7: Build and start services
echo ""
echo "[7/8] Building and starting Docker services..."
sudo docker-compose down 2>/dev/null || true
sudo docker-compose build || (echo "Retrying build..." && sleep 5 && sudo docker-compose build)
sudo docker-compose up -d
echo "✅ Services started"

# Wait for services
echo ""
echo "Waiting for services to initialize..."
sleep 15

# Step 8: Check status and get info
echo ""
echo "[8/8] Checking service status..."
sudo docker-compose ps

# Get Jenkins password
echo ""
echo "=========================================="
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    echo "🔑 JENKINS PASSWORD:"
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    echo "=========================================="
else
    echo "⚠️ Jenkins password file not found yet"
    echo "Wait a few minutes and run:"
    echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
    echo "=========================================="
fi

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo ""
echo "=========================================="
echo "✅ SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "📋 SERVICE URLs:"
echo ""
echo "  🌐 Web UI (Streamlit):"
echo "     http://$PUBLIC_IP:8501"
echo ""
echo "  🔌 API (Flask):"
echo "     http://$PUBLIC_IP:5000"
echo ""
echo "  📊 Prometheus (Monitoring):"
echo "     http://$PUBLIC_IP:9090"
echo ""
echo "  🔄 Jenkins (CI/CD):"
echo "     http://$PUBLIC_IP:8080"
echo ""
echo "=========================================="
echo ""
echo "🧪 TEST COMMANDS:"
echo ""
echo "  # Health check"
echo "  curl http://$PUBLIC_IP:5000/health"
echo ""
echo "  # Make prediction"
echo "  curl -X POST http://$PUBLIC_IP:5000/predict \\"
echo "    -H \"Content-Type: application/json\" \\"
echo "    -d '{\"features\": [5.1, 3.5, 1.4, 0.2]}'"
echo ""
echo "=========================================="

