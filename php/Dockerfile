FROM {PHP_IMAGE}

# Composer from the pinned official image, Node.js for frontend builds
COPY --from={COMPOSER_IMAGE} /usr/bin/composer /usr/local/bin/composer
# python3 is upgraded with Node: Alpine moves it on under the pinned image, and a new python3
# subpackage that npm pulls in clashes with the image's older python3 (2026-11-23).
RUN apk add --no-cache --upgrade python3 python3-pyc python3-pycache-pyc0 {NODE_APK_PACKAGES}

# Set the document root ({DOC_ROOT_NOTE})
ENV WEB_DOCUMENT_ROOT={DOC_ROOT}

WORKDIR /app

# --- Dependency layers (cached unless composer.json / package.json changes) ---

# PHP dependencies: copy manifests first, install, then copy source
# Wildcards match nothing without failing (BuildKit), so repos without these manifests still build
COPY composer.json* composer.lock* ./
RUN if [ -f composer.json ]; then \
        composer install --no-dev --optimize-autoloader --no-interaction --no-scripts; \
    else \
        echo "No composer.json found, skipping composer install"; \
    fi

# Node dependencies: copy manifests first, install (no build yet — needs source)
COPY package.json* package-lock.json* ./
RUN if [ -f package.json ]; then \
        if [ -f package-lock.json ]; then \
            npm ci --no-audit --no-fund; \
        else \
            npm install --no-audit --no-fund; \
        fi; \
    else \
        echo "No package.json found, skipping npm install"; \
    fi

# --- Application source (invalidates cache on any file change) ---
COPY . .

# Regenerate autoloader with actual source files (fast — no download)
RUN if [ -f composer.json ]; then \
        composer dump-autoload --optimize; \
    fi

# Build frontend assets (needs source files from COPY above)
RUN set -e && \
    if [ -f package.json ]; then \
        echo ">>> Running npm build..." && \
        npm run build && \
        echo ">>> NPM build completed. Checking for manifest..." && \
        if [ -f public/build/manifest.json ]; then \
            echo ">>> Vite manifest found at public/build/manifest.json"; \
        elif [ -f public/build/.vite/manifest.json ]; then \
            echo ">>> Vite manifest found at public/build/.vite/manifest.json"; \
        else \
            echo ">>> WARNING: No Vite manifest found after build!"; \
            ls -la public/build/ 2>/dev/null || echo ">>> public/build/ directory does not exist"; \
        fi; \
    else \
        echo ">>> No package.json found, skipping npm build"; \
    fi

# Copy .env.example to .env if not exists and configure
RUN if [ ! -f .env ] && [ -f .env.example ]; then \
        cp .env.example .env; \
    fi && \
    if [ -f .env ] && [ -f artisan ]; then \
        sed -i 's|APP_ENV=.*|APP_ENV=production|' .env && \
        sed -i 's|APP_DEBUG=.*|APP_DEBUG=false|' .env && \
        sed -i 's|SESSION_DRIVER=.*|SESSION_DRIVER=file|' .env && \
        php artisan key:generate --force; \
    fi

# Set permissions for Laravel directories if they exist
RUN if [ -d storage ]; then \
        mkdir -p storage/logs storage/framework/sessions storage/framework/views storage/framework/cache/data storage/app/public && \
        chown -R www-data:www-data storage && chmod -R 777 storage; \
    fi && \
    if [ -d bootstrap/cache ]; then \
        chown -R www-data:www-data bootstrap/cache && chmod -R 777 bootstrap/cache; \
    fi

{EXTRA_WRITABLE_DIRS}
# Copy custom nginx config if provided
RUN if [ -f /app/nginx.conf ]; then \
        cp /app/nginx.conf /opt/docker/etc/nginx/vhost.conf; \
    fi

# Expose port
EXPOSE 80

CMD ["supervisord", "-c", "/opt/docker/etc/supervisor.conf"]