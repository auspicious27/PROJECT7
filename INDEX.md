# MLOps Pipeline - Complete Documentation Index

Welcome to the MLOps Pipeline project! This index will help you navigate all the documentation.

## 📚 Quick Navigation

### Getting Started (Start Here!)
- **[GETTING_STARTED.md](GETTING_STARTED.md)** - Complete beginner's guide
- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute quick start
- **[README.md](README.md)** - Main project documentation

### Understanding the System
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Detailed system architecture
- **[DIAGRAMS.md](DIAGRAMS.md)** - Visual diagrams and flowcharts
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Project overview and features

### Installation & Setup
- **[install.sh](install.sh)** - Automated installation script
- **[verify_setup.sh](verify_setup.sh)** - Verify your installation
- **[requirements.txt](requirements.txt)** - Python dependencies

### Running the Project
- **[run_demo.sh](run_demo.sh)** - Start all services
- **[docker-compose.yml](docker-compose.yml)** - Service orchestration
- **[Makefile](Makefile)** - Convenient make commands

### Testing & Examples
- **[test_api.sh](test_api.sh)** - API testing script
- **[example_usage.py](example_usage.py)** - Python usage examples
- **[tests/test_basic.py](tests/test_basic.py)** - Unit tests

### Application Code
- **[app/flask_app.py](app/flask_app.py)** - Flask API with A/B testing
- **[app/streamlit_app.py](app/streamlit_app.py)** - Streamlit UI
- **[app/train_model.py](app/train_model.py)** - Model training
- **[app/monitoring.py](app/monitoring.py)** - Drift detection

### Docker & Deployment
- **[docker/Dockerfile.api](docker/Dockerfile.api)** - API container
- **[docker/Dockerfile.streamlit](docker/Dockerfile.streamlit)** - UI container
- **[docker/prometheus.yml](docker/prometheus.yml)** - Prometheus config

### CI/CD
- **[Jenkinsfile](Jenkinsfile)** - Jenkins pipeline definition

### Infrastructure (Optional)
- **[terraform/main.tf](terraform/main.tf)** - Terraform configuration
- **[terraform/README.md](terraform/README.md)** - Terraform guide

## 📖 Documentation by Role

### For Beginners
1. Start with [GETTING_STARTED.md](GETTING_STARTED.md)
2. Run `./install.sh` and `./run_demo.sh`
3. Open http://localhost:8501 and play with the UI
4. Read [QUICKSTART.md](QUICKSTART.md) for quick reference

### For Data Scientists
1. Read [README.md](README.md) for overview
2. Check [app/train_model.py](app/train_model.py) for model training
3. Run `python3 example_usage.py` for API examples
4. Review [app/monitoring.py](app/monitoring.py) for drift detection
5. Explore [ARCHITECTURE.md](ARCHITECTURE.md) for ML pipeline details

### For DevOps Engineers
1. Review [ARCHITECTURE.md](ARCHITECTURE.md) for system design
2. Check [docker-compose.yml](docker-compose.yml) for services
3. Study [Jenkinsfile](Jenkinsfile) for CI/CD pipeline
4. Review [terraform/](terraform/) for infrastructure
5. Check [docker/prometheus.yml](docker/prometheus.yml) for monitoring

### For Software Developers
1. Read [README.md](README.md) for project overview
2. Review [app/flask_app.py](app/flask_app.py) for API implementation
3. Check [app/streamlit_app.py](app/streamlit_app.py) for UI code
4. Run tests with `python3 -m pytest tests/`
5. Use [example_usage.py](example_usage.py) for integration examples

### For System Administrators
1. Read [GETTING_STARTED.md](GETTING_STARTED.md) for installation
2. Run `./verify_setup.sh` to check system
3. Review [install.sh](install.sh) for dependencies
4. Check [docker-compose.yml](docker-compose.yml) for services
5. Monitor with Prometheus at http://localhost:9090

## 🎯 Documentation by Task

### Installation
- [GETTING_STARTED.md](GETTING_STARTED.md) - Complete installation guide
- [install.sh](install.sh) - Automated installer
- [verify_setup.sh](verify_setup.sh) - Verify installation
- [requirements.txt](requirements.txt) - Dependencies

