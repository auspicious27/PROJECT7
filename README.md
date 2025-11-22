# MLOps Pipeline with A/B Testing and Monitoring

A production-style end-to-end MLOps pipeline that demonstrates model deployment, A/B testing, and monitoring using Docker, Flask, Streamlit, Prometheus, and Jenkins.

## Overview

This project implements a complete MLOps workflow for deploying and monitoring machine learning models. It includes:

- **Two ML model versions** (scikit-learn based) for A/B testing
- **Flask API** for serving predictions with configurable A/B split
- **Streamlit UI** for interactive model testing
- **Prometheus monitoring** for tracking requests, latency, and model usage
- **Jenkins CI/CD pipeline** for automated testing and deployment
- **Docker containerization** for all services
- **Model drift detection** simulation

## Tech Stack

- **Python 3** - Core language
- **Flask** - REST API for predictions
- **Streamlit** - Interactive web UI
- **scikit-learn** - ML models
- **Docker & Docker Compose** - Containerization
- **Prometheus** - Metrics and monitoring
- **Jenkins** - CI/CD pipeline
- **prometheus_client** - Python metrics library

## Architecture

```mermaid
flowchart LR
    subgraph User
        U[User/Data Scientist]
    end
    
    subgraph UI
        S[Streamlit App<br/>:8501]
    end
    
    subgraph API
        F[Flask API<br/>:5000]
    end
    
    subgraph Models
        M1[Model v1<br/>50% traffic]
        M2[Model v2<br/>50% traffic]
    end
    
    subgraph Monitoring
        P[Prometheus<br/>:9090]
        ME[/metrics endpoint]
    end
    
    subgraph CI/CD
        J[Jenkins Pipeline]
    end
    
    U --> S
    S --> F
    F --> M1
    F --> M2
    F --> ME
    ME --> P
    J --> F
    J --> S
```

## Setup and Installation

### Prerequisites

- Amazon Linux or Red Hat Enterprise Linux (RHEL)
- Root or sudo access
- Internet connection

### Quick Start

1. **Make scripts executable:**
```bash
chmod +x install.sh run_demo.sh
```

2. **Install dependencies:**
```bash
./install.sh
```

This will install:
- Python 3 and pip
- Docker and Docker Compose
- All Python dependencies
- System packages

3. **Run the demo:**
```bash
./run_demo.sh
```

This will:
- Train both model versions
- Start all services via Docker Compose
- Make services available at:
  - Flask API: http://localhost:5000
  - Streamlit UI: http://localhost:8501
  - Prometheus: http://localhost:9090

## How to Use

### 1. Access the Streamlit UI

Open your browser to `http://localhost:8501`

- Enter feature values in the input fields
- Click "Get Prediction"
- See which model version served your request
- View usage statistics

### 2. Call the Flask API directly

```bash
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [5.1, 3.5, 1.4, 0.2]}'
```

Response:
```json
{
  "prediction": 0,
  "model_version": "v1",
  "timestamp": "2025-11-22T10:30:45"
}
```

### 3. View Prometheus Metrics

- Open `http://localhost:9090`
- Query examples:
  - `prediction_requests_total` - Total predictions
  - `model_version_requests_total{version="v1"}` - V1 requests
  - `prediction_latency_seconds` - Request latency
  - `model_drift_score` - Drift indicator

### 4. Check API Metrics Endpoint

```bash
curl http://localhost:5000/metrics
```

## Configuration

### A/B Testing Split

Configure the traffic split via environment variables in `docker-compose.yml`:

```yaml
environment:
  - MODEL_V1_WEIGHT=50
  - MODEL_V2_WEIGHT=50
```

Values represent percentage weights. For example:
- `MODEL_V1_WEIGHT=70` and `MODEL_V2_WEIGHT=30` = 70% to v1, 30% to v2
- `MODEL_V1_WEIGHT=100` and `MODEL_V2_WEIGHT=0` = 100% to v1 only

