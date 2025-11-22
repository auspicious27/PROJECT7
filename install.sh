#!/bin/bash

set -e

echo "=========================================="
echo "MLOps Pipeline Installation Script"
echo "For Amazon Linux / RHEL"
echo "=========================================="

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
echo "[1/6] Updating system packages..."
if command -v yum &> /dev/null; then
    sudo yum update -y
elif command -v dnf &> /dev/null; then
    sudo dnf update -y
fi

# Install Python 3 and pip
echo ""
echo "[2/6] Installing Python 3 and pip..."
if command -v yum &> /dev/null; then
    sudo yum install -y python3 python3-pip python3-devel gcc
elif command -v dnf &> /dev/null; then
    sudo dnf install -y python3 python3-pip python3-devel gcc
fi

# Verify Python installation
python3 --version
pip3 --version

# Install Docker
echo ""
echo "[3/6] Installing Docker..."
if ! command -v docker &> /dev/null; then
    if command -v yum &> /dev/null; then
        sudo yum install -y docker
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y docker
    fi
    
    # Start and enable Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    echo "Note: You may need to log out and back in for Docker group permissions to take effect."
else
    echo "Docker already installed."
fi

docker --version

# Install Docker Compose
echo ""
echo "[4/6] Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Create symlink if needed
    if [ ! -f /usr/bin/docker-compose ]; then
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi
else
    echo "Docker Compose already installed."
fi

docker-compose --version

# Install Git (if not present)
echo ""
echo "[5/6] Checking Git installation..."
if ! command -v git &> /dev/null; then
    if command -v yum &> /dev/null; then
        sudo yum install -y git
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y git
    fi
fi

git --version

# Install Python dependencies
echo ""
echo "[6/6] Installing Python dependencies..."
pip3 install --user --upgrade pip
pip3 install --user -r requirements.txt

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. If this is your first time installing Docker, log out and back in"
echo "2. Run: ./run_demo.sh"
echo ""
