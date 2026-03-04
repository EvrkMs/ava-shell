# nginx (80/443, modular conf)

## Structure

- `nginx.conf` - base config
- `conf.d/*.conf` - flat configs
- `conf.d/*/*.conf` - grouped configs (for example `auth/auth.conf`)
- `snippets/` - reusable config fragments

Current examples:

- `conf.d/auth/auth.conf`
- `conf.d/admin-ui/admin.conf`
- `conf.d/routing-by-path.example.conf` (optional, disabled by default)

## TLS files

Put certificates here:

- `${NGINX_CERTS_DIR:-./certs}/fullchain.pem`
- `${NGINX_CERTS_DIR:-./certs}/privkey.pem`

`nginx` will fail to start if these files are missing.

## Start

```bash
cd nginx
docker compose up -d
```

HTTP on port `80` is redirected to HTTPS (`443`) by `conf.d/00-http-redirect.conf`.

## Certbot (Cloudflare DNS-01)

For self-hosted runner/CD use persistent state directories (outside runner `_work`), for example:

```bash
export NGINX_STATE_DIR=/home/evrk/ava-shell-state/nginx
export CERTBOT_STATE_DIR="${NGINX_STATE_DIR}/certbot"
export NGINX_CERTS_DIR="${NGINX_STATE_DIR}/certs"
mkdir -p "$CERTBOT_STATE_DIR" "$NGINX_CERTS_DIR" "$CERTBOT_STATE_DIR/work" "$CERTBOT_STATE_DIR/logs"
```

`docker-compose.yml` supports these env vars:

- `CERTBOT_STATE_DIR` -> mounted to `/etc/letsencrypt`
- `NGINX_CERTS_DIR` -> mounted to `/etc/nginx/certs`

Create a temporary credentials file from `CF_DNS_API_TOKEN`:

```bash
printf "dns_cloudflare_api_token = %s\n" "$CF_DNS_API_TOKEN" > "${CERTBOT_STATE_DIR}/.cloudflare.ini"
chmod 600 "${CERTBOT_STATE_DIR}/.cloudflare.ini"
```

Issue certificate (example for `ava-shell.ru`):

```bash
docker compose --profile certbot run --rm certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /etc/letsencrypt/.cloudflare.ini \
  --email you@example.com \
  --agree-tos \
  --no-eff-email \
  -d ava-shell.ru \
  -d '*.ava-shell.ru'
```

Renew certificates:

```bash
docker compose --profile certbot run --rm certbot renew \
  --dns-cloudflare \
  --dns-cloudflare-credentials /etc/letsencrypt/.cloudflare.ini
```

After issue/renew, copy certs from `${CERTBOT_STATE_DIR}/live/<domain>/` into `${NGINX_CERTS_DIR}/` and reload nginx.
Then remove temporary credentials file:

```bash
rm -f "${CERTBOT_STATE_DIR}/.cloudflare.ini"
```

## Reload config

```bash
docker exec ava-shell-nginx nginx -s reload
```

## Validate config

```bash
docker exec ava-shell-nginx nginx -t
```
