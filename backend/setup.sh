#!/bin/bash

# AlgoArena Backend Setup Script for Ubuntu/Debian
# This script will install MongoDB and set up the backend

set -e  # Exit on error

echo "========================================="
echo "AlgoArena Backend Setup"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${RED}This script is for Linux systems only.${NC}"
    echo "For other systems, please see MONGODB_INSTALLATION.md"
    exit 1
fi

# Check if script is run from backend directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: Please run this script from the backend directory${NC}"
    exit 1
fi

# Function to check if MongoDB is installed
check_mongodb() {
    if command -v mongod &> /dev/null; then
        echo -e "${GREEN}✓ MongoDB is already installed${NC}"
        return 0
    else
        echo -e "${YELLOW}MongoDB is not installed${NC}"
        return 1
    fi
}

# Function to install MongoDB
install_mongodb() {
    echo -e "${YELLOW}Installing MongoDB...${NC}"
    
    # Import MongoDB public key
    echo "Importing MongoDB GPG key..."
    curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
        sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
    
    # Add MongoDB repository
    echo "Adding MongoDB repository..."
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
        sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    
    # Update package list
    echo "Updating package list..."
    sudo apt-get update
    
    # Install MongoDB
    echo "Installing MongoDB packages..."
    sudo apt-get install -y mongodb-org
    
    # Start and enable MongoDB service
    echo "Starting MongoDB service..."
    sudo systemctl start mongod
    sudo systemctl enable mongod
    
    echo -e "${GREEN}✓ MongoDB installed and started successfully${NC}"
}

# Function to start MongoDB
start_mongodb() {
    echo "Starting MongoDB service..."
    sudo systemctl start mongod
    
    # Wait for MongoDB to start
    sleep 2
    
    if sudo systemctl is-active --quiet mongod; then
        echo -e "${GREEN}✓ MongoDB is running${NC}"
    else
        echo -e "${RED}✗ Failed to start MongoDB${NC}"
        echo "Please check the logs: sudo journalctl -u mongod"
        exit 1
    fi
}

# Main setup process
echo "Step 1: Checking MongoDB installation..."
if ! check_mongodb; then
    echo ""
    echo "MongoDB needs to be installed. This requires sudo privileges."
    read -p "Do you want to install MongoDB now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_mongodb
    else
        echo -e "${YELLOW}MongoDB installation skipped.${NC}"
        echo "Please install MongoDB manually and run this script again."
        echo "See MONGODB_INSTALLATION.md for instructions."
        exit 1
    fi
fi

echo ""
echo "Step 2: Checking MongoDB service status..."
if ! sudo systemctl is-active --quiet mongod && ! sudo systemctl is-active --quiet mongodb; then
    start_mongodb
else
    echo -e "${GREEN}✓ MongoDB service is already running${NC}"
fi

echo ""
echo "Step 3: Testing MongoDB connection..."
if mongosh --eval "db.version()" > /dev/null 2>&1 || mongo --eval "db.version()" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ MongoDB connection successful${NC}"
else
    echo -e "${RED}✗ Cannot connect to MongoDB${NC}"
    echo "MongoDB may still be starting up. Please wait a moment and try again."
fi

echo ""
echo "Step 4: Checking .env file..."
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}.env file not found. Creating from template...${NC}"
    cat > .env << 'EOF'
# MongoDB Connection
MONGODB_URI=mongodb://localhost:27017/algoarena

# JWT Configuration
JWT_SECRET=algoarena-super-secret-jwt-key-2024-change-in-production
JWT_EXPIRE=30d

# Server Configuration
PORT=5000
NODE_ENV=development
EOF
    echo -e "${GREEN}✓ .env file created${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

echo ""
echo "Step 5: Installing npm dependencies..."
if npm install; then
    echo -e "${GREEN}✓ npm packages installed${NC}"
else
    echo -e "${RED}✗ npm install failed${NC}"
    exit 1
fi

echo ""
echo "========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Start the backend server:"
echo -e "   ${YELLOW}npm run dev${NC}"
echo ""
echo "2. (Optional) Seed sample data:"
echo -e "   ${YELLOW}npm run seed${NC}"
echo ""
echo "3. Start your Flutter app in Android Studio"
echo ""
echo "The backend will be available at: http://localhost:5000"
echo "Android emulator will connect to: http://10.0.2.2:5000"
echo ""
