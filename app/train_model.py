#!/usr/bin/env python3
"""
Train two versions of ML models for A/B testing.
Uses the Iris dataset from scikit-learn.
"""

import os
import joblib
import numpy as np
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report

def train_models():
    """Train two model versions with different configurations."""
    
    print("Loading Iris dataset...")
    iris = load_iris()
    X, y = iris.data, iris.target
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    print(f"Training data shape: {X_train.shape}")
    print(f"Test data shape: {X_test.shape}")
    
    # Create models directory
    os.makedirs("app/models", exist_ok=True)
    
    # Train Model v1 (50 estimators)
    print("\n" + "="*50)
    print("Training Model v1 (Random Forest with 50 estimators)...")
    model_v1 = RandomForestClassifier(
        n_estimators=50,
        max_depth=5,
        random_state=42
    )
    model_v1.fit(X_train, y_train)
    
    # Evaluate v1
    y_pred_v1 = model_v1.predict(X_test)
    acc_v1 = accuracy_score(y_test, y_pred_v1)
    print(f"Model v1 Accuracy: {acc_v1:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred_v1, target_names=iris.target_names))
    
    # Save v1
    joblib.dump(model_v1, "app/models/model_v1.pkl")
    print("Model v1 saved to app/models/model_v1.pkl")
    
    # Train Model v2 (100 estimators - potentially better)
    print("\n" + "="*50)
    print("Training Model v2 (Random Forest with 100 estimators)...")
    model_v2 = RandomForestClassifier(
        n_estimators=100,
        max_depth=7,
        random_state=42
    )
    model_v2.fit(X_train, y_train)
    
    # Evaluate v2
    y_pred_v2 = model_v2.predict(X_test)
    acc_v2 = accuracy_score(y_test, y_pred_v2)
    print(f"Model v2 Accuracy: {acc_v2:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred_v2, target_names=iris.target_names))
    
    # Save v2
    joblib.dump(model_v2, "app/models/model_v2.pkl")
    print("Model v2 saved to app/models/model_v2.pkl")
    
    # Save training statistics for drift detection
    training_stats = {
        'mean': X_train.mean(axis=0).tolist(),
        'std': X_train.std(axis=0).tolist(),
        'min': X_train.min(axis=0).tolist(),
        'max': X_train.max(axis=0).tolist()
    }
    joblib.dump(training_stats, "app/models/training_stats.pkl")
    print("\nTraining statistics saved for drift detection.")
    
    print("\n" + "="*50)
    print("Training complete!")
    print(f"Model v1 accuracy: {acc_v1:.4f}")
    print(f"Model v2 accuracy: {acc_v2:.4f}")
    print(f"Improvement: {(acc_v2 - acc_v1):.4f}")

if __name__ == "__main__":
    train_models()
