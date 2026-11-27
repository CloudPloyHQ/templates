# WordPress

The official WordPress image (`wordpress:7.1.5-php8.4-apache`) with a MySQL 8.4 database and its files on a lasting volume at `/var/www/html`.

- Setup runs `wp core install` once in the `wordpress:cli` image. Until then the installer pages answer 404, so nobody can claim the site first.
- Sign in at `/wp-admin/` as `admin` with the password the team's owners and admins see in the console.
