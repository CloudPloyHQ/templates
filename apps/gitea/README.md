# Gitea

The official Gitea image (`gitea/gitea:28.4.0`, MIT) with a Postgres 17 database and its repositories and settings on a lasting volume at `/data`.

- The web installer is locked and sign-up is off. Setup creates the `admin` user with the Gitea CLI in the container.
- Git works over HTTPS only; SSH is off, because CloudPloy routes one HTTP port per app.
- Sign in at `/user/login` with the `admin` user and the password shown in the console, then add users from the site administration.
