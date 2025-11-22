# Quick Start Guide

Get the MLOps pipeline running in 5 minutes!

## Prerequisites

- Amazon Linux or RHEL system
- Root or sudo access
- Internet connection

## Installation (2 minutes)

```bash
# 1. Clone or download the project
cd mlops-pipeline

# 2. Make scripts executable
chmod +x install.sh run_demo.sh

# 3. Run installation
./install.sh
```

The installation script will:
- Install Python 3 and pip
- Install Docker and Docker Compose
- Install all Python dependencies
- Set up the environment

**Note**: If this is your first Docker installation, log out and back in after running `install.sh`.

## Running the Demo (1 minute)

```bash
./run_demo.sh
```

This will:
- Train the ML models (if not already trained)
- Build Docker containers
- Start all services

## Access the Services

Once running, open your browser:

- **Streamlit UI**: http://localhost:8501
- **Flask API**: http://localhost:5000
- **Prometheus**: http://localhost:9090

## Test the API

```bash
# Make a prediction
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [5.1, 3.5, 1.4, 0.2]}'

# Check health
curl http://localhost:5000/health

# View metrics
curl http://localhost:5000/metrics
```

## Using the Streamlit UI

1. Open http://localhost:8501
2. Adjust the feature sliders:
   - Sepal Length
   - Sepal Width
   - Petal Length
   - Petal Width
3. Click "Get Prediction"
4. See the predicted flower type and which model version served it
5. View statistics on model usage

## View Monitoring

1. Open http://localhost:9090 (Prometheus)
2. Try these queries:
   - `prediction_requests_total` - Total predictions
   - `rate(prediction_requests_total[1m])` - Requests per second
   - `model_version_requests_total` - Requests by model version
   - `prediction_latency_seconds` - Latency histogram

## Stopping the Demo

```bash
docker-compose down
```

## Viewing Logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs flask-api
docker-compose logs streamlit-ui
docker-compose logs prometheus

# Follow logs
docker-compose logs -f
```

## Changing A/B Split

Edit `docker-compose.yml`:

```yaml
services:
  flask-api:
    environment:
      - MODEL_V1_WEIGHT=70  # 70% to model v1
      - MODEL_V2_WEIGHT=30  # 30% to model v2
```

Then restart:

```bash
docker-compose down
docker-compose up -d
```

## Retraining Models

```bash
python3 app/train_model.py
docker-compose restart flask-api
```

## Running Tests

```bash
python3 -m pytest tests/ -v
```

## Common Issues

### Port Already in Use

```bash
# Stop all services
docker-compose down

# Or kill specific port
sudo lsof -ti:5000 | xargs kill -9
```

### Docker Permission Denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in
```

### Models Not Found

```bash
# Train models
python3 app/train_model.py
```

### Services Not Starting

```bash
# Check logs
docker-compose logs

# Rebuild containers
docker-compose build --no-cache
docker-compose up -d
```

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Check [ARCHITECTURE.md](ARCHITECTURE.md) for system design details
- Explore the [Jenkinsfile](Jenkinsfile) for CI/CD pipeline
- Review [terraform/](terraform/) for AWS deployment (optional)

## Getting Help

If you encounter issues:

1. Check the logs: `docker-compose logs`
2. Verify services are running: `docker-compose ps`
3. Check port availability: `netstat -tuln | grep -E '5000|8501|9090'`
4. Ensure models exist: `ls -lh app/models/`

## Example Workflow

Here's a typical workflow:

```bash
# 1. Install
./install.sh

# 2. Start services
./run_demo.sh

# 3. Make some predictions via UI
# Open http://localhost:8501 and test

# 4. Check metrics
# Open http://localhost:9090

# 5. Test API directly
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [6.5, 3.0, 5.2, 2.0]}'

# 6. Run drift detection
python3 app/monitoring.py

# 7. View logs
docker-compose logs -f flask-api

# 8. Stop when done
docker-compose down
```

Enjoy your MLOps pipeline! 🚀
