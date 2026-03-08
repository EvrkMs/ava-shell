# Интеграция с внешней DB-экосистемой

`ava-shell` использует внешний PostgreSQL-контур (в том числе возможный Patroni-кластер), но не хранит его runtime-конфиги в этом репозитории.

В репозитории остаётся DB entrypoint:

- `PgBouncer` как точка входа приложений;
- `HAProxy` как выбор текущего `primary`.

## Правило подключения сервисов

- подключение только через `db-rw.internal:5432`;
- прямое подключение к нодам PostgreSQL запрещено;
- логика топологии БД скрыта за прокси.
- список доступных `dbname` задаётся в `PgBouncer`;
- реальные пользователи и роли проверяются через PostgreSQL `auth_query`.

## Что хранится в этом репозитории

- `database/docker-compose.yml` (`PgBouncer + HAProxy`);
- `database/haproxy/haproxy.cfg.tmpl`;
- `database/pgbouncer/pgbouncer.ini.tmpl`;
- `scripts/db/render-haproxy-cfg.sh`.
- `scripts/db/validate-db-backends.sh`.
- `scripts/db/render-pgbouncer-config.sh`.
- `scripts/db/validate-pgbouncer-env.sh`.
- `scripts/db/export_db_name_vars.py`.

## Что хранится вне репозитория

- PostgreSQL-ноды;
- Patroni/etcd/consul;
- backup/PITR пайплайны и мониторинг БД.
