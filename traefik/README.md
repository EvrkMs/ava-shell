# Edge (Traefik)

This stack uses `Traefik` as the single edge entrypoint on ports `80/443`.

## Services

- `edge` (`traefik`) - HTTPS termination, redirects, ACME via Cloudflare DNS challenge
- `root-echo` - simple backend that returns `true`

The `auth` route intentionally points to `http://auth-admin:5000`.
If that backend is unavailable, Traefik should return `502/503` and stay alive.

## Route Config

Route templates are stored in:

- `traefik/dynamic/routes.ci.yml`
- `traefik/dynamic/routes.deploy.yml`

Workflows replace `__ROOT_DOMAIN__` and write:

- `traefik/dynamic/routes.generated.yml`

## Volumes

- `ava_shell_traefik_acme` - ACME storage (`acme.json`)

## Run locally

```bash
cd traefik
docker compose up -d
```

## Validate

```bash
docker compose ps
docker logs ava-shell-edge --tail 100
```

