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
health_mode="${HAPROXY_HEALTH_MODE:-tcp}"
patroni_api_port="${PATRONI_API_PORT:-8008}"
patroni_check_path="${PATRONI_CHECK_PATH:-/primary}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${script_dir}/validate-db-backends.sh" "${db_backends}" "${health_mode}"

if ! [[ "${patroni_api_port}" =~ ^[0-9]{1,5}$ ]]; then
  echo "Invalid PATRONI_API_PORT: ${patroni_api_port}"
  exit 1
fi

if ! [[ "${patroni_check_path}" == /* ]]; then
  echo "PATRONI_CHECK_PATH must start with '/': ${patroni_check_path}"
  exit 1
fi

server_lines=""
idx=1
IFS=',' read -ra backends <<< "$db_backends"
for backend in "${backends[@]}"; do
  backend_trimmed="$(echo "$backend" | xargs)"
  if [ "${health_mode}" = "patroni-api" ]; then
    server_lines="${server_lines}  server pg${idx} ${backend_trimmed} check port ${patroni_api_port}"$'\n'
  else
    server_lines="${server_lines}  server pg${idx} ${backend_trimmed} check"$'\n'
  fi
  idx=$((idx + 1))
done

healthcheck_block="  option tcp-check"
if [ "${health_mode}" = "patroni-api" ]; then
  healthcheck_block="  option httpchk GET ${patroni_check_path}"$'\n'"  http-check expect status 200"
fi

mkdir -p "$(dirname "$output_cfg")"
awk -v servers="$server_lines" -v checks="$healthcheck_block" '
  { gsub(/__HEALTHCHECK_BLOCK__/, checks); gsub(/__BACKEND_SERVERS__/, servers); print }
' "$template_path" > "$output_cfg"

echo "Rendered HAProxy config: ${output_cfg}"
echo "Backends: ${db_backends}"
echo "Health mode: ${health_mode}"
