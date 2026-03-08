#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <output_ini_path> <output_userlist_path>"
  exit 1
fi

output_ini="$1"
output_userlist="$2"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
template_path="${repo_root}/database/pgbouncer/pgbouncer.ini.tmpl"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "${template_path}" ]; then
  echo "Template not found: ${template_path}"
  exit 1
fi

bash "${script_dir}/validate-pgbouncer-env.sh"

db_names="${DB_NAMES}"
auth_user="${PGBOUNCER_AUTH_USER}"
auth_password="${PGBOUNCER_AUTH_PASSWORD}"
auth_dbname="${PGBOUNCER_AUTH_DBNAME}"
auth_query="${PGBOUNCER_AUTH_QUERY:-SELECT usename, passwd FROM pg_shadow WHERE usename = \$1}"

database_mappings=""
IFS=',' read -ra db_keys <<< "${db_names}"
for raw_key in "${db_keys[@]}"; do
  db_key="$(echo "${raw_key}" | xargs)"
  db_name_var="DB_NAME_${db_key}"
  db_name="${!db_name_var}"
  database_mappings="${database_mappings}${db_name} = host=db-proxy port=15432 dbname=${db_name}"$'\n'
done

md5_hash="$(printf '%s' "${auth_password}${auth_user}" | md5sum | awk '{print $1}')"

mkdir -p "$(dirname "${output_ini}")"
mkdir -p "$(dirname "${output_userlist}")"

awk \
  -v database_mappings="${database_mappings%$'\n'}" \
  -v auth_user="${auth_user}" \
  -v auth_dbname="${auth_dbname}" \
  -v auth_query="${auth_query}" '
    {
      gsub(/__DATABASE_MAPPINGS__/, database_mappings);
      gsub(/__PGBOUNCER_AUTH_USER__/, auth_user);
      gsub(/__PGBOUNCER_AUTH_DBNAME__/, auth_dbname);
      gsub(/__PGBOUNCER_AUTH_QUERY__/, auth_query);
      print;
    }
  ' "${template_path}" > "${output_ini}"

printf '"%s" "md5%s"\n' "${auth_user}" "${md5_hash}" > "${output_userlist}"

echo "Rendered PgBouncer config: ${output_ini}"
echo "Rendered PgBouncer userlist: ${output_userlist}"
echo "Databases: ${db_names}"
