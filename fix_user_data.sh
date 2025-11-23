#!/bin/bash
# Fixed user data script for Amazon Linux 2 with Python 3.7

cat > /tmp/fixed_user_data.txt <<'USERDATA_EOF'
#!/bin/bash
set -e

# Update system
yum update -y

# Install git and dependencies
yum install -y git python3 python3-pip python3-devel gcc

# Clone repository
cd /home/ec2-user
git clone https://github.com/JibbranAli/devops-project-7.git || (cd devops-project-7 && git pull)
cd devops-project-7

# Fix requirements.txt for Python 3.7
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

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install Python dependencies
pip3 install --user --upgrade pip
pip3 install --user -r requirements.txt

# Train models
python3 app/train_model.py

# Start services
cd /home/ec2-user/devops-project-7
docker-compose down 2>/dev/null || true
docker-compose build
docker-compose up -d

# Log completion
echo "Deployment complete at $(date)" >> /var/log/mlops-deployment.log
USERDATA_EOF

echo "Fixed user data script created at /tmp/fixed_user_data.txt"
echo ""
echo "To apply this fix, you need to:"
echo "1. Stop the instance"
echo "2. Modify instance attribute with new user data"
echo "3. Start the instance"
echo ""
echo "Or better: Create a new instance with this user data"

