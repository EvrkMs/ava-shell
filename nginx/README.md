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

- `certs/fullchain.pem`
- `certs/privkey.pem`

`nginx` will fail to start if these files are missing.

## Start

```bash
cd nginx
docker compose up -d
```

HTTP on port `80` is redirected to HTTPS (`443`) by `conf.d/00-http-redirect.conf`.

## Certbot (Cloudflare DNS-01)

Create a temporary credentials file from `CF_DNS_API_TOKEN`:

```bash
printf "dns_cloudflare_api_token = %s\n" "$CF_DNS_API_TOKEN" > certbot/.cloudflare.ini
chmod 600 certbot/.cloudflare.ini
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

After issue/renew, copy or link resulting certs into `certs/` and reload nginx.
Then remove temporary credentials file:

```bash
rm -f certbot/.cloudflare.ini
```

## Reload config

```bash
docker exec ava-shell-nginx nginx -s reload
```

## Validate config

```bash
docker exec ava-shell-nginx nginx -t
```
