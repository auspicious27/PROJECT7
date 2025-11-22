#!/usr/bin/env python3
"""
Model monitoring and drift detection simulation.
"""

import joblib
import numpy as np
from datetime import datetime

def calculate_drift_score(current_data, training_stats):
    """
    Calculate a simple drift score based on feature statistics.
    
    Returns a score between 0 and 1, where:
    - 0 means no drift
    - 1 means maximum drift
    """
    current_mean = np.mean(current_data, axis=0)
    current_std = np.std(current_data, axis=0)
    
    training_mean = np.array(training_stats['mean'])
    training_std = np.array(training_stats['std'])
    
    # Calculate normalized differences
    mean_diff = np.abs(current_mean - training_mean) / (training_std + 1e-8)
    std_diff = np.abs(current_std - training_std) / (training_std + 1e-8)
    
    # Combine into single score
    drift_score = np.mean(mean_diff + std_diff) / 2
    
    # Normalize to 0-1 range
    drift_score = min(drift_score, 1.0)
    
    return drift_score


def check_drift(current_data, threshold=0.3):
    """
    Check for model drift using current prediction data.
    
    Args:
        current_data: numpy array of recent feature inputs
        threshold: drift score threshold for alerting
    
    Returns:
        dict with drift information
    """
    try:
        # Load training statistics
        training_stats = joblib.load("app/models/training_stats.pkl")
        
        # Calculate drift score
        drift_score = calculate_drift_score(current_data, training_stats)
        
        # Determine if drift detected
        drift_detected = drift_score > threshold
        
        result = {
            'timestamp': datetime.now().isoformat(),
            'drift_score': float(drift_score),
            'threshold': threshold,
            'drift_detected': drift_detected,
            'status': 'WARNING' if drift_detected else 'OK'
        }
        
        # Log result
        print(f"\n{'='*60}")
        print(f"Drift Detection Report - {result['timestamp']}")
        print(f"{'='*60}")
        print(f"Drift Score: {drift_score:.4f}")
        print(f"Threshold: {threshold:.4f}")
        print(f"Status: {result['status']}")
        
        if drift_detected:
            print(f"\n⚠️  WARNING: Potential model drift detected!")
            print(f"   Consider retraining the model with recent data.")
        else:
            print(f"\n✅ No significant drift detected.")
        
        print(f"{'='*60}\n")
        
        return result
    
    except Exception as e:
        print(f"Error checking drift: {str(e)}")
        return {
            'error': str(e),
            'drift_score': 0.0,
            'drift_detected': False
        }


def simulate_drift_check():
    """
    Simulate drift checking with sample data.
    This would normally use real production data.
    """
    print("Running drift detection simulation...")
    
    # Simulate some recent prediction inputs
    # In production, this would come from logged API requests
    np.random.seed(42)
    
    # Scenario 1: No drift (similar to training data)
    print("\nScenario 1: Normal data (no drift)")
    normal_data = np.random.randn(100, 4) * 0.5 + [5.8, 3.0, 4.3, 1.3]
    check_drift(normal_data, threshold=0.3)
    
    # Scenario 2: Slight drift
    print("\nScenario 2: Slightly shifted data (minor drift)")
    shifted_data = np.random.randn(100, 4) * 0.6 + [6.5, 3.2, 5.0, 1.8]
    check_drift(shifted_data, threshold=0.3)
    
    # Scenario 3: Significant drift
    print("\nScenario 3: Significantly different data (major drift)")
    drifted_data = np.random.randn(100, 4) * 1.5 + [7.5, 4.0, 6.0, 2.2]
    check_drift(drifted_data, threshold=0.3)


if __name__ == "__main__":
    simulate_drift_check()
