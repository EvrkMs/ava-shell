#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <template_file> <output_file> <root_domain>"
  exit 1
fi

template_file="$1"
output_file="$2"
root_domain="$3"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${script_dir}/validate-root-domain.sh" "$root_domain"

mkdir -p "$(dirname "$output_file")"
sed "s/__ROOT_DOMAIN__/${root_domain}/g" "$template_file" > "$output_file"
