#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <root_domain>"
  exit 1
fi

root_domain="$1"
location="$(curl --silent --show-error --output /dev/null --write-out '%{redirect_url}' \
  --resolve "${root_domain}:80:127.0.0.1" \
  "http://${root_domain}/")"

if [ "$location" != "https://${root_domain}/" ]; then
  echo "Expected redirect to https://${root_domain}/, got: ${location}"
  exit 1
fi
