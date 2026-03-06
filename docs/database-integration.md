# Интеграция с внешней DB-экосистемой

`ava-shell` использует внешний PostgreSQL-контур (в том числе возможный Patroni-кластер), но не хранит его runtime-конфиги в этом репозитории.

В репозитории остаётся только прокси-вход через `HAProxy`.

## Правило подключения сервисов

- подключение только через `db-rw.internal:5432`;
- прямое подключение к нодам PostgreSQL запрещено;
- логика топологии БД скрыта за прокси.

## Что хранится в этом репозитории

- `database/docker-compose.yml` (только HAProxy);
- `database/haproxy/haproxy.cfg.tmpl`;
- `scripts/db/render-haproxy-cfg.sh`.

## Что хранится вне репозитория

- PostgreSQL-ноды;
- Patroni/etcd/consul;
- backup/PITR пайплайны и мониторинг БД.
