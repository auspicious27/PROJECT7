#!/usr/bin/env python3
"""
Basic unit tests for the MLOps pipeline.
"""

import pytest
import numpy as np
import joblib
import os
import sys

# Add app directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))


def test_models_exist():
    """Test that model files exist."""
    assert os.path.exists("app/models/model_v1.pkl"), "Model v1 not found"
    assert os.path.exists("app/models/model_v2.pkl"), "Model v2 not found"


def test_models_load():
    """Test that models can be loaded."""
    model_v1 = joblib.load("app/models/model_v1.pkl")
    model_v2 = joblib.load("app/models/model_v2.pkl")
    
    assert model_v1 is not None
    assert model_v2 is not None


def test_model_predictions():
    """Test that models can make predictions."""
    model_v1 = joblib.load("app/models/model_v1.pkl")
    model_v2 = joblib.load("app/models/model_v2.pkl")
    
    # Sample input (Iris features)
    X_test = np.array([[5.1, 3.5, 1.4, 0.2]])
    
    # Test v1
    pred_v1 = model_v1.predict(X_test)
    assert pred_v1.shape == (1,)
    assert pred_v1[0] in [0, 1, 2]
    
    # Test v2
    pred_v2 = model_v2.predict(X_test)
    assert pred_v2.shape == (1,)
    assert pred_v2[0] in [0, 1, 2]


def test_training_stats_exist():
    """Test that training statistics file exists."""
    assert os.path.exists("app/models/training_stats.pkl"), "Training stats not found"


def test_training_stats_structure():
    """Test that training statistics have correct structure."""
    stats = joblib.load("app/models/training_stats.pkl")
    
    assert 'mean' in stats
    assert 'std' in stats
    assert 'min' in stats
    assert 'max' in stats
    
    # Check that each stat has 4 features
    assert len(stats['mean']) == 4
    assert len(stats['std']) == 4
    assert len(stats['min']) == 4
    assert len(stats['max']) == 4


def test_model_input_shape():
    """Test that models expect correct input shape."""
    model_v1 = joblib.load("app/models/model_v1.pkl")
    
    # Correct shape should work
    X_correct = np.array([[5.1, 3.5, 1.4, 0.2]])
    pred = model_v1.predict(X_correct)
    assert pred is not None
    
    # Wrong shape should raise error
    X_wrong = np.array([[5.1, 3.5, 1.4]])  # Only 3 features
    with pytest.raises(ValueError):
        model_v1.predict(X_wrong)


def test_drift_calculation():
    """Test drift score calculation."""
    from app.monitoring import calculate_drift_score
    
    # Load training stats
    training_stats = joblib.load("app/models/training_stats.pkl")
    
    # Test with similar data (should have low drift)
    similar_data = np.random.randn(50, 4) * 0.5 + training_stats['mean']
    drift_score = calculate_drift_score(similar_data, training_stats)
    
    assert 0 <= drift_score <= 1, "Drift score should be between 0 and 1"
    assert drift_score < 0.5, "Similar data should have low drift score"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
