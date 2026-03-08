#!/usr/bin/env bash
set -euo pipefail

db_names="${DB_NAMES:-}"
auth_user="${PGBOUNCER_AUTH_USER:-}"
auth_password="${PGBOUNCER_AUTH_PASSWORD:-}"
auth_dbname="${PGBOUNCER_AUTH_DBNAME:-}"
auth_query="${PGBOUNCER_AUTH_QUERY:-SELECT usename, passwd FROM pg_shadow WHERE usename = \$1}"

if [ -z "${db_names}" ] || [ -z "${auth_user}" ] || [ -z "${auth_password}" ] || [ -z "${auth_dbname}" ]; then
  echo "DB_NAMES, PGBOUNCER_AUTH_USER, PGBOUNCER_AUTH_PASSWORD and PGBOUNCER_AUTH_DBNAME must be set"
  exit 1
fi

if ! [[ "${auth_user}" =~ ^[A-Za-z0-9_]+$ ]]; then
  echo "Invalid PGBOUNCER_AUTH_USER: ${auth_user}"
  exit 1
fi

if ! [[ "${auth_dbname}" =~ ^[A-Za-z0-9_]+$ ]]; then
  echo "Invalid PGBOUNCER_AUTH_DBNAME: ${auth_dbname}"
  exit 1
fi

if [ -z "${auth_query}" ]; then
  echo "PGBOUNCER_AUTH_QUERY must not be empty"
  exit 1
fi

IFS=',' read -ra db_keys <<< "${db_names}"
if [ "${#db_keys[@]}" -eq 0 ]; then
  echo "DB_NAMES has no entries"
  exit 1
fi

for raw_key in "${db_keys[@]}"; do
  db_key="$(echo "${raw_key}" | xargs)"
  if ! [[ "${db_key}" =~ ^[A-Za-z0-9_]+$ ]]; then
    echo "Invalid DB key in DB_NAMES: ${db_key}"
    exit 1
  fi

  var_name="DB_NAME_${db_key}"
  db_name="${!var_name:-}"
  if [ -z "${db_name}" ]; then
    echo "Missing variable: ${var_name}"
    exit 1
  fi

  if ! [[ "${db_name}" =~ ^[A-Za-z0-9_]+$ ]]; then
    echo "Invalid ${var_name}: ${db_name}"
    exit 1
  fi
done
