#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -gt 2 ]; then
  echo "Usage: $0 [db_backends] [health_mode]"
  exit 1
fi

db_backends="${1:-${DB_BACKENDS:-}}"
health_mode="${2:-${HAPROXY_HEALTH_MODE:-tcp}}"
if [ -z "${db_backends}" ]; then
  echo "DB_BACKENDS is empty"
  exit 1
fi

case "${health_mode}" in
  tcp|patroni-api) ;;
  *)
    echo "Unsupported HAPROXY_HEALTH_MODE: ${health_mode}"
    echo "Supported modes: tcp, patroni-api"
    exit 1
    ;;
esac

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
