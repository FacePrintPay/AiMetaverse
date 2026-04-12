#!/data/data/com.termux/files/usr/bin/bash

# PaTHos API - Termux Setup Script
# This script sets up the environment for running PaTHos API on Termux

echo "=================================="
echo "PaTHos API - Termux Setup"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Update package lists
print_status "Updating package lists..."
pkg update -y || {
    print_error "Failed to update packages"
    exit 1
}

# Install system dependencies
print_status "Installing system dependencies..."
pkg install -y \
    python \
    python-pip \
    openssl \
    libcrypt \
    libffi \
    build-essential \
    git || {
    print_error "Failed to install system packages"
    exit 1
}

# Upgrade pip, setuptools, and wheel
print_status "Upgrading pip, setuptools, and wheel..."
pip install --upgrade pip setuptools wheel || {
    print_warning "Failed to upgrade pip tools (this might be okay)"
}

# Install Python dependencies
print_status "Installing Python dependencies..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt || {
        print_error "Failed to install Python requirements"
        exit 1
    }
else
    print_warning "requirements.txt not found, installing basic packages..."
    pip install flask pyyaml requests || {
        print_error "Failed to install basic packages"
        exit 1
    }
fi

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p logs
mkdir -p data
mkdir -p tmp

# Set permissions
chmod +x PaTHos_API.py 2>/dev/null || true

echo ""
print_status "Setup complete!"
echo ""
echo "To start the server, run:"
echo "  ./start.sh"
echo ""
echo "Or manually with:"
echo "  python PaTHos_API.py"
echo ""
