#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <output_cfg_path>"
  exit 1
fi

output_cfg="$1"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
template_path="${repo_root}/database/haproxy/haproxy.cfg.tmpl"

if [ ! -f "$template_path" ]; then
  echo "Template not found: ${template_path}"
  exit 1
fi

db_backends="${DB_BACKENDS:-127.0.0.1:5432}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${script_dir}/validate-db-backends.sh" "${db_backends}"

server_lines=""
idx=1
IFS=',' read -ra backends <<< "$db_backends"
for backend in "${backends[@]}"; do
  backend_trimmed="$(echo "$backend" | xargs)"

  server_lines="${server_lines}  server pg${idx} ${backend_trimmed} check"$'\n'
  idx=$((idx + 1))
done

mkdir -p "$(dirname "$output_cfg")"
awk -v servers="$server_lines" '
  { gsub(/__BACKEND_SERVERS__/, servers); print }
' "$template_path" > "$output_cfg"

echo "Rendered HAProxy config: ${output_cfg}"
echo "Backends: ${db_backends}"
