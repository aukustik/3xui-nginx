#!/bin/bash
set -e

echo "=== 3X-UI + Nginx Deployment Script ==="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    apt-get update
    apt-get install -y ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

# Check .env file
if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    echo "Please copy .env.example to .env and configure it"
    exit 1
fi

# Load environment variables
source .env

# Check SSL certificates
if [ ! -f "$SSL_CERTS_PATH/fullchain.pem" ] || [ ! -f "$SSL_CERTS_PATH/privkey.pem" ]; then
    echo "Error: SSL certificates not found at $SSL_CERTS_PATH"
    echo "Please ensure fullchain.pem and privkey.pem exist"
    exit 1
fi

# Create data directory
mkdir -p data

# Pull images
echo "Pulling Docker images..."
docker compose pull

# Start services
echo "Starting services..."
docker compose up -d

# Wait for services to start
echo "Waiting for services to start..."
sleep 5

# Check status
docker compose ps

echo ""
echo "=== Deployment Complete ==="
echo "WebUI: https://$DOMAIN:8080"
echo "Default credentials: admin / admin"
echo ""
echo "Check logs: docker compose logs -f"
