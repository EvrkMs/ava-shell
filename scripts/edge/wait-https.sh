#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 <root_domain> [attempts]"
  exit 1
fi

root_domain="$1"
attempts="${2:-30}"

for _ in $(seq 1 "$attempts"); do
  if curl --silent --show-error -k \
    --resolve "${root_domain}:443:127.0.0.1" \
    "https://${root_domain}/" >/dev/null 2>&1; then
    exit 0
  fi
  sleep 2
done

echo "HTTPS endpoint did not become ready in time: ${root_domain}"
exit 1