After changing, restart services:
```bash
docker-compose down
docker-compose up -d
```

## Jenkins Pipeline

The `Jenkinsfile` defines a CI/CD pipeline with these stages:

1. **Checkout** - Get code from repository
2. **Setup** - Install Python dependencies
3. **Test** - Run unit tests
4. **Train Models** - Generate model versions
5. **Build Docker Images** - Create API and UI containers
6. **Push Images** - (Optional) Push to registry
7. **Deploy** - Start services with docker-compose

### Running in Jenkins

1. Create a new Pipeline job
2. Point to this repository
3. Jenkins will automatically detect the `Jenkinsfile`
4. Run the pipeline

The pipeline uses a Docker agent and runs all stages automatically.

## Model Training

Models are trained using the Iris dataset (scikit-learn):

- **Model v1**: Random Forest with 50 estimators
- **Model v2**: Random Forest with 100 estimators

To retrain models manually:

```bash
python app/train_model.py
```

Models are saved to `app/models/`:
- `model_v1.pkl`
- `model_v2.pkl`

## Monitoring & Model Drift

### Prometheus Metrics

The Flask API exposes these metrics:

- `prediction_requests_total` - Counter of all predictions
- `model_version_requests_total{version}` - Counter per model version
- `prediction_latency_seconds` - Histogram of request latency
- `prediction_errors_total` - Counter of errors
- `model_drift_score` - Gauge indicating potential drift (0-1)

### Drift Detection

The `monitoring.py` script simulates drift detection by:

1. Comparing current prediction distributions to training data
2. Computing a drift score based on feature statistics
3. Logging warnings when drift exceeds threshold (0.3)

Run drift check manually:
```bash
python app/monitoring.py
```

The drift score is also exposed as a Prometheus metric and updated periodically.

## Project Structure

```
.
├── app/
│   ├── flask_app.py          # Flask API with A/B testing
│   ├── streamlit_app.py      # Streamlit UI
│   ├── train_model.py        # Model training script
│   ├── monitoring.py         # Drift detection
│   ├── models/               # Trained models
│   │   ├── model_v1.pkl
│   │   └── model_v2.pkl
│   └── __init__.py
├── tests/
│   └── test_basic.py         # Unit tests
├── docker/
│   ├── Dockerfile.api        # Flask API container
│   ├── Dockerfile.streamlit  # Streamlit UI container
│   └── prometheus.yml        # Prometheus config
├── docker-compose.yml        # Orchestration
├── Jenkinsfile               # CI/CD pipeline
├── requirements.txt          # Python dependencies
├── install.sh                # Installation script
├── run_demo.sh               # Demo runner
└── README.md                 # This file
```

## Testing

Run tests:
```bash
python -m pytest tests/
```

Or within the Jenkins pipeline, tests run automatically.

## Notes on AWS/EKS

This project **does not use AWS EKS**. It's designed to run locally using Docker Compose and is suitable for:

- Local development on Amazon Linux or RHEL
- Single EC2 instance deployment
- On-premise servers

For cloud deployment, you could:
- Run docker-compose on an EC2 instance
- Use AWS ECS (simpler than EKS) for container orchestration
- Set up a simple VM-based deployment

## Troubleshooting

### Port already in use
```bash
docker-compose down
# Or kill specific processes
sudo lsof -ti:5000 | xargs kill -9
```

### Docker permission denied
```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### Models not found
```bash
python app/train_model.py
```

### Services not starting
```bash
docker-compose logs
```

## Extending the Project

Ideas for enhancement:

- Add more sophisticated drift detection (KS test, PSI)
- Implement model versioning with MLflow
- Add data validation with Great Expectations
- Integrate with cloud storage (S3) for models
- Add authentication to API endpoints
- Implement canary deployments
- Add more comprehensive tests
- Set up alerting with Alertmanager

## License

MIT License - feel free to use and modify for your needs.
