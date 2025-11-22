#!/usr/bin/env python3
"""
Flask API for serving ML predictions with A/B testing and Prometheus monitoring.
"""

import os
import time
import random
import joblib
import numpy as np
from datetime import datetime
from flask import Flask, request, jsonify
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Load models
print("Loading models...")
model_v1 = joblib.load("app/models/model_v1.pkl")
model_v2 = joblib.load("app/models/model_v2.pkl")
print("Models loaded successfully!")

# A/B testing configuration
MODEL_V1_WEIGHT = int(os.getenv("MODEL_V1_WEIGHT", "50"))
MODEL_V2_WEIGHT = int(os.getenv("MODEL_V2_WEIGHT", "50"))

print(f"A/B Testing Configuration:")
print(f"  Model v1 weight: {MODEL_V1_WEIGHT}%")
print(f"  Model v2 weight: {MODEL_V2_WEIGHT}%")

# Prometheus metrics
prediction_counter = Counter(
    'prediction_requests_total',
    'Total number of prediction requests'
)

model_version_counter = Counter(
    'model_version_requests_total',
    'Number of requests per model version',
    ['version']
)

prediction_latency = Histogram(
    'prediction_latency_seconds',
    'Prediction request latency in seconds'
)

error_counter = Counter(
    'prediction_errors_total',
    'Total number of prediction errors'
)

drift_score_gauge = Gauge(
    'model_drift_score',
    'Model drift score (0-1, higher means more drift)'
)

# Initialize drift score
drift_score_gauge.set(0.0)


def select_model():
    """Select model based on A/B testing weights."""
    total_weight = MODEL_V1_WEIGHT + MODEL_V2_WEIGHT
    if total_weight == 0:
        return model_v1, "v1"
    
    rand_val = random.randint(1, total_weight)
    
    if rand_val <= MODEL_V1_WEIGHT:
        return model_v1, "v1"
    else:
        return model_v2, "v2"


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'models_loaded': True
    })


@app.route('/predict', methods=['POST'])
def predict():
    """
    Prediction endpoint with A/B testing.
    
    Expected JSON input:
    {
        "features": [5.1, 3.5, 1.4, 0.2]
    }
    
    Returns:
    {
        "prediction": 0,
        "model_version": "v1",
        "timestamp": "2025-11-22T10:30:45"
    }
    """
    start_time = time.time()
    
    try:
        # Increment request counter
        prediction_counter.inc()
        
        # Parse input
        data = request.get_json()
        
        if not data or 'features' not in data:
            error_counter.inc()
            return jsonify({
                'error': 'Missing "features" in request body'
            }), 400
        
        features = np.array(data['features']).reshape(1, -1)
        
        # Validate input shape
        if features.shape[1] != 4:
            error_counter.inc()
            return jsonify({
                'error': f'Expected 4 features, got {features.shape[1]}'
            }), 400
        
        # Select model using A/B testing
        model, version = select_model()
        
        # Make prediction
        prediction = int(model.predict(features)[0])
        
        # Track model version usage
        model_version_counter.labels(version=version).inc()
        
        # Record latency
        latency = time.time() - start_time
        prediction_latency.observe(latency)
        
        # Return response
        return jsonify({
            'prediction': prediction,
            'model_version': version,
            'timestamp': datetime.now().isoformat(),
            'latency_ms': round(latency * 1000, 2)
        })
    
    except Exception as e:
        error_counter.inc()
        return jsonify({
            'error': str(e)
        }), 500


@app.route('/metrics', methods=['GET'])
def metrics():
    """Prometheus metrics endpoint."""
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


@app.route('/config', methods=['GET'])
def config():
    """Return current A/B testing configuration."""
    return jsonify({
        'model_v1_weight': MODEL_V1_WEIGHT,
        'model_v2_weight': MODEL_V2_WEIGHT,
        'total_weight': MODEL_V1_WEIGHT + MODEL_V2_WEIGHT
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
