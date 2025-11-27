#!/bin/bash
# =============================================
# AlgoArena Backend Setup Script for DigitalOcean VPS
# Run this script on your VPS after uploading files
# =============================================

echo "🚀 AlgoArena Backend Setup Starting..."

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install Node.js 20.x if not installed
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
else
    echo "✅ Node.js already installed: $(node --version)"
fi

# Install PM2 globally
echo "📦 Installing PM2..."
npm install -g pm2

# Create app directory
echo "📁 Creating app directory..."
mkdir -p /var/www/algoarena-backend

# If we're running from the uploaded backend folder
if [ -f "server.js" ]; then
    echo "📁 Copying files to /var/www/algoarena-backend..."
    cp -r ./* /var/www/algoarena-backend/
fi

cd /var/www/algoarena-backend

# Install dependencies
echo "📦 Installing Node.js dependencies..."
npm install --production

# Configure firewall
echo "🔥 Configuring firewall..."
ufw allow 5000
ufw allow 22
ufw allow 80
ufw allow 443
echo "y" | ufw enable

# Stop any existing PM2 process
pm2 delete algoarena-api 2>/dev/null || true

# Start the server with PM2
echo "🚀 Starting server with PM2..."
pm2 start server.js --name "algoarena-api"

# Save PM2 process list
pm2 save

# Setup PM2 to start on boot
pm2 startup systemd -u root --hp /root

echo ""
echo "============================================="
echo "✅ AlgoArena Backend Setup Complete!"
echo "============================================="
echo ""
echo "🌐 Your API is now running at:"
echo "   http://152.42.240.220:5000/api"
echo ""
echo "📋 Test endpoints:"
echo "   Health: http://152.42.240.220:5000/api/health"
echo "   Leo:    http://152.42.240.220:5000/api/leo/ask"
echo ""
echo "📝 Useful PM2 commands:"
echo "   pm2 status          - Check status"
echo "   pm2 logs            - View logs"
echo "   pm2 restart all     - Restart server"
echo ""
