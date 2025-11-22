#!/bin/bash

set -e

echo "=========================================="
echo "MLOps Pipeline Installation Script"
echo "Complete Setup with Jenkins CI/CD"
echo "For Amazon Linux / RHEL"
echo "=========================================="

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo: sudo ./install.sh"
    exit 1
fi

# Get the actual user (not root)
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    echo "Detected OS: $OS"
else
    echo "Cannot detect OS. Assuming RHEL-based system."
    OS="rhel"
fi

# Update system
echo ""
echo "[1/8] Updating system packages..."
if command -v yum &> /dev/null; then
    yum update -y
elif command -v dnf &> /dev/null; then
    dnf update -y
fi

# Install Python 3 and pip
echo ""
echo "[2/8] Installing Python 3 and pip..."
if command -v yum &> /dev/null; then
    yum install -y python3 python3-pip python3-devel gcc git wget || true
elif command -v dnf &> /dev/null; then
    dnf install -y python3 python3-pip python3-devel gcc git wget || true
fi

# Verify Python installation
python3 --version
pip3 --version

# Install Java (required for Jenkins)
echo ""
echo "[3/8] Installing Java (Jenkins requirement)..."
if command -v yum &> /dev/null; then
    # Try Java 17 first (Amazon Linux 2023), then fall back to Java 11
    yum install -y java-17-amazon-corretto java-17-amazon-corretto-devel || \
    yum install -y java-11-amazon-corretto java-11-amazon-corretto-devel || \
    yum install -y java-11-openjdk java-11-openjdk-devel || true
elif command -v dnf &> /dev/null; then
    dnf install -y java-17-amazon-corretto java-17-amazon-corretto-devel || \
    dnf install -y java-11-amazon-corretto java-11-amazon-corretto-devel || \
    dnf install -y java-11-openjdk java-11-openjdk-devel || true
fi

java -version 2>&1 || echo "Java installation may need manual intervention"

# Install Docker
echo ""
echo "[4/8] Installing Docker..."
if ! command -v docker &> /dev/null; then
    if command -v yum &> /dev/null; then
        yum install -y docker
    elif command -v dnf &> /dev/null; then
        dnf install -y docker
    fi
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    # Add users to docker group
    usermod -aG docker $ACTUAL_USER
    usermod -aG docker jenkins 2>/dev/null || true
    
    echo "Note: Docker group permissions will take effect after logout/login"
else
    echo "Docker already installed."
fi

docker --version

# Install Docker Compose
echo ""
echo "[5/8] Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Create symlink if needed
    if [ ! -f /usr/bin/docker-compose ]; then
        ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi
else
    echo "Docker Compose already installed."
fi

docker-compose --version

# Install Jenkins
echo ""
echo "[6/8] Installing Jenkins..."
if ! command -v jenkins &> /dev/null; then
    # Add Jenkins repository
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    
    # Install Jenkins
    if command -v yum &> /dev/null; then
        yum install -y jenkins
    elif command -v dnf &> /dev/null; then
        dnf install -y jenkins
    fi
    
    # Add jenkins user to docker group
    usermod -aG docker jenkins
    
    # Start Jenkins
    systemctl daemon-reload
    systemctl start jenkins
    systemctl enable jenkins
    
    echo "Jenkins installed and started."
else
    echo "Jenkins already installed."
    systemctl start jenkins || true
fi

# Install Python dependencies
echo ""
echo "[7/8] Installing Python dependencies..."
sudo -u $ACTUAL_USER pip3 install --user --upgrade pip
sudo -u $ACTUAL_USER pip3 install --user -r requirements.txt

# Train models
echo ""
echo "[8/8] Training ML models..."
sudo -u $ACTUAL_USER python3 app/train_model.py

# Wait for Jenkins to initialize
echo ""
echo "Waiting for Jenkins to initialize (30 seconds)..."
sleep 30

# Get public IP
PUBLIC_IP=$(curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')

# Get Jenkins initial password
JENKINS_PASSWORD=""
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    JENKINS_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
fi

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Your Public IP: $PUBLIC_IP"
echo ""
echo "Jenkins is running at:"
echo "  http://${PUBLIC_IP}:8080"
echo ""
if [ -n "$JENKINS_PASSWORD" ]; then
    echo "Jenkins Initial Admin Password:"
    echo "  $JENKINS_PASSWORD"
    echo ""
    echo "IMPORTANT: Copy this password!"
else
    echo "Jenkins is still initializing..."
    echo "Get password with: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
    echo ""
fi
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo ""
echo "1. Open Jenkins in your browser:"
echo "   http://${PUBLIC_IP}:8080"
echo ""
echo "2. Enter the initial admin password shown above"
echo ""
echo "3. Install suggested plugins (click the button)"
echo ""
echo "4. Create admin user or skip"
echo ""
echo "5. Run the pipeline setup script:"
echo "   sudo ./setup_jenkins_pipeline.sh"
echo ""
echo "Note: Make sure port 8080 is open in your Security Group (AWS)"
echo ""
echo "=========================================="

# Save info for next script
cat > /tmp/mlops_install_info.txt <<EOF
PUBLIC_IP=$PUBLIC_IP
JENKINS_PASSWORD=$JENKINS_PASSWORD
ACTUAL_USER=$ACTUAL_USER
EOF

chmod 644 /tmp/mlops_install_info.txt
