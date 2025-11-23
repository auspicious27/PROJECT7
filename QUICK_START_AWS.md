# 🚀 Quick Start - AWS Deployment

## Sab Kuch Ready Hai! 

Aapke AWS credentials configure ho chuke hain aur sab scripts ready hain.

## ⚡ Fastest Way (3 Steps)

### Step 1: EC2 Instance Par SSH Karein
```bash
ssh -i your-key.pem ec2-user@YOUR-INSTANCE-IP
```

### Step 2: Repository Clone Karein
```bash
git clone https://github.com/JibbranAli/devops-project-7.git
cd devops-project-7
```

### Step 3: Deploy Karein
```bash
chmod +x *.sh
./deploy_aws.sh
```

**Bas! 5-10 minutes mein sab ready ho jayega!**

## 📋 Kya Kya Setup Hoga?

1. ✅ **Python 3** - ML models ke liye
2. ✅ **Docker & Docker Compose** - Containerization
3. ✅ **Jenkins** - CI/CD pipeline
4. ✅ **ML Models** - Auto train honge
5. ✅ **Flask API** - Port 5000
6. ✅ **Streamlit UI** - Port 8501
7. ✅ **Prometheus** - Port 9090 (Monitoring)
8. ✅ **Jenkins** - Port 8080 (CI/CD)

## 🌐 Service URLs

Deployment ke baad, yeh URLs milenge:

```
🌐 Web UI:     http://YOUR-IP:8501
🔌 API:        http://YOUR-IP:5000
📊 Prometheus: http://YOUR-IP:9090
🔄 Jenkins:     http://YOUR-IP:8080
```

**Sab URLs get karne ke liye:**
```bash
./get_all_urls.sh
```

## 🔧 Jenkins Setup

### Step 1: Jenkins Open Karein
Browser mein: `http://YOUR-IP:8080`

### Step 2: Initial Password Get Karein
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Step 3: Setup Complete Karein
1. Password enter karein
2. "Install suggested plugins" click karein
3. Admin user create karein (ya skip karein)
4. Save & Finish

### Step 4: Pipeline Setup
```bash
sudo ./setup_jenkins_pipeline.sh
```

## ✅ Testing

Sab kuch test karne ke liye:
```bash
./test_everything.sh
```

Yeh automatically:
- ✅ Sab services check karega
- ✅ API test karega
- ✅ URLs provide karega
- ✅ Status report dega

## 🔍 Common Commands

```bash
# Services start
./run_demo.sh

# Services stop
docker-compose down

# Logs dekhne ke liye
docker-compose logs -f

# Service status
docker-compose ps

# URLs get karne ke liye
./get_all_urls.sh
```

## 🛠️ Troubleshooting

### Services Start Nahi Ho Rahe?
```bash
docker-compose down
docker-compose up -d
```

### Ports Already in Use?
```bash
docker-compose down
sudo lsof -ti:5000 | xargs kill -9
sudo lsof -ti:8501 | xargs kill -9
sudo lsof -ti:9090 | xargs kill -9
sudo lsof -ti:8080 | xargs kill -9
```

### AWS Security Group
AWS Console mein ports open karein:
- 5000 (Flask API)
- 8501 (Streamlit UI)
- 9090 (Prometheus)
- 8080 (Jenkins)

## 📝 Important Files

- `deploy_aws.sh` - Main deployment script
- `get_all_urls.sh` - All URLs get karne ke liye
- `test_everything.sh` - Complete system test
- `service_urls.txt` - Saved URLs (auto-generated)

## 🎯 Next Steps

1. ✅ `./deploy_aws.sh` run karein
2. ✅ Wait karein (5-10 minutes)
3. ✅ `./get_all_urls.sh` run karein
4. ✅ URLs browser mein open karein
5. ✅ Jenkins setup complete karein
6. ✅ Test karein!

---

**Sab kuch ready hai! Bas `./deploy_aws.sh` run karein! 🚀**

