#!/usr/bin/env python3
"""
Example usage script demonstrating how to interact with the MLOps pipeline.
This script shows various ways to use the API and models.
"""

import requests
import json
import time
import numpy as np
from datetime import datetime

# Configuration
API_URL = "http://localhost:5000"

def print_section(title):
    """Print a formatted section header."""
    print("\n" + "="*60)
    print(f"  {title}")
    print("="*60 + "\n")


def check_api_health():
    """Check if the API is healthy and running."""
    print_section("1. Health Check")
    
    try:
        response = requests.get(f"{API_URL}/health", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print("✅ API is healthy!")
            print(f"Status: {data['status']}")
            print(f"Timestamp: {data['timestamp']}")
            return True
        else:
            print("❌ API returned non-200 status")
            return False
    except Exception as e:
        print(f"❌ Cannot connect to API: {e}")
        print("Make sure services are running: ./run_demo.sh")
        return False


def get_ab_config():
    """Get current A/B testing configuration."""
    print_section("2. A/B Testing Configuration")
    
    response = requests.get(f"{API_URL}/config")
    config = response.json()
    
    print(f"Model v1 weight: {config['model_v1_weight']}%")
    print(f"Model v2 weight: {config['model_v2_weight']}%")
    print(f"Total weight: {config['total_weight']}")


def make_single_prediction(features, description=""):
    """Make a single prediction."""
    payload = {"features": features}
    
    start_time = time.time()
    response = requests.post(
        f"{API_URL}/predict",
        json=payload,
        headers={"Content-Type": "application/json"}
    )
    latency = (time.time() - start_time) * 1000
    
    if response.status_code == 200:
        result = response.json()
        
        # Map prediction to class name
        class_names = ["Setosa", "Versicolor", "Virginica"]
        predicted_class = class_names[result['prediction']]
        
        print(f"Input: {features}")
        if description:
            print(f"Description: {description}")
        print(f"Prediction: {predicted_class} (class {result['prediction']})")
        print(f"Model version: {result['model_version']}")
        print(f"API latency: {result['latency_ms']:.2f} ms")
        print(f"Total latency: {latency:.2f} ms")
        
        return result
    else:
        print(f"❌ Error: {response.json()}")
        return None


def test_predictions():
    """Test predictions with different inputs."""
    print_section("3. Making Predictions")
    
    # Example 1: Iris Setosa
    print("Example 1: Iris Setosa (small flower)")
    make_single_prediction([5.1, 3.5, 1.4, 0.2], "Small petals and sepals")
    print()
    
    # Example 2: Iris Versicolor
    print("Example 2: Iris Versicolor (medium flower)")
    make_single_prediction([6.0, 2.9, 4.5, 1.5], "Medium-sized features")
    print()
    
    # Example 3: Iris Virginica
    print("Example 3: Iris Virginica (large flower)")
    make_single_prediction([6.5, 3.0, 5.2, 2.0], "Large petals")
    print()


def test_ab_distribution():
    """Test A/B testing distribution."""
    print_section("4. A/B Testing Distribution")
    
    print("Making 50 predictions to test A/B split...")
    
    v1_count = 0
    v2_count = 0
    latencies = []
    
    for i in range(50):
        response = requests.post(
            f"{API_URL}/predict",
            json={"features": [5.1, 3.5, 1.4, 0.2]}
        )
        
        if response.status_code == 200:
            result = response.json()
            latencies.append(result['latency_ms'])
            
            if result['model_version'] == 'v1':
                v1_count += 1
            else:
                v2_count += 1
        
        # Progress indicator
        if (i + 1) % 10 == 0:
            print(f"  Completed {i + 1}/50 requests...")
    
    print(f"\nResults:")
    print(f"  Model v1: {v1_count} requests ({v1_count/50*100:.1f}%)")
    print(f"  Model v2: {v2_count} requests ({v2_count/50*100:.1f}%)")
    print(f"\nLatency statistics:")
    print(f"  Mean: {np.mean(latencies):.2f} ms")
    print(f"  Median: {np.median(latencies):.2f} ms")
    print(f"  Min: {np.min(latencies):.2f} ms")
    print(f"  Max: {np.max(latencies):.2f} ms")
    print(f"  Std: {np.std(latencies):.2f} ms")


def test_error_handling():
    """Test error handling with invalid inputs."""
    print_section("5. Error Handling")
    
    # Test 1: Missing features
    print("Test 1: Missing 'features' key")
    response = requests.post(
        f"{API_URL}/predict",
        json={"wrong_key": [1, 2, 3, 4]}
    )
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    print()
    
    # Test 2: Wrong number of features
    print("Test 2: Wrong number of features (3 instead of 4)")
    response = requests.post(
        f"{API_URL}/predict",
        json={"features": [1, 2, 3]}
    )
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    print()


def view_metrics():
    """View Prometheus metrics."""
    print_section("6. Prometheus Metrics")
    
    response = requests.get(f"{API_URL}/metrics")
    metrics_text = response.text
    
    # Extract key metrics
    print("Key metrics:")
    for line in metrics_text.split('\n'):
        if line and not line.startswith('#'):
            if any(keyword in line for keyword in [
                'prediction_requests_total',
                'model_version_requests_total',
                'prediction_errors_total',
                'model_drift_score'
            ]):
                print(f"  {line}")


def batch_predictions():
    """Make batch predictions."""
    print_section("7. Batch Predictions")
    
    # Generate random test data
    print("Generating 10 random test samples...")
    np.random.seed(42)
    
    # Generate samples around different class centers
    samples = [
        # Setosa-like
        [5.0 + np.random.randn()*0.3, 3.5 + np.random.randn()*0.3, 
         1.4 + np.random.randn()*0.2, 0.2 + np.random.randn()*0.1],
        # Versicolor-like
        [6.0 + np.random.randn()*0.3, 2.9 + np.random.randn()*0.3, 
         4.5 + np.random.randn()*0.3, 1.5 + np.random.randn()*0.2],
        # Virginica-like
        [6.5 + np.random.randn()*0.3, 3.0 + np.random.randn()*0.3, 
         5.2 + np.random.randn()*0.3, 2.0 + np.random.randn()*0.2],
    ]
    
    # Repeat to get 10 samples
    samples = samples * 4
    samples = samples[:10]
    
    results = []
    class_names = ["Setosa", "Versicolor", "Virginica"]
    
    print("\nMaking predictions...")
    for i, features in enumerate(samples, 1):
        # Ensure non-negative values
        features = [max(0.1, f) for f in features]
        
        response = requests.post(
            f"{API_URL}/predict",
            json={"features": features}
        )
        
        if response.status_code == 200:
            result = response.json()
            results.append(result)
            
            predicted_class = class_names[result['prediction']]
            print(f"  Sample {i}: {predicted_class} (v{result['model_version'][-1]})")
    
    # Summary
    print(f"\nBatch summary:")
    print(f"  Total predictions: {len(results)}")
    print(f"  Average latency: {np.mean([r['latency_ms'] for r in results]):.2f} ms")
    
    # Count predictions by class
    predictions = [r['prediction'] for r in results]
    for i, class_name in enumerate(class_names):
        count = predictions.count(i)
        print(f"  {class_name}: {count} predictions")


def main():
    """Main function to run all examples."""
    print("\n" + "="*60)
    print("  MLOps Pipeline - Example Usage")
    print("="*60)
    
    # Check if API is running
    if not check_api_health():
        return
    
    # Run all examples
    get_ab_config()
    test_predictions()
    test_ab_distribution()
    test_error_handling()
    view_metrics()
    batch_predictions()
    
    # Final message
    print_section("Summary")
    print("✅ All examples completed successfully!")
    print("\nNext steps:")
    print("  - View Streamlit UI: http://localhost:8501")
    print("  - View Prometheus: http://localhost:9090")
    print("  - Check API docs: http://localhost:5000/health")
    print("  - Run drift detection: python3 app/monitoring.py")
    print()


if __name__ == "__main__":
    main()
