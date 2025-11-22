#!/bin/bash

# Script to test the Flask API endpoints

API_URL="http://localhost:5000"

echo "=========================================="
echo "MLOps API Testing Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo -e "${YELLOW}Testing: $description${NC}"
    echo "Endpoint: $method $endpoint"
    
    if [ -z "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method "$API_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$API_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    
    http_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 200 ]; then
        echo -e "${GREEN}✅ Success (HTTP $http_code)${NC}"
        echo "Response: $body" | head -c 200
        if [ ${#body} -gt 200 ]; then
            echo "..."
        fi
    else
        echo -e "${RED}❌ Failed (HTTP $http_code)${NC}"
        echo "Response: $body"
    fi
    echo ""
}

# Check if API is reachable
echo "Checking if API is reachable..."
if curl -s --connect-timeout 5 "$API_URL/health" > /dev/null; then
    echo -e "${GREEN}✅ API is reachable${NC}"
else
    echo -e "${RED}❌ Cannot reach API at $API_URL${NC}"
    echo "Make sure services are running: ./run_demo.sh"
    exit 1
fi
echo ""

# Test 1: Health check
test_endpoint "GET" "/health" "" "Health Check"

# Test 2: Configuration
test_endpoint "GET" "/config" "" "A/B Testing Configuration"

# Test 3: Prediction - Setosa (class 0)
test_endpoint "POST" "/predict" \
    '{"features": [5.1, 3.5, 1.4, 0.2]}' \
    "Prediction - Iris Setosa"

# Test 4: Prediction - Versicolor (class 1)
test_endpoint "POST" "/predict" \
    '{"features": [6.0, 2.9, 4.5, 1.5]}' \
    "Prediction - Iris Versicolor"

# Test 5: Prediction - Virginica (class 2)
test_endpoint "POST" "/predict" \
    '{"features": [6.5, 3.0, 5.2, 2.0]}' \
    "Prediction - Iris Virginica"

# Test 6: Invalid input - missing features
test_endpoint "POST" "/predict" \
    '{"wrong_key": [1, 2, 3, 4]}' \
    "Invalid Input - Missing Features (should fail)"

# Test 7: Invalid input - wrong number of features
test_endpoint "POST" "/predict" \
    '{"features": [1, 2, 3]}' \
    "Invalid Input - Wrong Feature Count (should fail)"

# Test 8: Metrics endpoint
echo -e "${YELLOW}Testing: Prometheus Metrics${NC}"
echo "Endpoint: GET /metrics"
metrics=$(curl -s "$API_URL/metrics")
if echo "$metrics" | grep -q "prediction_requests_total"; then
    echo -e "${GREEN}✅ Metrics endpoint working${NC}"
    echo "Sample metrics:"
    echo "$metrics" | grep "prediction_requests_total" | head -n 3
else
    echo -e "${RED}❌ Metrics endpoint not working${NC}"
fi
echo ""

# Load test - make multiple requests
echo -e "${YELLOW}Load Test: Making 20 predictions...${NC}"
v1_count=0
v2_count=0

for i in {1..20}; do
    response=$(curl -s -X POST "$API_URL/predict" \
        -H "Content-Type: application/json" \
        -d '{"features": [5.1, 3.5, 1.4, 0.2]}')
    
    if echo "$response" | grep -q '"model_version": "v1"'; then
        v1_count=$((v1_count + 1))
    elif echo "$response" | grep -q '"model_version": "v2"'; then
        v2_count=$((v2_count + 1))
    fi
    
    # Show progress
    echo -n "."
done

echo ""
echo -e "${GREEN}✅ Load test complete${NC}"
echo "Model v1 served: $v1_count requests (${v1_count}%)"
echo "Model v2 served: $v2_count requests (${v2_count}%)"
echo ""

# Summary
echo "=========================================="
echo "Testing Complete!"
echo "=========================================="
echo ""
echo "View detailed metrics at: http://localhost:9090"
echo "Access Streamlit UI at: http://localhost:8501"
echo ""
