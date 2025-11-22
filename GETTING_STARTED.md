# Getting Started with MLOps Pipeline

Welcome! This guide will help you get the MLOps pipeline up and running quickly.

## What You'll Get

A complete machine learning deployment pipeline with:
- 🤖 Two ML models with A/B testing
- 🌐 REST API for predictions
- 🎨 Interactive web UI
- 📊 Prometheus monitoring
- 🐳 Docker containerization
- 🔄 Jenkins CI/CD pipeline

## Prerequisites

You need:
- Amazon Linux or RHEL system
- Root/sudo access
- 2+ GB RAM
- 10+ GB disk space
- Internet connection

## Installation (5 minutes)

### Step 1: Download the Project

```bash
# If you have git
git clone <your-repo-url>
cd mlops-pipeline

# Or extract from zip
unzip mlops-pipeline.zip
cd mlops-pipeline
```

### Step 2: Make Scripts Executable

```bash
chmod +x *.sh
```

### Step 3: Install Dependencies

```bash
./install.sh
```

This installs:
- Python 3 and pip
- Docker and Docker Compose
- All Python packages
- System dependencies

**Important**: If this is your first Docker installation, log out and back in after running the script.

### Step 4: Verify Installation

```bash
./verify_setup.sh
```

This checks that everything is installed correctly.

## Running the Demo (2 minutes)

### Start All Services

```bash
./run_demo.sh
```

This will:
1. Train the ML models (first run only)
2. Build Docker containers
3. Start all services

### Access the Services

Open your browser:

| Service | URL | Description |
|---------|-----|-------------|
| Streamlit UI | http://localhost:8501 | Interactive interface |
| Flask API | http://localhost:5000 | REST API |
| Prometheus | http://localhost:9090 | Metrics dashboard |

## Using the Pipeline

### Option 1: Web UI (Easiest)

1. Open http://localhost:8501
2. Adjust the sliders for flower measurements
3. Click "Get Prediction"
4. See the predicted flower type and model version

### Option 2: API (For Developers)

```bash
# Make a prediction
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [5.1, 3.5, 1.4, 0.2]}'

# Response:
# {
#   "prediction": 0,
#   "model_version": "v1",
#   "timestamp": "2025-11-22T10:30:45",
#   "latency_ms": 12.34
# }
```

### Option 3: Python Script

```bash
python3 example_usage.py
```

This runs comprehensive examples showing all features.

### Option 4: Test Script

```bash
./test_api.sh
```

This tests all API endpoints and performs a load test.

## Understanding the Results

### Predictions

The model predicts one of three Iris flower types:
- **0 = Setosa** (small flowers)
- **1 = Versicolor** (medium flowers)
- **2 = Virginica** (large flowers)

### Model Versions

- **v1**: Random Forest with 50 trees (baseline)
- **v2**: Random Forest with 100 trees (improved)

The A/B testing randomly routes 50% of requests to each model.

### Metrics

View metrics at http://localhost:9090 and query:
- `prediction_requests_total` - Total predictions
- `model_version_requests_total` - Per-model counts
- `prediction_latency_seconds` - Response times

## Common Tasks

### View Logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs flask-api

# Follow logs in real-time
docker-compose logs -f
```

### Check Service Status

```bash
docker-compose ps
```

### Restart Services

```bash
docker-compose restart
```

### Stop Services

```bash
docker-compose down
```

### Retrain Models

```bash
python3 app/train_model.py
docker-compose restart flask-api
```

### Run Tests

```bash
python3 -m pytest tests/ -v
```

### Check for Model Drift

```bash
python3 app/monitoring.py
```

## Changing A/B Split

Edit `docker-compose.yml`:

```yaml
services:
  flask-api:
    environment:
      - MODEL_V1_WEIGHT=70  # 70% to v1
      - MODEL_V2_WEIGHT=30  # 30% to v2
```

Then restart:

```bash
docker-compose down
docker-compose up -d
```

## Using the Makefile (Optional)

If you have `make` installed:

```bash
make help          # Show all commands
make install       # Install dependencies
make train         # Train models
make up            # Start services
make down          # Stop services
make logs          # View logs
make test          # Run tests
make drift         # Check drift
```

## Troubleshooting

### Problem: Port Already in Use

```bash
# Stop services
docker-compose down

# Or kill specific port
sudo lsof -ti:5000 | xargs kill -9
```

### Problem: Docker Permission Denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in
```

### Problem: Models Not Found

```bash
# Train models
python3 app/train_model.py
```

### Problem: Services Won't Start

```bash
# Check logs
docker-compose logs

# Rebuild containers
docker-compose build --no-cache
docker-compose up -d
```

### Problem: Cannot Connect to API

```bash
# Check if services are running
docker-compose ps

# Check if ports are open
netstat -tuln | grep -E '5000|8501|9090'

# Restart services
docker-compose restart
```

## Next Steps

### Learn More

- Read [README.md](README.md) for full documentation
- Check [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- Review [QUICKSTART.md](QUICKSTART.md) for quick reference

### Explore the Code

- `app/flask_app.py` - API implementation
- `app/streamlit_app.py` - UI implementation
- `app/train_model.py` - Model training
- `app/monitoring.py` - Drift detection
- `Jenkinsfile` - CI/CD pipeline

### Customize

- Add your own models
- Modify the UI
- Add more metrics
- Implement authentication
- Deploy to cloud

### Deploy to Production

For production deployment:

1. **Single Server**: Run on EC2 instance with docker-compose
2. **Infrastructure as Code**: Use the Terraform configs in `terraform/`
3. **CI/CD**: Set up Jenkins with the provided Jenkinsfile
4. **Monitoring**: Configure Prometheus alerts
5. **Security**: Add authentication and HTTPS

See [README.md](README.md) for detailed deployment instructions.

## Getting Help

If you encounter issues:

1. Run `./verify_setup.sh` to check your setup
2. Check logs with `docker-compose logs`
3. Review the troubleshooting section above
4. Check the [README.md](README.md) for more details

## Example Workflow

Here's a typical workflow:

```bash
# 1. Install (first time only)
./install.sh

# 2. Verify setup
./verify_setup.sh

# 3. Start services
./run_demo.sh

# 4. Test the API
./test_api.sh

# 5. Use the UI
# Open http://localhost:8501 in browser

# 6. View metrics
# Open http://localhost:9090 in browser

# 7. Run Python examples
python3 example_usage.py

# 8. Check for drift
python3 app/monitoring.py

# 9. View logs
docker-compose logs -f

# 10. Stop when done
docker-compose down
```

## Tips

- **First Run**: The first run takes longer because it trains models and builds containers
- **Subsequent Runs**: Much faster (30 seconds)
- **Development**: Edit code and restart specific services
- **Testing**: Use `test_api.sh` to verify everything works
- **Monitoring**: Keep Prometheus open to watch metrics in real-time

## What's Next?

Now that you have the pipeline running:

1. ✅ Make some predictions via the UI
2. ✅ Test the API with curl or Python
3. ✅ View metrics in Prometheus
4. ✅ Check the logs
5. ✅ Experiment with A/B split ratios
6. ✅ Run the drift detection
7. ✅ Explore the code
8. ✅ Customize for your needs

Happy MLOps! 🚀
