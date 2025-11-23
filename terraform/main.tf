# Simple Terraform configuration for deploying on a single EC2 instance
# This is optional and minimal - the project works without it

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Security group for the MLOps instance
resource "aws_security_group" "mlops_sg" {
  name        = "mlops-pipeline-sg"
  description = "Security group for MLOps pipeline"
  
  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }
  
  # Flask API
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Flask API"
  }
  
  # Streamlit UI
  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Streamlit UI"
  }
  
  # Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Prometheus"
  }
  
  # Jenkins CI/CD
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins"
  }
  
  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "mlops-pipeline-sg"
  }
}

# EC2 instance for MLOps pipeline
resource "aws_instance" "mlops_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.mlops_sg.id]
  
  iam_instance_profile = "EC2-SSM-InstanceProfile"
  
  user_data = <<-EOF
              #!/bin/bash
              # Complete MLOps Pipeline Deployment Script with Jenkins Pipeline Auto-Setup
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              set -x
              
              # Update system
              yum update -y
              
              # Install all dependencies including Java for Jenkins
              yum install -y git python3 python3-pip python3-devel gcc docker wget java-11-amazon-corretto
              
              # Start and enable Docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user
              
              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
              
              # Install Jenkins
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              yum install -y jenkins
              systemctl start jenkins
              systemctl enable jenkins
              usermod -aG docker jenkins
              
              # Wait for Docker and Jenkins to be ready
              sleep 15
              
              # Clone repository
              cd /home/ec2-user
              git clone https://github.com/JibbranAli/devops-project-7.git 2>&1 || (cd devops-project-7 && git pull)
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
              
              # Install Python dependencies (with retries)
              pip3 install --user --upgrade pip || true
              pip3 install --user -r requirements.txt || pip3 install --user flask==2.3.3 scikit-learn==1.3.2 numpy==1.24.3 pandas==2.0.3 streamlit==1.28.0 prometheus-client==0.19.0 requests==2.31.0 pytest==7.4.3 joblib==1.3.2
              
              # Train models
              python3 app/train_model.py || echo "Model training failed, continuing..."
              
              # Start services with Docker
              cd /home/ec2-user/devops-project-7
              sudo docker-compose down 2>/dev/null || true
              sudo docker-compose build || (echo "Build failed, retrying..." && sleep 5 && sudo docker-compose build)
              sudo docker-compose up -d || echo "Start failed"
              
              # Wait for services
              sleep 20
              
              # Get public IP
              PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
              
              # Wait for Jenkins to be ready and setup pipeline automatically
              echo "Waiting for Jenkins to be ready..."
              for i in {1..60}; do
                  if curl -s http://localhost:8080/login > /dev/null 2>&1; then
                      echo "Jenkins is ready!"
                      break
                  fi
                  echo "Waiting for Jenkins... ($i/60)"
                  sleep 5
              done
              
              # Get Jenkins password
              JENKINS_PASSWORD=""
              if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
                  JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
                  echo "JENKINS_PASSWORD=$JENKINS_PASSWORD" > /home/ec2-user/jenkins_info.txt
                  chmod 644 /home/ec2-user/jenkins_info.txt
              fi
              
              # Setup Jenkins pipeline automatically (after initial setup is done)
              # This will be done via a background script that waits for Jenkins setup
              cat > /home/ec2-user/setup_jenkins_auto.sh <<'SETUP_EOF'
#!/bin/bash
# Auto-setup Jenkins pipeline script
sleep 120  # Wait for Jenkins initial setup to complete

# Wait for Jenkins to be fully ready
for i in {1..30}; do
    if curl -s http://localhost:8080/api/json > /dev/null 2>&1; then
        echo "Jenkins API is ready!"
        break
    fi
    sleep 10
done

# Create Jenkins pipeline job using API
cd /home/ec2-user/devops-project-7

# Create pipeline config
cat > /tmp/mlops-pipeline-config.xml <<'XML_EOF'
<?xml version='1.1' encoding='UTF-8'?>
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

# Try to create pipeline (may fail if Jenkins not fully setup, that's OK)
curl -s -X POST "http://localhost:8080/createItem?name=mlops-pipeline" \
    --user "admin:$(cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo '')" \
    --header "Content-Type: application/xml" \
    --data-binary @/tmp/mlops-pipeline-config.xml > /dev/null 2>&1 || echo "Pipeline will be created manually"

rm -f /tmp/mlops-pipeline-config.xml
SETUP_EOF

              chmod +x /home/ec2-user/setup_jenkins_auto.sh
              nohup /home/ec2-user/setup_jenkins_auto.sh > /var/log/jenkins-setup.log 2>&1 &
              
              # Check status
              sudo docker-compose ps >> /var/log/user-data.log 2>&1
              
              # Save final URLs
              cat > /home/ec2-user/final_urls.txt <<URL_EOF
╔════════════════════════════════════════════════════════╗
║           ✅ FINAL WORKING SERVICE URLs                ║
╚════════════════════════════════════════════════════════╝

🌐 Streamlit Dashboard URL:
   http://$PUBLIC_IP:8501

🔄 Jenkins Dashboard URL:
   http://$PUBLIC_IP:8080

📊 Prometheus Monitoring URL:
   http://$PUBLIC_IP:9090

🔌 Flask API URL:
   http://$PUBLIC_IP:5000

🔑 Jenkins Password:
   $JENKINS_PASSWORD

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Jenkins Pipeline Setup:
1. Open: http://$PUBLIC_IP:8080
2. Enter password: $JENKINS_PASSWORD
3. Install suggested plugins
4. Create admin user
5. Pipeline will auto-create or manually:
   - New Item > mlops-pipeline > Pipeline
   - Pipeline script from SCM > Git
   - Repository: https://github.com/JibbranAli/devops-project-7.git
   - Script Path: Jenkinsfile
   - Save > Build Now

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
URL_EOF
              
              chmod 644 /home/ec2-user/final_urls.txt
              
              # Log completion
              echo "Deployment complete at $(date)" >> /var/log/mlops-deployment.log
              echo "Final URLs saved to /home/ec2-user/final_urls.txt" >> /var/log/mlops-deployment.log
              EOF
  
  tags = {
    Name = "mlops-pipeline-instance"
  }
}

output "instance_public_ip" {
  description = "Public IP of the MLOps instance"
  value       = aws_instance.mlops_instance.public_ip
}

output "flask_api_url" {
  description = "Flask API URL"
  value       = "http://${aws_instance.mlops_instance.public_ip}:5000"
}

output "streamlit_url" {
  description = "Streamlit UI URL"
  value       = "http://${aws_instance.mlops_instance.public_ip}:8501"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${aws_instance.mlops_instance.public_ip}:9090"
}

output "jenkins_url" {
  description = "Jenkins CI/CD URL"
  value       = "http://${aws_instance.mlops_instance.public_ip}:8080"
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.mlops_instance.id
}