### Running the System
- [run_demo.sh](run_demo.sh) - Start everything
- [docker-compose.yml](docker-compose.yml) - Service configuration
- [Makefile](Makefile) - Make commands
- [QUICKSTART.md](QUICKSTART.md) - Quick commands

### Using the API
- [README.md](README.md) - API documentation
- [test_api.sh](test_api.sh) - API testing
- [example_usage.py](example_usage.py) - Python examples
- [app/flask_app.py](app/flask_app.py) - API source code

### Training Models
- [app/train_model.py](app/train_model.py) - Training script
- [README.md](README.md) - Training documentation
- [ARCHITECTURE.md](ARCHITECTURE.md) - Model architecture

### Monitoring
- [docker/prometheus.yml](docker/prometheus.yml) - Prometheus config
- [app/monitoring.py](app/monitoring.py) - Drift detection
- [ARCHITECTURE.md](ARCHITECTURE.md) - Monitoring architecture
- [README.md](README.md) - Metrics documentation

### A/B Testing
- [app/flask_app.py](app/flask_app.py) - A/B implementation
- [README.md](README.md) - A/B configuration
- [ARCHITECTURE.md](ARCHITECTURE.md) - A/B architecture
- [docker-compose.yml](docker-compose.yml) - Weight configuration

### Deployment
- [docker-compose.yml](docker-compose.yml) - Local deployment
- [terraform/](terraform/) - AWS deployment
- [Jenkinsfile](Jenkinsfile) - CI/CD pipeline
- [ARCHITECTURE.md](ARCHITECTURE.md) - Deployment architecture

### Troubleshooting
- [GETTING_STARTED.md](GETTING_STARTED.md) - Common issues
- [README.md](README.md) - Troubleshooting section
- [verify_setup.sh](verify_setup.sh) - System check
- [docker-compose.yml](docker-compose.yml) - Service logs

## 📊 Visual Documentation

### Diagrams
- [DIAGRAMS.md](DIAGRAMS.md) - All system diagrams
- [README.md](README.md) - Architecture diagram
- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed diagrams

### Screenshots
Access the running system:
- Streamlit UI: http://localhost:8501
- Flask API: http://localhost:5000/health
- Prometheus: http://localhost:9090

## 🔧 Configuration Files

### Docker
- [docker-compose.yml](docker-compose.yml) - Service orchestration
- [docker/Dockerfile.api](docker/Dockerfile.api) - API container
- [docker/Dockerfile.streamlit](docker/Dockerfile.streamlit) - UI container
- [docker/prometheus.yml](docker/prometheus.yml) - Monitoring config
- [.dockerignore](.dockerignore) - Docker ignore rules

### Python
- [requirements.txt](requirements.txt) - Dependencies
- [app/__init__.py](app/__init__.py) - Package init

### CI/CD
- [Jenkinsfile](Jenkinsfile) - Pipeline definition

### Infrastructure
- [terraform/main.tf](terraform/main.tf) - Infrastructure code
- [terraform/variables.tf](terraform/variables.tf) - Variables

### Git
- [.gitignore](.gitignore) - Git ignore rules

## 🧪 Testing Documentation

### Test Files
- [tests/test_basic.py](tests/test_basic.py) - Unit tests
- [test_api.sh](test_api.sh) - API tests
- [example_usage.py](example_usage.py) - Integration examples

### Running Tests
```bash
# Unit tests
python3 -m pytest tests/ -v

# API tests
./test_api.sh

# Examples
python3 example_usage.py

# Drift detection
python3 app/monitoring.py
```

## 📝 Scripts Reference

### Shell Scripts
- **install.sh** - Install all dependencies
- **run_demo.sh** - Start the demo
- **verify_setup.sh** - Verify installation
- **test_api.sh** - Test API endpoints

### Python Scripts
- **app/train_model.py** - Train ML models
- **app/flask_app.py** - Run Flask API
- **app/streamlit_app.py** - Run Streamlit UI
- **app/monitoring.py** - Check model drift
- **example_usage.py** - Usage examples

