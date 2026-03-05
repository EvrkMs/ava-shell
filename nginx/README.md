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

- `ava_shell_nginx_certs:/etc/nginx/certs/fullchain.pem`
- `ava_shell_nginx_certs:/etc/nginx/certs/privkey.pem`

`nginx` will fail to start if these files are missing.

## Start

```bash
cd nginx
docker compose up -d
```

HTTP on port `80` is redirected to HTTPS (`443`) by `conf.d/00-http-redirect.conf`.

## Certbot (Cloudflare DNS-01)

State is persisted in fixed Docker named volumes:

- `ava_shell_certbot_state` -> `/etc/letsencrypt`
- `ava_shell_nginx_certs` -> `/etc/nginx/certs`

List volumes:

```bash
docker volume ls | grep ava_shell
```

Create temporary Cloudflare credentials:

```bash
mkdir -p runtime
printf "dns_cloudflare_api_token = %s\n" "$CF_DNS_API_TOKEN" > runtime/.cloudflare.ini
chmod 600 runtime/.cloudflare.ini
```

Issue certificate (example for `ava-shell.ru`):

```bash
docker compose --profile certbot run --rm certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /runtime/.cloudflare.ini \
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
  --dns-cloudflare-credentials /runtime/.cloudflare.ini
```

After issue/renew, copy certs from `/etc/letsencrypt/live/<domain>/` into `/etc/nginx/certs/` and reload nginx.
Then remove temporary credentials file:

```bash
rm -f runtime/.cloudflare.ini
```

## Reload config

```bash
docker exec ava-shell-nginx nginx -s reload
```

## Validate config

```bash
docker exec ava-shell-nginx nginx -t
```
