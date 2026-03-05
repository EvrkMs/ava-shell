#!/usr/bin/env bash
set -euo pipefail

volume_name="${1:-ava_shell_traefik_acme}"

docker volume create "$volume_name" >/dev/null
docker run --rm -v "${volume_name}:/acme" alpine:3.20 \
  sh -c "touch /acme/acme.json && chmod 600 /acme/acme.json"
