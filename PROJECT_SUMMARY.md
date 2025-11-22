# MLOps Pipeline - Project Summary

## What Was Built

A complete, production-style MLOps pipeline demonstrating end-to-end machine learning deployment with A/B testing, monitoring, and CI/CD capabilities.

## Project Structure

```
mlops-pipeline/
├── app/                          # Application code
│   ├── __init__.py              # Package initializer
│   ├── flask_app.py             # Flask API with A/B testing (180 lines)
│   ├── streamlit_app.py         # Streamlit UI (180 lines)
│   ├── train_model.py           # Model training script (90 lines)
│   └── monitoring.py            # Drift detection (110 lines)
│
├── docker/                       # Docker configurations
│   ├── Dockerfile.api           # Flask API container
│   ├── Dockerfile.streamlit     # Streamlit UI container
│   └── prometheus.yml           # Prometheus config
│
├── tests/                        # Unit tests
│   └── test_basic.py            # Test suite (80 lines)
│
├── terraform/                    # Optional AWS deployment
│   ├── main.tf                  # Infrastructure as code
│   ├── variables.tf             # Terraform variables
│   └── README.md                # Terraform guide
│
├── docker-compose.yml            # Service orchestration
├── Jenkinsfile                   # CI/CD pipeline (150 lines)
├── requirements.txt              # Python dependencies
├── install.sh                    # Installation script
├── run_demo.sh                   # Demo runner script
├── README.md                     # Main documentation
├── QUICKSTART.md                 # Quick start guide
├── ARCHITECTURE.md               # Architecture details
└── .gitignore / .dockerignore   # Git and Docker ignore files
```

## Key Features Implemented

### 1. Machine Learning
- ✅ Two model versions (Random Forest with different configurations)
- ✅ Training script using scikit-learn and Iris dataset
- ✅ Model serialization with joblib
- ✅ Training statistics for drift detection

### 2. API Service (Flask)
- ✅ RESTful prediction endpoint
- ✅ A/B testing with configurable weights
- ✅ Health check endpoint
- ✅ Configuration endpoint
- ✅ Prometheus metrics integration
- ✅ Error handling and validation

### 3. User Interface (Streamlit)
- ✅ Interactive feature input sliders
- ✅ Real-time predictions
- ✅ Model version tracking
- ✅ Usage statistics dashboard
- ✅ Prediction history
- ✅ API health monitoring

### 4. Monitoring (Prometheus)
- ✅ Request counter metrics
- ✅ Model version usage tracking
- ✅ Latency histogram
- ✅ Error counter
- ✅ Drift score gauge
- ✅ Automatic scraping configuration

### 5. A/B Testing Framework
- ✅ Weighted random selection
- ✅ Configurable via environment variables
- ✅ Per-request model selection
- ✅ Version tracking in responses
- ✅ Metrics per model version

### 6. Model Monitoring & Drift Detection
- ✅ Statistical drift calculation
- ✅ Comparison with training data
- ✅ Configurable threshold
- ✅ Drift score metric
- ✅ Simulation script

### 7. Containerization (Docker)
- ✅ Separate containers for API and UI
- ✅ Docker Compose orchestration
- ✅ Health checks for all services
- ✅ Shared network configuration
- ✅ Volume mounting for models

### 8. CI/CD Pipeline (Jenkins)
- ✅ Multi-stage pipeline
- ✅ Automated testing
- ✅ Model training stage
- ✅ Docker image building
- ✅ Deployment automation
- ✅ Health checks and smoke tests
- ✅ Artifact archiving

### 9. Infrastructure (Terraform - Optional)
- ✅ EC2 instance provisioning
- ✅ Security group configuration
- ✅ User data script
- ✅ Output variables
- ✅ Minimal and simple

### 10. Testing
- ✅ Unit tests for models
- ✅ Model loading tests
- ✅ Prediction tests
- ✅ Drift calculation tests
- ✅ Input validation tests

### 11. Documentation
- ✅ Comprehensive README with Mermaid diagrams
- ✅ Quick start guide
- ✅ Architecture documentation
- ✅ Inline code comments
- ✅ Terraform guide
- ✅ Troubleshooting sections

### 12. Installation & Deployment
- ✅ Automated installation script for Amazon Linux/RHEL
- ✅ One-command demo runner
- ✅ Dependency management
- ✅ System package installation
- ✅ Docker and Docker Compose setup

## Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| ML Framework | scikit-learn | Model training |
| API | Flask | Prediction service |
| UI | Streamlit | Interactive interface |
| Monitoring | Prometheus | Metrics collection |
| Containerization | Docker | Service isolation |
| Orchestration | Docker Compose | Multi-container management |
| CI/CD | Jenkins | Automated pipeline |
| IaC | Terraform | Infrastructure provisioning |
| Testing | pytest | Unit testing |
| Language | Python 3.9 | Core development |

## Metrics Exposed

1. **prediction_requests_total** - Total prediction count
2. **model_version_requests_total{version}** - Per-version counts
3. **prediction_latency_seconds** - Response time distribution
4. **prediction_errors_total** - Error count
5. **model_drift_score** - Drift indicator (0-1)

## A/B Testing Configuration

Default: 50/50 split between model v1 and v2

Configurable via environment variables:
- `MODEL_V1_WEIGHT` (default: 50)
- `MODEL_V2_WEIGHT` (default: 50)

## Installation Requirements

### System Requirements
- Amazon Linux or RHEL
- 2+ GB RAM
- 10+ GB disk space
- Internet connection

### Installed by Script
- Python 3 and pip
- Docker
- Docker Compose
- Git
- All Python dependencies

## Usage

### Quick Start
```bash
chmod +x install.sh run_demo.sh
./install.sh
./run_demo.sh
```

### Access Points
- Streamlit UI: http://localhost:8501
- Flask API: http://localhost:5000
- Prometheus: http://localhost:9090

### API Example
```bash
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"features": [5.1, 3.5, 1.4, 0.2]}'
```

## What Makes This Production-Style

1. **Separation of Concerns**: API, UI, and monitoring are separate services
2. **Containerization**: All services run in Docker containers
3. **Monitoring**: Prometheus metrics for observability
4. **Health Checks**: All services have health endpoints
5. **CI/CD**: Automated pipeline with Jenkins
6. **Testing**: Unit tests included
7. **A/B Testing**: Production-grade feature flagging
8. **Drift Detection**: Model monitoring capability
9. **Documentation**: Comprehensive docs and diagrams
10. **Configuration**: Environment-based config
11. **Error Handling**: Proper error responses
12. **Logging**: Structured logging throughout

## What Was Intentionally Kept Simple

1. **No EKS**: Uses Docker Compose instead of Kubernetes
2. **Single Node**: Designed for one machine deployment
3. **In-Memory Metrics**: No persistent metric storage
4. **No Authentication**: For demo purposes
5. **Simple Models**: Basic Random Forest classifiers
6. **Toy Dataset**: Iris dataset (150 samples)
7. **Basic Drift**: Simple statistical approach
8. **No Database**: Models stored as files

## Extensibility

The project is designed to be extended with:
- More sophisticated models
- Real datasets
- Authentication and authorization
- Persistent storage (databases)
- Advanced drift detection (KS test, PSI)
- Model versioning (MLflow)
- Data validation (Great Expectations)
- Cloud deployment (AWS ECS, not EKS)
- Load balancing
- Auto-scaling
- Alerting (Alertmanager)

## Compliance with Requirements

✅ Simple, clean, readable code
✅ Works on Amazon Linux and RHEL
✅ No AWS EKS (uses Docker Compose)
✅ Automated installation script
✅ One-command demo runner
✅ Flask API with predictions
✅ Streamlit UI
✅ Docker containerization
✅ Jenkins pipeline
✅ Prometheus monitoring
✅ A/B testing framework
✅ Model drift detection
✅ Minimal Terraform (optional)
✅ Comprehensive README with Mermaid diagrams
✅ Production-style architecture
✅ Fully working end-to-end

## File Count and Lines of Code

- **Total Files**: 25+
- **Python Files**: 5 (app code) + 1 (tests)
- **Docker Files**: 3
- **Config Files**: 5
- **Documentation**: 5
- **Scripts**: 2
- **Total Lines of Code**: ~1,500+ (excluding docs)

## Time to Deploy

- Installation: ~5 minutes
- First run: ~2 minutes (includes model training)
- Subsequent runs: ~30 seconds

## Learning Value

This project demonstrates:
- MLOps best practices
- Microservices architecture
- Container orchestration
- CI/CD pipelines
- Monitoring and observability
- A/B testing strategies
- Model deployment patterns
- Infrastructure as code
- Testing strategies

Perfect for learning or as a template for real projects!
