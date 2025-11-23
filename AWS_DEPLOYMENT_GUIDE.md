# AWS Deployment Guide - Complete Setup

Yeh guide aapko AWS par complete MLOps pipeline deploy karne mein help karega with Jenkins integration.

## Prerequisites

- AWS Account with credentials
- AWS CLI installed (optional, script will install if needed)
- Terraform installed (optional, script will install if needed)

## AWS Credentials

Aapke credentials configure karein:
- **AWS_ACCESS_KEY_ID**: YOUR_AWS_ACCESS_KEY_ID
- **AWS_SECRET_ACCESS_KEY**: YOUR_AWS_SECRET_ACCESS_KEY
- **Region**: us-east-1

## Method 1: Direct EC2 Deployment (Recommended)

Agar aap already EC2 instance par hain:

```bash
# Script ko executable banao
chmod +x deploy_aws.sh

# Deployment run karo
./deploy_aws.sh
```

Yeh script automatically:
1. ✅ AWS credentials configure karega
2. ✅ Dependencies install karega
3. ✅ ML models train karega
4. ✅ Docker services start karega
5. ✅ Jenkins setup karega
6. ✅ Sab URLs provide karega

## Method 2: New EC2 Instance Create Karna

Agar aapko naya EC2 instance banana hai:

### Step 1: Terraform se Instance Create Karein

```bash
cd terraform

# Terraform initialize karo
terraform init

# Instance create karo
terraform apply -auto-approve
```

Yeh automatically:
- EC2 instance create karega (t3.medium, Amazon Linux 2)
- Security group banayega with all required ports
- User data script run karega jo automatically sab install karega

### Step 2: Instance Ready Hone Ka Wait Karein

Instance create hone ke baad, user data script automatically:
- Git clone karega
- Dependencies install karega
- Models train karega
- Services start karega

**Wait time**: 5-10 minutes

### Step 3: URLs Get Karein

```bash
# Terraform output se URLs get karo
terraform output

# Ya direct script run karo
cd ..
./get_all_urls.sh
```

## Method 3: Manual Setup (Step by Step)

Agar aap manually setup karna chahte hain:

### Step 1: EC2 Instance Launch Karein

1. AWS Console → EC2 → Launch Instance
2. **AMI**: Amazon Linux 2
3. **Instance Type**: t3.medium (minimum)
4. **Storage**: 20 GB minimum
5. **Security Group**: Ports open karein:
   - 22 (SSH)
   - 5000 (Flask API)
   - 8501 (Streamlit UI)
   - 9090 (Prometheus)
   - 8080 (Jenkins)

### Step 2: SSH into Instance

```bash
ssh -i your-key.pem ec2-user@YOUR-INSTANCE-IP
```

### Step 3: Repository Clone Karein

```bash
git clone https://github.com/JibbranAli/devops-project-7.git
cd devops-project-7
```

### Step 4: Installation Run Karein

```bash
# Scripts ko executable banao
chmod +x *.sh

# Installation run karo
sudo ./install.sh
```

### Step 5: Services Start Karein

```bash
# Models train karo (if not already done)
python3 app/train_model.py

# Services start karo
./run_demo.sh
```

### Step 6: URLs Get Karein

```bash
./get_all_urls.sh
```

## Service URLs

Deployment ke baad, aapko yeh URLs milenge:

### 🌐 Web UI (Streamlit)
```
http://YOUR-IP:8501
```
Interactive interface for making predictions

### 🔌 API (Flask)
```
http://YOUR-IP:5000
```
REST API endpoints:
- `GET /health` - Health check
- `GET /config` - Configuration
- `GET /metrics` - Prometheus metrics
- `POST /predict` - Make predictions

**Test API:**
```bash
curl -X POST http://YOUR-IP:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [5.1, 3.5, 1.4, 0.2]}'
```

### 📊 Prometheus (Monitoring)
```
http://YOUR-IP:9090
```
Metrics and performance monitoring dashboard

### 🔄 Jenkins (CI/CD)
```
http://YOUR-IP:8080
```
Continuous Integration and Deployment

**Initial Setup:**
1. Browser mein Jenkins URL open karein
2. Initial admin password get karein:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. Suggested plugins install karein
4. Admin user create karein
5. Pipeline setup karein:
   ```bash
   sudo ./setup_jenkins_pipeline.sh
   ```

## Jenkins Pipeline Setup

### Automatic Setup

```bash
sudo ./setup_jenkins_pipeline.sh
```

### Manual Setup

1. Jenkins mein login karein
2. **New Item** click karein
3. **Pipeline** select karein
4. **Pipeline script from SCM** select karein
5. **SCM**: Git
6. **Repository URL**: `https://github.com/JibbranAli/devops-project-7.git`
7. **Script Path**: `Jenkinsfile`
8. **Save** karein
9. **Build Now** click karein

## Testing Everything

Complete system test run karein:

```bash
./test_everything.sh
```

Yeh script:
- ✅ All services check karega
- ✅ API endpoints test karega
- ✅ A/B testing verify karega
- ✅ Monitoring check karega
- ✅ Jenkins status check karega
- ✅ Sab URLs provide karega

## Troubleshooting

### Services Start Nahi Ho Rahe

```bash
# Check Docker status
sudo systemctl status docker

# Check service logs
docker-compose logs

# Restart services
docker-compose down
docker-compose up -d
```

### Ports Already in Use

```bash
# Stop all services
docker-compose down

# Kill specific port
sudo lsof -ti:5000 | xargs kill -9
sudo lsof -ti:8501 | xargs kill -9
sudo lsof -ti:9090 | xargs kill -9
sudo lsof -ti:8080 | xargs kill -9
```

### Jenkins Access Nahi Ho Raha

1. Check if Jenkins running:
   ```bash
   sudo systemctl status jenkins
   ```

2. Check security group - port 8080 open hona chahiye

3. Check firewall:
   ```bash
   sudo firewall-cmd --list-all
   ```

### Models Not Found

```bash
# Train models
python3 app/train_model.py

# Restart API
docker-compose restart flask-api
```

### AWS Security Group Configuration

AWS Console mein:
1. EC2 → Security Groups
2. Aapke instance ka security group select karein
3. **Inbound Rules** mein add karein:
   - Type: Custom TCP, Port: 5000, Source: 0.0.0.0/0
   - Type: Custom TCP, Port: 8501, Source: 0.0.0.0/0
   - Type: Custom TCP, Port: 9090, Source: 0.0.0.0/0
   - Type: Custom TCP, Port: 8080, Source: 0.0.0.0/0

## Quick Commands Reference

```bash
# Start all services
./run_demo.sh

# Stop all services
docker-compose down

# View logs
docker-compose logs -f

# Restart a service
docker-compose restart flask-api

# Check service status
docker-compose ps

# Get all URLs
./get_all_urls.sh

# Run tests
./test_everything.sh

# Retrain models
python3 app/train_model.py

# Check for drift
python3 app/monitoring.py
```

## Service URLs File

Sab URLs automatically `service_urls.txt` file mein save ho jayenge.

## Next Steps

1. ✅ Services start karein
2. ✅ URLs test karein
3. ✅ Jenkins pipeline setup karein
4. ✅ Monitoring dashboard check karein
5. ✅ API test karein
6. ✅ Web UI use karein

## Support

Agar koi problem aaye:
1. `./test_everything.sh` run karein - yeh sab kuch check karega
2. `docker-compose logs` se logs check karein
3. Security group ports verify karein
4. Firewall rules check karein

---

**Happy Deploying! 🚀**

