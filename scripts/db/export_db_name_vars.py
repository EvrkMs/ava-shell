#!/usr/bin/env python3
import json
import os

payload = os.environ.get("GITHUB_VARS_JSON", "{}")
db_names = os.environ.get("DB_NAMES", "")
github_env = os.environ.get("GITHUB_ENV", "")

if not db_names:
    raise SystemExit("DB_NAMES is empty")

if not github_env:
    raise SystemExit("GITHUB_ENV is not set")

variables = json.loads(payload)
keys = [item.strip() for item in db_names.split(",") if item.strip()]

with open(github_env, "a", encoding="utf-8") as handle:
    for key in keys:
      var_name = f"DB_NAME_{key}"
      value = variables.get(var_name, "")
      if not value:
          raise SystemExit(f"Missing GitHub variable: {var_name}")
      handle.write(f"{var_name}={value}\n")
