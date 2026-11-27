# n8n

The official n8n image (`n8nio/n8n:2.49.6`) with a Postgres 17 database and its files on a lasting volume at `/home/node/.n8n`.

- Setup claims the owner account on localhost. Traefik routes nothing to the app until the ready file exists.
- Sign in with the creator's email address and the password shown in the console.
