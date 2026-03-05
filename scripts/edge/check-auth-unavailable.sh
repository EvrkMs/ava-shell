#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <root_domain>"
  exit 1
fi

root_domain="$1"
status_code="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' -k \
  --resolve "auth.${root_domain}:443:127.0.0.1" \
  "https://auth.${root_domain}/")"

case "$status_code" in
  502|503)
    echo "Expected backend failure status: ${status_code}"
    ;;
  *)
    echo "Expected 502/503 for unavailable auth backend, got ${status_code}"
    exit 1
    ;;
esac
