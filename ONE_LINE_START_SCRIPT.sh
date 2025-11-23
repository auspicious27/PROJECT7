cd /home/ec2-user && git clone https://github.com/JibbranAli/devops-project-7.git 2>/dev/null || (cd devops-project-7 && git pull) && cd devops-project-7 && cat > requirements.txt <<'REQEOF'
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
pip3 install --user --upgrade pip && pip3 install --user -r requirements.txt && sudo yum install -y docker && sudo systemctl start docker && sudo systemctl enable docker && sudo usermod -aG docker ec2-user && sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose && sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose && sleep 5 && python3 app/train_model.py && sudo docker-compose down 2>/dev/null || true && sudo docker-compose build && sudo docker-compose up -d && sleep 20 && sudo docker-compose ps && echo "==========================================" && echo "JENKINS PASSWORD:" && sudo cat /var/lib/jenkins/secrets/initialAdminPassword && echo "==========================================" && PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) && echo "" && echo "✅ ALL SERVICES STARTED!" && echo "" && echo "Service URLs:" && echo "  Web UI:     http://$PUBLIC_IP:8501" && echo "  API:        http://$PUBLIC_IP:5000" && echo "  Prometheus: http://$PUBLIC_IP:9090" && echo "  Jenkins:    http://$PUBLIC_IP:8080" && echo "" && echo "Test API:" && echo "  curl http://$PUBLIC_IP:5000/health"

