#!/bin/bash
# Initial certificate request using acme.sh

set -e

# Load .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

DOMAIN=${ACME_DOMAIN:-example.com}
EMAIL=${ACME_EMAIL:-admin@example.com}
ACME_SERVER=${ACME_SERVER:-letsencrypt}

# Paths
CERTS_DIR=${SSL_CERTS_PATH:-./certs}
ACME_HOME="$CERTS_DIR/acme.sh"
WEBROOT="$CERTS_DIR/webroot"

echo "Requesting certificate for domain: $DOMAIN"
echo "Server: $ACME_SERVER"

# Create directories
mkdir -p "$CERTS_DIR" "$WEBROOT"

# Install acme.sh if not present
if [ ! -f "$ACME_HOME/acme.sh" ]; then
    echo "Installing acme.sh..."
    curl https://get.acme.sh | sh -s email=$EMAIL --force
    # Copy installed acme.sh to our directory
    if [ -f ~/.acme.sh/acme.sh ]; then
        cp -r ~/.acme.sh "$ACME_HOME"
    fi
fi

# Request certificate
"$ACME_HOME/acme.sh" --issue \
    -d $DOMAIN \
    --webroot $WEBROOT \
    --server $ACME_SERVER \
    --accountemail $EMAIL \
    --home "$ACME_HOME"

# Create symlinks for nginx (fullchain.pem, privkey.pem)
mkdir -p "$CERTS_DIR/live/$DOMAIN"
ln -sf "$ACME_HOME/$DOMAIN/fullchain.cer" "$CERTS_DIR/live/$DOMAIN/fullchain.pem"
ln -sf "$ACME_HOME/$DOMAIN/$DOMAIN.key" "$CERTS_DIR/live/$DOMAIN/privkey.pem"

echo "Certificate obtained successfully!"
echo "Now update your nginx config to use SSL and restart:"
echo "docker compose restart nginx"
