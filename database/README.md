# DB Proxy (HAProxy only)

`database/` содержит только `HAProxy` для входа в внешнюю DB-экосистему.

`PostgreSQL/Patroni` живут и управляются вне этого репозитория.

## Контракт

Сервисы проекта должны подключаться к:

- `DB_HOST=db-rw.internal`
- `DB_PORT=5432`

В dev/prod строка подключения приложения не меняется. Меняются только значения окружения.

## Рендер backend-нод

Backend-узлы задаются переменной:

- `DB_BACKENDS=10.0.0.11:5432,10.0.0.12:5432,10.0.0.13:5432`
- `HAPROXY_HEALTH_MODE=tcp` (по умолчанию) или `patroni-api`
- для `patroni-api`: `PATRONI_API_PORT=8008`, `PATRONI_CHECK_PATH=/primary`

Рендер:

```bash
bash scripts/db/render-haproxy-cfg.sh database/haproxy/haproxy.cfg
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

Для `deploy-dev` требуется переменная окружения `DB_BACKENDS` в `Environment: dev-shell`.

В `CI` есть отдельный job `Validate Patroni API Checks (Mock)`:

- поднимает mock-ноды `primary/replica`;
- рендерит конфиг в режиме `patroni-api`;
- проверяет, что HAProxy маршрутизирует трафик только в `primary`.
