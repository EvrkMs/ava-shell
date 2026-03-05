#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <compose_file>"
  exit 1
fi

compose_file="$1"
docker compose -f "$compose_file" ps
running_count="$(docker compose -f "$compose_file" ps --status running --services | wc -l)"

if [ "$running_count" -lt 1 ]; then
  echo "Edge stack is not running."
  exit 1
fi