### Make Commands
```bash
make help      # Show all commands
make install   # Install dependencies
make train     # Train models
make up        # Start services
make down      # Stop services
make test      # Run tests
make logs      # View logs
make drift     # Check drift
```

## 🌐 URLs Reference

When services are running:

| Service | URL | Description |
|---------|-----|-------------|
| Streamlit UI | http://localhost:8501 | Interactive interface |
| Flask API | http://localhost:5000 | REST API |
| API Health | http://localhost:5000/health | Health check |
| API Config | http://localhost:5000/config | A/B config |
| API Metrics | http://localhost:5000/metrics | Prometheus metrics |
| Prometheus | http://localhost:9090 | Metrics dashboard |

## 📦 Project Structure

```
mlops-pipeline/
├── 📄 Documentation
│   ├── README.md              # Main documentation
│   ├── GETTING_STARTED.md     # Beginner's guide
│   ├── QUICKSTART.md          # Quick reference
│   ├── ARCHITECTURE.md        # System architecture
│   ├── DIAGRAMS.md            # Visual diagrams
│   ├── PROJECT_SUMMARY.md     # Project overview
│   └── INDEX.md               # This file
│
├── 🐍 Application Code
│   └── app/
│       ├── flask_app.py       # Flask API
│       ├── streamlit_app.py   # Streamlit UI
│       ├── train_model.py     # Model training
│       ├── monitoring.py      # Drift detection
│       └── models/            # Trained models
│
├── 🐳 Docker
│   ├── docker/
│   │   ├── Dockerfile.api
│   │   ├── Dockerfile.streamlit
│   │   └── prometheus.yml
│   └── docker-compose.yml
│
├── 🧪 Testing
│   ├── tests/
│   │   └── test_basic.py
│   ├── test_api.sh
│   └── example_usage.py
│
├── 🔄 CI/CD
│   └── Jenkinsfile
│
├── 🏗️ Infrastructure
│   └── terraform/
│       ├── main.tf
│       ├── variables.tf
│       └── README.md
│
├── 🔧 Scripts
│   ├── install.sh
│   ├── run_demo.sh
│   ├── verify_setup.sh
│   └── Makefile
│
└── 📋 Configuration
    ├── requirements.txt
    ├── .gitignore
    ├── .dockerignore
    └── LICENSE
```

## 🚀 Quick Commands

```bash
# Installation
./install.sh

# Verification
./verify_setup.sh

# Start services
./run_demo.sh

# Test API
./test_api.sh

# Run examples
python3 example_usage.py

# Train models
python3 app/train_model.py

# Check drift
python3 app/monitoring.py

# Run tests
python3 -m pytest tests/ -v

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 📞 Getting Help

1. **Check Documentation**: Start with [GETTING_STARTED.md](GETTING_STARTED.md)
2. **Verify Setup**: Run `./verify_setup.sh`
3. **Check Logs**: Run `docker-compose logs`
4. **Review Troubleshooting**: See [README.md](README.md) troubleshooting section
5. **Test System**: Run `./test_api.sh`

## 🎓 Learning Path

### Beginner Path
1. [GETTING_STARTED.md](GETTING_STARTED.md)
2. [QUICKSTART.md](QUICKSTART.md)
3. Run `./install.sh` and `./run_demo.sh`
4. Use the Streamlit UI
5. [README.md](README.md)

### Intermediate Path
1. [README.md](README.md)
2. [ARCHITECTURE.md](ARCHITECTURE.md)
3. [DIAGRAMS.md](DIAGRAMS.md)
4. Review application code in `app/`
5. Run `python3 example_usage.py`

### Advanced Path
1. [ARCHITECTURE.md](ARCHITECTURE.md)
2. [Jenkinsfile](Jenkinsfile)
3. [docker-compose.yml](docker-compose.yml)
4. [terraform/](terraform/)
5. Customize and extend

## 📄 License

See [LICENSE](LICENSE) file for details.

---

**Need help?** Start with [GETTING_STARTED.md](GETTING_STARTED.md) or run `./verify_setup.sh`
