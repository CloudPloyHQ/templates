# Grafana

The official Grafana OSS image (`grafana/grafana:13.0.14`, AGPL-3.0) with its SQLite data on a lasting volume at `/var/lib/grafana`.

- Grafana starts with a well-known default password. Setup replaces it with `grafana cli admin reset-admin-password` in the container, and Traefik routes nothing to the app until the ready file exists. Sign-up is off.
- It has no separate database, so CloudPloy database backups do not cover it.
- Sign in at `/login` with the `admin` user and the password shown in the console.
