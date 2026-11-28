# Umami

The official Umami image (`ghcr.io/umami-software/umami:3.5.0`, MIT) with a Postgres 17 database.

- Umami starts with a well-known default password. Setup replaces it with the generated one on localhost, and Traefik routes nothing to the app until the ready file exists.
- The volume at `/app/data` holds only that ready file; the data is in Postgres.
- Sign in at `/login` with the `admin` user and the password shown in the console.
