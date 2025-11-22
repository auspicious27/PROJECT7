#!/usr/bin/env python3
"""
Streamlit UI for interacting with the ML model API.
"""

import streamlit as st
import requests
import pandas as pd
import time
from datetime import datetime

# Configuration
API_URL = "http://flask-api:5000"

# Page config
st.set_page_config(
    page_title="MLOps Model Predictor",
    page_icon="🤖",
    layout="wide"
)

# Initialize session state
if 'predictions' not in st.session_state:
    st.session_state.predictions = []

# Title
st.title("🤖 MLOps Model Predictor")
st.markdown("### Iris Flower Classification with A/B Testing")

# Sidebar
st.sidebar.header("About")
st.sidebar.info(
    "This app demonstrates an MLOps pipeline with:\n\n"
    "- Two model versions (v1 and v2)\n"
    "- A/B testing between models\n"
    "- Real-time monitoring\n"
    "- Prometheus metrics"
)

# Check API health
try:
    health_response = requests.get(f"{API_URL}/health", timeout=2)
    if health_response.status_code == 200:
        st.sidebar.success("✅ API is healthy")
    else:
        st.sidebar.error("❌ API is unhealthy")
except:
    st.sidebar.error("❌ Cannot connect to API")

# Get A/B config
try:
    config_response = requests.get(f"{API_URL}/config", timeout=2)
    if config_response.status_code == 200:
        config = config_response.json()
        st.sidebar.markdown("### A/B Testing Config")
        st.sidebar.write(f"Model v1: {config['model_v1_weight']}%")
        st.sidebar.write(f"Model v2: {config['model_v2_weight']}%")
except:
    pass

# Main content
col1, col2 = st.columns([1, 1])

with col1:
    st.header("Input Features")
    st.markdown("Enter the Iris flower measurements:")
    
    # Feature inputs
    sepal_length = st.slider(
        "Sepal Length (cm)",
        min_value=4.0,
        max_value=8.0,
        value=5.1,
        step=0.1
    )
    
    sepal_width = st.slider(
        "Sepal Width (cm)",
        min_value=2.0,
        max_value=4.5,
        value=3.5,
        step=0.1
    )
    
    petal_length = st.slider(
        "Petal Length (cm)",
        min_value=1.0,
        max_value=7.0,
        value=1.4,
        step=0.1
    )
    
    petal_width = st.slider(
        "Petal Width (cm)",
        min_value=0.1,
        max_value=2.5,
        value=0.2,
        step=0.1
    )
    
    # Predict button
    if st.button("🔮 Get Prediction", type="primary"):
        features = [sepal_length, sepal_width, petal_length, petal_width]
        
        with st.spinner("Making prediction..."):
            try:
                response = requests.post(
                    f"{API_URL}/predict",
                    json={"features": features},
                    timeout=5
                )
                
                if response.status_code == 200:
                    result = response.json()
                    
                    # Map prediction to class name
                    class_names = ["Setosa", "Versicolor", "Virginica"]
                    predicted_class = class_names[result['prediction']]
                    
                    # Store prediction
                    st.session_state.predictions.append({
                        'timestamp': result['timestamp'],
                        'prediction': predicted_class,
                        'model_version': result['model_version'],
                        'latency_ms': result['latency_ms']
                    })
                    
                    # Display result
                    st.success("Prediction successful!")
                    st.markdown(f"### Predicted Class: **{predicted_class}**")
                    st.info(f"Model Version: **{result['model_version']}**")
                    st.caption(f"Latency: {result['latency_ms']} ms")
                else:
                    st.error(f"Error: {response.json().get('error', 'Unknown error')}")
            
            except Exception as e:
                st.error(f"Failed to connect to API: {str(e)}")

with col2:
    st.header("Prediction Results")
    
    if st.session_state.predictions:
        # Recent predictions
        st.markdown("### Recent Predictions")
        recent_df = pd.DataFrame(st.session_state.predictions[-10:])
        st.dataframe(recent_df, use_container_width=True)
        
        # Statistics
        st.markdown("### Statistics")
        total_predictions = len(st.session_state.predictions)
        v1_count = sum(1 for p in st.session_state.predictions if p['model_version'] == 'v1')
        v2_count = sum(1 for p in st.session_state.predictions if p['model_version'] == 'v2')
        avg_latency = sum(p['latency_ms'] for p in st.session_state.predictions) / total_predictions
        
        col_a, col_b, col_c = st.columns(3)
        col_a.metric("Total Predictions", total_predictions)
        col_b.metric("Model v1 Usage", f"{v1_count} ({v1_count/total_predictions*100:.1f}%)")
        col_c.metric("Model v2 Usage", f"{v2_count} ({v2_count/total_predictions*100:.1f}%)")
        
        st.metric("Average Latency", f"{avg_latency:.2f} ms")
        
        # Clear button
        if st.button("Clear History"):
            st.session_state.predictions = []
            st.rerun()
    else:
        st.info("No predictions yet. Enter features and click 'Get Prediction' to start.")

# Footer
st.markdown("---")
st.markdown(
    "**MLOps Pipeline Demo** | "
    "[API Docs](http://localhost:5000/health) | "
    "[Prometheus](http://localhost:9090) | "
    "[Metrics](http://localhost:5000/metrics)"
)
