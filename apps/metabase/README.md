# Metabase

The official Metabase image (`metabase/metabase:v0.65.7.3`, AGPL-3.0 build) with a Postgres 17 database for Metabase's own settings.

- Setup completes Metabase's first-visit setup on localhost with the creator's email address. Traefik routes nothing to the app until the ready file exists.
- The JVM is capped at 768 MB of heap; the process uses about 1.3 GB in total, so it needs a server with 4 GB of memory or more.
- Sign in at `/auth/login` with the creator's email address and the password shown in the console.
