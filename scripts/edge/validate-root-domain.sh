#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <root_domain>"
  exit 1
fi

root_domain="$1"

if [ -z "$root_domain" ]; then
  echo "ROOT_DOMAIN is empty"
  exit 1
fi

if [[ "$root_domain" == http://* || "$root_domain" == https://* ]]; then
  echo "ROOT_DOMAIN must be a host only, without scheme: ${root_domain}"
  exit 1
fi

if [[ "$root_domain" == *"/"* ]]; then
  echo "ROOT_DOMAIN must not contain path segments: ${root_domain}"
  exit 1
fi

if [[ "$root_domain" == \** ]]; then
  echo "ROOT_DOMAIN must be apex/base domain, not wildcard: ${root_domain}"
  exit 1
fi

if ! [[ "$root_domain" =~ ^[A-Za-z0-9.-]+$ ]]; then
  echo "ROOT_DOMAIN contains invalid characters: ${root_domain}"
  exit 1
fi
