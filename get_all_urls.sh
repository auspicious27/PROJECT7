#!/bin/bash

# Script to get all working URLs for the MLOps Pipeline
# This script detects the public IP and displays all service URLs

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
echo "║        MLOps Pipeline - Service URLs                 ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to get public IP
get_public_ip() {
    local ip=""
    
    # Method 1: AWS metadata service (if on EC2)
    ip=$(curl -s --connect-timeout 2 --max-time 3 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "")
    
    if [ -n "$ip" ] && [ "$ip" != "127.0.0.1" ]; then
        echo "$ip"
        return
    fi
    
    # Method 2: External service
    ip=$(curl -s --connect-timeout 2 --max-time 3 https://api.ipify.org 2>/dev/null || echo "")
    
    if [ -n "$ip" ] && [ "$ip" != "127.0.0.1" ]; then
        echo "$ip"
        return
    fi
    
    # Method 3: Hostname
    ip=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "")
    
    if [ -n "$ip" ]; then
        echo "$ip"
        return
    fi
    
    echo "localhost"
}

# Get IP
PUBLIC_IP=$(get_public_ip)

# Get instance ID if on EC2
INSTANCE_ID=$(curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "N/A")

echo ""
echo -e "${GREEN}Detected IP Address:${NC} $PUBLIC_IP"
if [ "$INSTANCE_ID" != "N/A" ]; then
    echo -e "${GREEN}Instance ID:${NC} $INSTANCE_ID"
fi
echo ""

# Check if services are running
echo -e "${YELLOW}Checking service status...${NC}"
echo ""

# Check Docker services
if command -v docker-compose &> /dev/null; then
    if docker-compose ps 2>/dev/null | grep -q "Up"; then
        echo -e "${GREEN}✓ Docker services are running${NC}"
    else
        echo -e "${RED}✗ Docker services are not running${NC}"
        echo "  Run: ./run_demo.sh"
    fi
else
    echo -e "${YELLOW}⚠ Docker Compose not found${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}                    SERVICE URLs                        ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Service URLs
echo -e "${GREEN}🌐 Web UI (Streamlit):${NC}"
echo "   http://$PUBLIC_IP:8501"
echo "   Interactive interface for making predictions"
echo ""

echo -e "${GREEN}🔌 API (Flask):${NC}"
echo "   http://$PUBLIC_IP:5000"
echo "   REST API for programmatic access"
echo ""
echo "   Test command:"
echo "   curl -X POST http://$PUBLIC_IP:5000/predict \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d '{\"features\": [5.1, 3.5, 1.4, 0.2]}'"
echo ""

echo -e "${GREEN}📊 Prometheus (Monitoring):${NC}"
echo "   http://$PUBLIC_IP:9090"
echo "   Metrics and performance monitoring"
echo ""

echo -e "${GREEN}🔄 Jenkins (CI/CD):${NC}"
echo "   http://$PUBLIC_IP:8080"
echo "   Continuous Integration and Deployment"
echo ""

# Get Jenkins password if available
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "")
    if [ -n "$JENKINS_PASSWORD" ]; then
        echo -e "${YELLOW}   Initial Admin Password:${NC} $JENKINS_PASSWORD"
        echo ""
    fi
fi

# Test endpoints
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}                    SERVICE STATUS                       ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

test_endpoint() {
    local url=$1
    local name=$2
    
    response=$(curl -s -w "\n%{http_code}" --connect-timeout 3 --max-time 5 "$url" 2>/dev/null || echo -e "\n000")
    http_code=$(echo "$response" | tail -n 1)
    
    if [ "$http_code" == "200" ] || [ "$http_code" == "302" ]; then
        echo -e "${GREEN}✓${NC} $name - ${GREEN}Accessible${NC} (HTTP $http_code)"
    else
        echo -e "${RED}✗${NC} $name - ${RED}Not accessible${NC} (HTTP $http_code)"
    fi
}

test_endpoint "http://$PUBLIC_IP:5000/health" "Flask API"
test_endpoint "http://$PUBLIC_IP:8501" "Streamlit UI"
test_endpoint "http://$PUBLIC_IP:9090/-/healthy" "Prometheus"
test_endpoint "http://$PUBLIC_IP:8080/login" "Jenkins"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Save to file
cat > service_urls.txt <<EOF
╔════════════════════════════════════════════════════════╗
║     MLOps Pipeline - Service URLs                     ║
╚════════════════════════════════════════════════════════╝

Instance IP: $PUBLIC_IP
Instance ID: $INSTANCE_ID
Generated: $(date)

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

Quick Test:
  curl http://$PUBLIC_IP:5000/health
  curl -X POST http://$PUBLIC_IP:5000/predict \\
    -H "Content-Type: application/json" \\
    -d '{"features": [5.1, 3.5, 1.4, 0.2]}'
EOF

echo -e "${GREEN}✓ URLs saved to: service_urls.txt${NC}"
echo ""

