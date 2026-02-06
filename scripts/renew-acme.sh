#!/bin/bash
# Renew certificates using acme.sh

set -e

# Load .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

DOMAIN=${ACME_DOMAIN:-example.com}
CERTS_DIR=${SSL_CERTS_PATH:-./certs}
ACME_HOME="$CERTS_DIR/acme.sh"

echo "Renewing certificate for domain: $DOMAIN"

# Renew certificate
"$ACME_HOME/acme.sh" --renew -d $DOMAIN --force

# Update symlinks
mkdir -p "$CERTS_DIR/live/$DOMAIN"
ln -sf "$ACME_HOME/$DOMAIN/fullchain.cer" "$CERTS_DIR/live/$DOMAIN/fullchain.pem"
ln -sf "$ACME_HOME/$DOMAIN/$DOMAIN.key" "$CERTS_DIR/live/$DOMAIN/privkey.pem"

echo "Certificate renewed successfully!"
echo "Reloading nginx..."
docker compose exec nginx nginx -s reload
