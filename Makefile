# Makefile for MLOps Pipeline
# Provides convenient commands for common tasks

.PHONY: help install train test build up down logs clean restart status

help:
	@echo "MLOps Pipeline - Available Commands"
	@echo "===================================="
	@echo "make install    - Install all dependencies"
	@echo "make train      - Train ML models"
	@echo "make test       - Run unit tests"
	@echo "make build      - Build Docker images"
	@echo "make up         - Start all services"
	@echo "make down       - Stop all services"
	@echo "make restart    - Restart all services"
	@echo "make logs       - View logs from all services"
	@echo "make status     - Check service status"
	@echo "make clean      - Clean up containers and images"
	@echo "make drift      - Run drift detection"
	@echo ""

install:
	@echo "Installing dependencies..."
	@chmod +x install.sh
	@./install.sh

train:
	@echo "Training models..."
	@python3 app/train_model.py

test:
	@echo "Running tests..."
	@python3 -m pytest tests/ -v

build:
	@echo "Building Docker images..."
	@docker-compose build

up:
	@echo "Starting services..."
	@docker-compose up -d
	@echo ""
	@echo "Services started!"
	@echo "  - Streamlit UI:  http://localhost:8501"
	@echo "  - Flask API:     http://localhost:5000"
	@echo "  - Prometheus:    http://localhost:9090"

down:
	@echo "Stopping services..."
	@docker-compose down

restart:
	@echo "Restarting services..."
	@docker-compose restart

logs:
	@docker-compose logs -f

status:
	@docker-compose ps

clean:
	@echo "Cleaning up..."
	@docker-compose down -v
	@docker system prune -f

drift:
	@echo "Running drift detection..."
	@python3 app/monitoring.py

demo: train up
	@echo ""
	@echo "Demo is running!"
	@echo "Access the services at:"
	@echo "  - Streamlit UI:  http://localhost:8501"
	@echo "  - Flask API:     http://localhost:5000"
	@echo "  - Prometheus:    http://localhost:9090"
