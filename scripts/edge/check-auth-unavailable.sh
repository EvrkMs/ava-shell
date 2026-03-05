#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <root_domain>"
  exit 1
fi

root_domain="$1"
last_status=""
for _ in $(seq 1 15); do
  status_code="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' -k \
    --resolve "auth.${root_domain}:443:127.0.0.1" \
    "https://auth.${root_domain}/")"

  case "$status_code" in
    502|503)
      echo "Expected backend failure status: ${status_code}"
      exit 0
      ;;
  esac

  last_status="${status_code}"
  sleep 2
done

echo "Expected 502/503 for unavailable auth backend, got ${last_status}"
exit 1
