# Directus

The official Directus image (`directus/directus:12.7.0`) with a Postgres 17 database and its uploads on a lasting volume at `/directus/uploads`.

- Directus is source-available under the Monospace Sustainable Core License; check that its terms fit your organisation.
- Setup creates an Administrator role and the `admin@example.com` user with the generated password, using the Directus CLI in the container. Traefik routes nothing to the app until the ready file exists.
- Sign in at `/admin/login` with `admin@example.com` and the password shown in the console, then change the email in Directus.
