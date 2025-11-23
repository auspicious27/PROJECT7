#!/bin/bash
# Complete script to start all services on EC2 instance

set -e

cd /home/ec2-user

# Clone repo if not exists
if [ ! -d "devops-project-7" ]; then
    echo "Cloning repository..."
    git clone https://github.com/JibbranAli/devops-project-7.git
fi

cd devops-project-7

# Fix requirements for Python 3.7
echo "Fixing requirements.txt..."
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

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install --user --upgrade pip || true
pip3 install --user -r requirements.txt || pip3 install --user flask==2.3.3 scikit-learn==1.3.2 numpy==1.24.3 pandas==2.0.3 streamlit==1.28.0 prometheus-client==0.19.0 requests==2.31.0 pytest==7.4.3 joblib==1.3.2

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
fi

# Install Docker Compose if not installed
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

# Wait for Docker
sleep 5

# Train models if not exists
if [ ! -f "app/models/model_v1.pkl" ]; then
    echo "Training models..."
    python3 app/train_model.py || echo "Model training failed, continuing..."
fi

# Stop existing services
echo "Stopping existing services..."
sudo docker-compose down 2>/dev/null || true

# Build services
echo "Building Docker images..."
sudo docker-compose build || echo "Build failed, retrying..." && sleep 5 && sudo docker-compose build

# Start services
echo "Starting services..."
sudo docker-compose up -d

# Wait for services
echo "Waiting for services to start..."
sleep 15

# Check status
echo "=========================================="
echo "Service Status:"
sudo docker-compose ps

# Get Jenkins password
echo "=========================================="
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    echo "JENKINS PASSWORD:"
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    echo "=========================================="
fi

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo ""
echo "=========================================="
echo "✅ ALL SERVICES STARTED!"
echo "=========================================="
echo ""
echo "Service URLs:"
echo "  Web UI:     http://$PUBLIC_IP:8501"
echo "  API:        http://$PUBLIC_IP:5000"
echo "  Prometheus: http://$PUBLIC_IP:9090"
echo "  Jenkins:    http://$PUBLIC_IP:8080"
echo ""
echo "Test API:"
echo "  curl http://$PUBLIC_IP:5000/health"
echo ""

