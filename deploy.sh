#!/bin/bash

# Spam Email Classifier Deployment Script
# This script handles the complete deployment process

set -e

echo "🚀 Starting Spam Email Classifier Deployment"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if Docker is installed
check_docker() {
    print_status "Checking Docker installation..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi

    print_success "Docker and Docker Compose are installed"
}

# Check if required files exist
check_files() {
    print_status "Checking required files..."

    required_files=(
        "backend/requirements.txt"
        "frontend/package.json"
        "docker-compose.yml"
        "backend/Dockerfile"
        "frontend/Dockerfile"
    )

    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "Required file missing: $file"
            exit 1
        fi
    done

    print_success "All required files are present"
}

# Train ML model if not exists
setup_ml_model() {
    print_status "Checking ML model..."

    if [ ! -f "ml-models/spam_classifier.pkl" ] || [ ! -f "ml-models/vectorizer.pkl" ]; then
        print_warning "ML model not found. Training new model..."
        cd ml-models
        python train_model.py
        cd ..
        print_success "ML model trained successfully"
    else
        print_success "ML model already exists"
    fi
}

# Build and start services
deploy_services() {
    print_status "Building and starting services..."

    # Stop any existing containers
    docker-compose down

    # Build and start services
    docker-compose up -d --build

    print_success "Services are building and starting..."
}

# Wait for services to be ready
wait_for_services() {
    print_status "Waiting for services to be ready..."

    # Wait for backend
    max_attempts=30
    attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:8000/health > /dev/null; then
            print_success "Backend is ready"
            break
        fi

        print_status "Waiting for backend... (attempt $attempt/$max_attempts)"
        sleep 5
        attempt=$((attempt + 1))
    done

    if [ $attempt -gt $max_attempts ]; then
        print_error "Backend failed to start"
        exit 1
    fi

    # Wait for frontend
    attempt=1
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:3000 > /dev/null; then
            print_success "Frontend is ready"
            break
        fi

        print_status "Waiting for frontend... (attempt $attempt/$max_attempts)"
        sleep 5
        attempt=$((attempt + 1))
    done

    if [ $attempt -gt $max_attempts ]; then
        print_error "Frontend failed to start"
        exit 1
    fi
}

# Run integration tests
run_tests() {
    print_status "Running integration tests..."

    if python integration_test.py; then
        print_success "Integration tests passed"
    else
        print_error "Integration tests failed"
        exit 1
    fi
}

# Display deployment information
show_deployment_info() {
    print_success "Deployment completed successfully!"
    echo ""
    echo "🌐 Application URLs:"
    echo "   Frontend:    http://localhost:3000"
    echo "   Backend:     http://localhost:8000"
    echo "   API Docs:    http://localhost:8000/docs"
    echo "   Health:      http://localhost:8000/health"
    echo ""
    echo "📊 Services Status:"
    docker-compose ps
    echo ""
    echo "🔧 Useful Commands:"
    echo "   View logs:      docker-compose logs -f"
    echo "   Stop services:  docker-compose down"
    echo "   Restart:        docker-compose restart"
    echo "   Update:         docker-compose up -d --build"
}

# Main deployment process
main() {
    echo "🔧 Spam Email Classifier Deployment Script"
    echo "=========================================="

    check_docker
    check_files
    setup_ml_model
    deploy_services
    wait_for_services
    run_tests
    show_deployment_info

    print_success "🎉 Deployment completed! Your spam email classifier is now running."
    echo ""
    print_status "Next steps:"
    echo "1. Open http://localhost:3000 in your browser"
    echo "2. Try classifying some emails"
    echo "3. Test OCR with email images"
    echo "4. Use the AI comparison feature"
}

# Handle command line arguments
case "${1:-}" in
    "stop")
        print_status "Stopping services..."
        docker-compose down
        print_success "Services stopped"
        ;;
    "restart")
        print_status "Restarting services..."
        docker-compose restart
        print_success "Services restarted"
        ;;
    "logs")
        print_status "Showing service logs..."
        docker-compose logs -f
        ;;
    "test")
        run_tests
        ;;
    "status")
        print_status "Service status:"
        docker-compose ps
        ;;
    *)
        main
        ;;
esac
