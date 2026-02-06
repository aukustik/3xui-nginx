#!/bin/bash
# Initial certificate request for Let's Encrypt

set -e

# Load .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

DOMAIN=${CERTBOT_DOMAIN:-example.com}
EMAIL=${CERTBOT_EMAIL:-admin@example.com}

echo "Requesting certificate for domain: $DOMAIN"
echo "Make sure nginx is running and serving ACME challenges on port 80"

docker compose run --rm --entrypoint "certbot" -p 80:80 certbot certonly \
    --webroot \
    --webroot-path /var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN

echo "Certificate obtained successfully!"
echo "Now update your nginx config to use SSL and restart:"
echo "docker compose restart nginx"
