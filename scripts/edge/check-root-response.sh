#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <root_domain>"
  exit 1
fi

root_domain="$1"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${script_dir}/validate-root-domain.sh" "$root_domain"

last_status=""
last_body=""
for _ in $(seq 1 15); do
  response_file="$(mktemp)"
  status_code="$(curl --silent --show-error -k \
    --output "${response_file}" \
    --write-out '%{http_code}' \
    --resolve "${root_domain}:443:127.0.0.1" \
    "https://${root_domain}/")"
  body="$(tr -d '\r\n' < "${response_file}")"
  rm -f "${response_file}"

  if [ "${status_code}" = "200" ] && [ "${body}" = "true" ]; then
    exit 0
  fi

  last_status="${status_code}"
  last_body="${body}"
  sleep 2
done

echo "Unexpected root response after retries. status=${last_status} body='${last_body}' domain=${root_domain}"
exit 1
