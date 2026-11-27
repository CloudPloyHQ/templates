# Uptime Kuma

The official Uptime Kuma image (`louislam/uptime-kuma:2.5.12-slim`) with its SQLite data on a lasting volume at `/app/data`.

- Setup creates the `admin` user on localhost. Traefik routes nothing to the app until the ready file exists.
- It has no separate database, so CloudPloy database backups do not cover it.
