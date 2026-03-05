#!/usr/bin/env bash
set -euo pipefail

for required in ROOT_DOMAIN LETSENCRYPT_EMAIL CF_DNS_API_TOKEN; do
  if [ -z "${!required:-}" ]; then
    echo "Missing required environment variable: ${required}"
    exit 1
  fi
done

mkdir -p traefik/dynamic
rm -f traefik/dynamic/routes.generated.yml
