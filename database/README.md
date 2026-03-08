# DB Entry (PgBouncer + HAProxy)

`database/` содержит единый вход в внешнюю DB-экосистему:

- `PgBouncer` для приложений;
- `HAProxy` для выбора текущего `primary`.

`PostgreSQL/Patroni` живут и управляются вне этого репозитория.

## Контракт

Сервисы проекта должны подключаться к:

- `DB_HOST=db-rw.internal`
- `DB_PORT=5432`

В dev/prod строка подключения приложения не меняется. Меняются только значения окружения.

## Рендер backend-нод и PgBouncer

Backend-узлы задаются переменной:

- `DB_BACKENDS=10.0.0.11:5432,10.0.0.12:5432,10.0.0.13:5432`
- `HAPROXY_HEALTH_MODE=tcp` (по умолчанию) или `patroni-api`
- для `patroni-api`: `PATRONI_API_PORT=8008`, `PATRONI_CHECK_PATH=/primary`
- `DB_NAMES=AUTH,SAFE`
- `DB_NAME_AUTH=auth`
- `DB_NAME_SAFE=safe`
- `PGBOUNCER_AUTH_USER=pgbouncer_auth`
- `PGBOUNCER_AUTH_PASSWORD=<secret>`
- `PGBOUNCER_AUTH_DBNAME=ava_auth`
- `PGBOUNCER_AUTH_QUERY` опционально

Рендер:

```bash
bash scripts/db/render-haproxy-cfg.sh database/haproxy/haproxy.cfg
bash scripts/db/render-pgbouncer-config.sh database/pgbouncer/pgbouncer.ini database/pgbouncer/userlist.txt
```

## Запуск

```bash
docker compose -f database/docker-compose.yml up -d
```

## CI/CD

Workflow: `.github/workflows/db-proxy.yml`

Триггеры:

- `database/**`
- `scripts/db/**`
- `.github/workflows/db-proxy.yml`

Для `deploy-dev` требуются:

- `DB_BACKENDS`
- `DB_NAMES`
- `DB_NAME_*`
- `PGBOUNCER_AUTH_USER`
- `PGBOUNCER_AUTH_PASSWORD`
- `PGBOUNCER_AUTH_DBNAME`

В `CI` есть отдельный job `Validate Patroni API Checks (Mock)`:

- поднимает mock-ноды `primary/replica`;
- рендерит конфиг в режиме `patroni-api`;
- проверяет, что HAProxy маршрутизирует трафик только в `primary`.
