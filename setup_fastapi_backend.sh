#!/bin/bash

# FastAPI Backend Automation Script - Simple & Reliable
# This script automates the setup and launch of the FastAPI backend

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

echo "🚀 FastAPI Backend Automation Script"
echo "====================================="

# Step 1: Ensure python3 and python3-venv are installed
print_status "Step 1: Checking Python 3 and python3-venv installation..."
if ! command -v python3 &> /dev/null; then
    print_error "python3 is not installed. Please install python3 first."
fi

python3_version=$(python3 --version)
print_success "Python 3 is available: $python3_version"

if ! python3 -m venv --help &> /dev/null; then
    print_error "python3-venv is not available. Please install python3-venv package."
fi
print_success "python3-venv is available"

# Navigate to project root (current directory should be the project root)
PROJECT_ROOT=$(pwd)
BACKEND_DIR="$PROJECT_ROOT/backend"

if [ ! -d "$BACKEND_DIR" ]; then
    print_error "Backend directory not found at $BACKEND_DIR"
fi

cd "$BACKEND_DIR"
print_success "Changed to backend directory: $BACKEND_DIR"

# Step 2: Create virtual environment if it doesn't exist and activate it
print_status "Step 2: Setting up virtual environment..."
VENV_DIR="$BACKEND_DIR/.venv"

if [ ! -d "$VENV_DIR" ]; then
    print_status "Creating virtual environment..."
    python3 -m venv .venv
    print_success "Virtual environment created"
else
    print_success "Virtual environment already exists"
fi

# Step 3: Skip pip upgrade to avoid network issues
print_status "Step 3: Using existing pip, wheel, and setuptools..."
print_success "Skipping pip upgrade for reliability"

# Step 4: Remove docker-compose from requirements.txt
print_status "Step 4: Checking and removing docker-compose from requirements.txt..."
if [ -f "requirements.txt" ]; then
    if grep -q "docker-compose" requirements.txt; then
        print_status "Removing docker-compose from requirements.txt..."
        sed -i '/docker-compose/d' requirements.txt
        print_success "docker-compose removed from requirements.txt"
    else
        print_success "No docker-compose found in requirements.txt"
    fi
else
    print_warning "requirements.txt not found"
fi

# Step 5: Ensure PyYAML>=6.0 is in requirements.txt
print_status "Step 5: Ensuring PyYAML>=6.0 is in requirements.txt..."
if [ -f "requirements.txt" ]; then
    if ! grep -q "PyYAML" requirements.txt; then
        print_status "Adding PyYAML>=6.0 to requirements.txt..."
        echo "PyYAML>=6.0" >> requirements.txt
        print_success "PyYAML>=6.0 added to requirements.txt"
    else
        print_success "PyYAML already present in requirements.txt"
    fi
fi

# Step 6: Check if FastAPI dependencies are already installed
print_status "Step 6: Checking FastAPI dependencies..."
if .venv/bin/python -c "import fastapi, uvicorn" 2>/dev/null; then
    print_success "FastAPI and uvicorn are already installed and working"
else
    print_error "FastAPI dependencies not found or not working. Please run: .venv/bin/pip install fastapi uvicorn"
fi

# Step 7: Load environment variables from .env if it exists
print_status "Step 7: Checking for .env file..."
if [ -f ".env" ]; then
    print_status "Loading environment variables from .env file..."
    set -a  # Enable automatic export of variables
    source .env
    set +a  # Disable automatic export
    print_success "Environment variables loaded from .env"
else
    print_warning "No .env file found, skipping environment variable loading"
fi

# Step 8: Run alembic migrations if alembic.ini exists
print_status "Step 8: Checking for database migrations..."
if [ -f "alembic.ini" ] && .venv/bin/python -c "import alembic" 2>/dev/null; then
    print_status "Running alembic migrations..."
    if .venv/bin/alembic upgrade head 2>/dev/null; then
        print_success "Database migrations completed"
    else
        print_warning "Database migrations failed or not configured, continuing without them"
    fi
else
    print_warning "No alembic.ini found or alembic not available, skipping database migrations"
fi

# Step 9: Determine the correct FastAPI app entrypoint
print_status "Step 9: Determining FastAPI app entrypoint..."
APP_MODULE="app.main:app"

# Check if the app module exists
if [ -f "app/main.py" ]; then
    if .venv/bin/python -c "from app.main import app" 2>/dev/null; then
        print_success "FastAPI app found at app.main:app"
    else
        print_error "Could not import FastAPI app from app.main:app"
    fi
elif [ -f "main.py" ]; then
    APP_MODULE="main:app"
    if .venv/bin/python -c "from main import app" 2>/dev/null; then
        print_success "FastAPI app found at main:app"
    else
        print_error "Could not import FastAPI app from main:app"
    fi
else
    print_error "Could not find FastAPI app. Checked app/main.py and main.py"
fi

# Step 10: Launch FastAPI app with uvicorn
print_status "Step 10: Launching FastAPI app..."
echo ""
echo "🎉 =============================================="
echo "   ✅ FastAPI Backend Setup Complete!"
echo "=============================================="
echo ""
print_success "🚀 Starting FastAPI server with uvicorn..."
print_status "📦 App module: $APP_MODULE"
print_status "🌐 Host: 0.0.0.0"
print_status "🔌 Port: 8000"
echo ""
echo "📍 Access URLs:"
print_success "   🌍 API Base: http://localhost:8000"
print_success "   📚 API Docs: http://localhost:8000/docs"
print_success "   ❤️  Health: http://localhost:8000/health"
echo ""
print_warning "⚠️  Press Ctrl+C to stop the server"
echo ""

# Activate virtual environment and launch the FastAPI app
source .venv/bin/activate
uvicorn "$APP_MODULE" --host 0.0.0.0 --port 8000