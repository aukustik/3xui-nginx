#!/bin/bash
# Cron job for automatic certificate renewal

set -e

# Load .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

DOMAIN=${ACME_DOMAIN:-example.com}
CERTS_DIR=${SSL_CERTS_PATH:-./certs}
ACME_HOME="$CERTS_DIR/acme.sh"

# Renew only if needed (acme.sh handles this automatically)
"$ACME_HOME/acme.sh" --cron --home "$ACME_HOME"

# Reload nginx if certificates were updated
if [ $? -eq 0 ]; then
    docker compose exec nginx nginx -s reload 2>/dev/null || true
fi
