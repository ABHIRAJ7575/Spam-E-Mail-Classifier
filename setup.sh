#!/bin/bash

# Spam Email Classifier Setup Script
# This script sets up the development environment

set -e

echo "🔧 Setting up Spam Email Classifier Development Environment"
echo "==========================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
}

# Check Python version
check_python() {
    print_status "Checking Python version..."
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed. Please install Python 3.8+ first."
        exit 1
    fi

    python_version=$(python3 --version | cut -d' ' -f2)
    print_success "Python version: $python_version"
}

# Check Node.js version
check_nodejs() {
    print_status "Checking Node.js version..."
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js 18+ first."
        exit 1
    fi

    node_version=$(node --version)
    print_success "Node.js version: $node_version"
}

# Setup backend
setup_backend() {
    print_status "Setting up backend..."

    cd backend

    # Create virtual environment
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        print_success "Virtual environment created"
    fi

    # Activate virtual environment and install dependencies
    source venv/bin/activate
    pip install -r requirements.txt
    print_success "Backend dependencies installed"

    cd ..
}

# Setup frontend
setup_frontend() {
    print_status "Setting up frontend..."

    cd frontend

    # Install dependencies
    npm install
    print_success "Frontend dependencies installed"

    cd ..
}

# Setup ML models
setup_ml() {
    print_status "Setting up ML models..."

    cd ml-models

    # Train the model
    python3 train_model.py
    print_success "ML model trained"

    cd ..
}

# Check Tesseract OCR
check_tesseract() {
    print_status "Checking Tesseract OCR..."

    if ! command -v tesseract &> /dev/null; then
        print_warning "Tesseract OCR is not installed."
        echo "Please install Tesseract OCR:"
        echo "  - Ubuntu/Debian: sudo apt-get install tesseract-ocr"
        echo "  - macOS: brew install tesseract"
        echo "  - Windows: Download from https://github.com/UB-Mannheim/tesseract/wiki"
        echo ""
        print_warning "OCR functionality will not work without Tesseract."
    else
        tesseract_version=$(tesseract --version | head -n1)
        print_success "Tesseract version: $tesseract_version"
    fi
}

# Create necessary directories
create_directories() {
    print_status "Creating necessary directories..."

    mkdir -p logs
    mkdir -p ssl
    print_success "Directories created"
}

# Main setup process
main() {
    check_python
    check_nodejs
    check_tesseract
    create_directories
    setup_backend
    setup_frontend
    setup_ml

    print_success "🎉 Setup completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "1. Start the backend: cd backend && source venv/bin/activate && python run.py"
    echo "2. Start the frontend: cd frontend && npm run dev"
    echo "3. Open http://localhost:3000 in your browser"
    echo ""
    print_status "Or run the integration test:"
    echo "python integration_test.py"
    echo ""
    print_status "For production deployment:"
    echo "./deploy.sh"
}

# Run main setup
main
