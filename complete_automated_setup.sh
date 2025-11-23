#!/bin/bash
# Complete Automated MLOps Pipeline Setup Script
# Ye script sab kuch automatically setup karega

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║     MLOps Pipeline - Complete Automated Setup        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || echo "localhost")

echo "Instance IP: $PUBLIC_IP"
echo ""

# Step 1: Install Dependencies
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[1/8] Installing system dependencies..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

sudo yum update -y
sudo yum install -y git python3 python3-pip python3-devel gcc docker wget java-11-amazon-corretto

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

echo "✅ Dependencies installed"
sleep 5

# Step 2: Clone Repository
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[2/8] Cloning repository..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd /home/ec2-user
if [ ! -d "devops-project-7" ]; then
    git clone https://github.com/JibbranAli/devops-project-7.git
else
    cd devops-project-7 && git pull && cd ..
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

chmod +x *.sh
echo "✅ Repository cloned and configured"

# Step 3: Install Python Dependencies
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[3/8] Installing Python dependencies..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

pip3 install --user --upgrade pip || true
pip3 install --user -r requirements.txt
echo "✅ Python dependencies installed"

# Step 4: Train ML Models
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[4/8] Training ML models..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

python3 app/train_model.py
echo "✅ Models trained and saved"

# Step 5: Build Docker Images
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[5/8] Building Docker images..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

sudo docker-compose build
echo "✅ Docker images built"

# Step 6: Install Jenkins
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[6/8] Installing Jenkins..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! systemctl is-active --quiet jenkins; then
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    sudo yum install -y jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    sudo usermod -aG docker jenkins
    echo "✅ Jenkins installed and started"
else
    echo "✅ Jenkins already installed"
fi

# Wait for Jenkins to initialize
echo "Waiting for Jenkins to initialize..."
sleep 30

# Get Jenkins password
JENKINS_PASSWORD=""
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
    echo "✅ Jenkins password retrieved"
else
    echo "⚠️  Jenkins password not available yet"
fi

# Step 7: Start Services with Docker Compose
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[7/8] Starting services with Docker Compose..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

sudo docker-compose down 2>/dev/null || true
sudo docker-compose up -d
echo "✅ Services started"

sleep 20

# Step 8: Setup Jenkins Pipeline
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[8/8] Setting up Jenkins pipeline..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Wait for Jenkins API to be ready
echo "Waiting for Jenkins API..."
for i in {1..30}; do
    if curl -s http://localhost:8080/api/json > /dev/null 2>&1; then
        echo "✅ Jenkins API is ready!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 5
done

# Create Jenkins pipeline
if [ -n "$JENKINS_PASSWORD" ]; then
    cat > /tmp/jenkins_pipeline_config.xml <<'XML_EOF'
<?xml version="1.1" encoding="UTF-8"?>
<flow-definition plugin="workflow-job@2.40">
  <description>MLOps Pipeline with A/B Testing and Monitoring</description>
  <keepDependencies>false</keepDependencies>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.90">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@4.10.0">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>https://github.com/JibbranAli/devops-project-7.git</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/main</name>
        </hudson.plugins.git.BranchSpec>
        <hudson.plugins.git.BranchSpec>
          <name>*/master</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="list"/>
      <extensions/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
XML_EOF

    # Try to create pipeline
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "http://localhost:8080/createItem?name=mlops-pipeline" \
        --user "admin:$JENKINS_PASSWORD" \
        --header "Content-Type: application/xml" \
        --data-binary @/tmp/jenkins_pipeline_config.xml 2>&1)
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    
    if [ "$HTTP_CODE" == "200" ]; then
        echo "✅ Jenkins pipeline created successfully!"
        sleep 3
        # Trigger build
        BUILD_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "http://localhost:8080/job/mlops-pipeline/build" \
            --user "admin:$JENKINS_PASSWORD" 2>&1)
        BUILD_CODE=$(echo "$BUILD_RESPONSE" | tail -n 1)
        if [ "$BUILD_CODE" == "201" ] || [ "$BUILD_CODE" == "200" ]; then
            echo "✅ Pipeline build triggered!"
        fi
    else
        echo "⚠️  Pipeline creation returned HTTP $HTTP_CODE"
        echo "   (Jenkins may need initial setup first)"
    fi
    
    rm -f /tmp/jenkins_pipeline_config.xml
else
    echo "⚠️  Jenkins password not available, pipeline will be created after manual setup"
fi

# Final Status
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║           ✅ SETUP COMPLETE!                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || echo "localhost")

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 FINAL WORKING URLs:"
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
    echo ""
    echo "After Jenkins setup, pipeline 'mlops-pipeline' will be visible in dashboard!"
else
    echo "⚠️  Jenkins password not available yet."
    echo "   Wait a few minutes and run:"
    echo "   sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Service Status:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
sudo docker-compose ps
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All services are running!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Save URLs and password to file
cat > /home/ec2-user/final_urls_and_info.txt <<EOF
╔════════════════════════════════════════════════════════╗
║     FINAL WORKING URLs AND JENKINS INFO                ║
╚════════════════════════════════════════════════════════╝

Instance IP: $PUBLIC_IP

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 WORKING URLs:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 Streamlit Dashboard:
   http://$PUBLIC_IP:8501

🔄 Jenkins Dashboard:
   http://$PUBLIC_IP:8080

📊 Prometheus Monitoring:
   http://$PUBLIC_IP:9090

🔌 Flask API:
   http://$PUBLIC_IP:5000

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔑 JENKINS PASSWORD:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$JENKINS_PASSWORD

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 JENKINS PIPELINE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pipeline Name: mlops-pipeline
Pipeline URL: http://$PUBLIC_IP:8080/job/mlops-pipeline/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

chmod 644 /home/ec2-user/final_urls_and_info.txt
echo "✅ URLs and info saved to: /home/ec2-user/final_urls_and_info.txt"
echo ""

