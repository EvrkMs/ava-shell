#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <compose_file>"
  exit 1
fi

compose_file="$1"

if docker compose -f "$compose_file" up -d; then
  echo "Soft deploy succeeded."
else
  echo "Soft deploy failed. Fallback to conflict recovery + force recreate."
  docker compose -f "$compose_file" down --remove-orphans || true
  docker rm -f ava-shell-edge ava-shell-root-echo || true
  docker compose -f "$compose_file" up -d --force-recreate
fi

docker compose -f "$compose_file" ps
