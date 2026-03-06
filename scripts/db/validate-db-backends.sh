#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -gt 1 ]; then
  echo "Usage: $0 [db_backends]"
  exit 1
fi

db_backends="${1:-${DB_BACKENDS:-}}"
if [ -z "${db_backends}" ]; then
  echo "DB_BACKENDS is empty"
  exit 1
fi

IFS=',' read -ra backends <<< "${db_backends}"
if [ "${#backends[@]}" -eq 0 ]; then
  echo "DB_BACKENDS has no entries"
  exit 1
fi

for backend in "${backends[@]}"; do
  backend_trimmed="$(echo "$backend" | xargs)"
  if ! [[ "$backend_trimmed" =~ ^[A-Za-z0-9._-]+:[0-9]{1,5}$ ]]; then
    echo "Invalid backend entry: ${backend_trimmed}"
    echo "Expected format: host:port,host:port"
    exit 1
  fi
done
