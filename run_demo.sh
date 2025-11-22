#!/bin/bash

set -e

echo "=========================================="
echo "MLOps Pipeline Demo Runner"
echo "=========================================="

# Train models if they don't exist
echo ""
echo "[1/3] Checking models..."
if [ ! -f "app/models/model_v1.pkl" ] || [ ! -f "app/models/model_v2.pkl" ]; then
    echo "Training models..."
    python3 app/train_model.py
else
    echo "Models already exist. Skipping training."
    echo "To retrain, delete app/models/*.pkl and run again."
fi

# Build and start Docker containers
echo ""
echo "[2/3] Building and starting Docker containers..."
docker-compose down 2>/dev/null || true
docker-compose build
docker-compose up -d

# Wait for services to be ready
echo ""
echo "[3/3] Waiting for services to start..."
sleep 5

# Check service health
echo ""
echo "Checking service status..."
docker-compose ps

echo ""
echo "=========================================="
echo "Demo is running!"
echo "=========================================="
echo ""
echo "Access the services:"
echo "  - Streamlit UI:  http://localhost:8501"
echo "  - Flask API:     http://localhost:5000"
echo "  - Prometheus:    http://localhost:9090"
echo ""
echo "Test the API:"
echo '  curl -X POST http://localhost:5000/predict -H "Content-Type: application/json" -d '"'"'{"features": [5.1, 3.5, 1.4, 0.2]}'"'"''
echo ""
echo "View logs:"
echo "  docker-compose logs -f"
echo ""
echo "Stop the demo:"
echo "  docker-compose down"
echo ""
