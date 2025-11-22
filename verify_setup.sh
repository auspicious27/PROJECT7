#!/bin/bash

# Verification script to check if the MLOps pipeline is set up correctly

echo "=========================================="
echo "MLOps Pipeline Setup Verification"
echo "=========================================="
echo ""

ERRORS=0
WARNINGS=0

# Function to check command
check_command() {
    if command -v $1 &> /dev/null; then
        echo "✅ $1 is installed"
        $1 --version 2>&1 | head -n 1 | sed 's/^/   /'
    else
        echo "❌ $1 is NOT installed"
        ERRORS=$((ERRORS + 1))
    fi
}

# Function to check file
check_file() {
    if [ -f "$1" ]; then
        echo "✅ $1 exists"
    else
        echo "❌ $1 is missing"
        ERRORS=$((ERRORS + 1))
    fi
}

# Function to check directory
check_directory() {
    if [ -d "$1" ]; then
        echo "✅ $1 directory exists"
    else
        echo "⚠️  $1 directory is missing"
        WARNINGS=$((WARNINGS + 1))
    fi
}

# Check system commands
echo "[1/5] Checking System Dependencies..."
check_command python3
check_command pip3
check_command docker
check_command docker-compose
check_command git
echo ""

# Check Python packages
echo "[2/5] Checking Python Packages..."
if command -v pip3 &> /dev/null; then
    PACKAGES=("flask" "scikit-learn" "streamlit" "prometheus-client" "pytest")
    for pkg in "${PACKAGES[@]}"; do
        if pip3 show $pkg &> /dev/null; then
            echo "✅ $pkg is installed"
        else
            echo "❌ $pkg is NOT installed"
            ERRORS=$((ERRORS + 1))
        fi
    done
else
    echo "⚠️  Cannot check Python packages (pip3 not found)"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Check project structure
echo "[3/5] Checking Project Structure..."
check_file "requirements.txt"
check_file "docker-compose.yml"
check_file "Jenkinsfile"
check_file "install.sh"
check_file "run_demo.sh"
check_directory "app"
check_directory "docker"
check_directory "tests"
check_file "app/flask_app.py"
check_file "app/streamlit_app.py"
check_file "app/train_model.py"
check_file "app/monitoring.py"
echo ""

# Check models
echo "[4/5] Checking ML Models..."
if [ -f "app/models/model_v1.pkl" ]; then
    echo "✅ Model v1 exists"
else
    echo "⚠️  Model v1 not found (run: python3 app/train_model.py)"
    WARNINGS=$((WARNINGS + 1))
fi

if [ -f "app/models/model_v2.pkl" ]; then
    echo "✅ Model v2 exists"
else
    echo "⚠️  Model v2 not found (run: python3 app/train_model.py)"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# Check Docker
echo "[5/5] Checking Docker Status..."
if command -v docker &> /dev/null; then
    if docker ps &> /dev/null; then
        echo "✅ Docker daemon is running"
        
        # Check if services are running
        if docker-compose ps 2>/dev/null | grep -q "Up"; then
            echo "✅ Docker Compose services are running"
            docker-compose ps
        else
            echo "⚠️  Docker Compose services are not running"
            echo "   Run: ./run_demo.sh"
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        echo "⚠️  Docker daemon is not running or permission denied"
        echo "   Try: sudo systemctl start docker"
        echo "   Or add user to docker group: sudo usermod -aG docker $USER"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "❌ Docker is not installed"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Summary
echo "=========================================="
echo "Verification Summary"
echo "=========================================="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ Everything looks good! You're ready to go."
    echo ""
    echo "Next steps:"
    echo "  1. Train models: python3 app/train_model.py"
    echo "  2. Start services: ./run_demo.sh"
    echo "  3. Access UI: http://localhost:8501"
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  Setup is mostly complete with some warnings."
    echo "   Review the warnings above and fix if needed."
else
    echo "❌ Setup is incomplete. Please fix the errors above."
    echo "   Run: ./install.sh"
fi
echo ""
