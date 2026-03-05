#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <root_domain>"
  exit 1
fi

root_domain="$1"
body="$(curl --silent --show-error --fail -k \
  --resolve "${root_domain}:443:127.0.0.1" \
  "https://${root_domain}/" | tr -d '\r\n')"

if [ "$body" != "true" ]; then
  echo "Expected root response 'true', got: ${body}"
  exit 1
fi
