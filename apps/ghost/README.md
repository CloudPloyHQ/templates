# Ghost

The official Ghost image (`ghost:6.79.0`) with a MySQL 8.4 database and its content on a lasting volume at `/var/lib/ghost/content`.

- Setup claims the owner account on localhost. Traefik routes nothing to the app until the ready file exists.
- Sign in at `/ghost/` with the creator's email address and the password shown in the console.
- Mail is not set up: newsletters, staff invites and password reset do not send.
