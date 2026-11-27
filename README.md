# CloudPloy templates

The build recipes, one-click app templates and base images CloudPloy uses to run apps on your
servers, in the open.

- **Recipes**: one folder per framework or runtime. Each holds the `Dockerfile` CloudPloy
  generates for that stack and a `template.json` describing it (frameworks, how they are
  detected, default port, start command, placeholders).
- **App templates**: `apps/<id>/template.json`, one folder per one-click app (WordPress,
  Ghost, n8n, Uptime Kuma). An app from a template runs a pinned image with no build, an
  optional database and lasting volume, and an optional one-time setup.
- **Images**: `images.txt` pins every third-party image CloudPloy runs (the PHP base,
  Composer, Traefik, Postgres, MySQL, Valkey and the one-click app images). A daily workflow
  copies each one, every architecture and the same digest, to
  `ghcr.io/cloudployhq/<name>:<tag>`. Servers pull from there, so builds never wait on
  Docker Hub's pull limit or on one cloud's registry.

This repo holds no secrets. The mirror workflow logs in to GHCR with the workflow's own
`GITHUB_TOKEN` and nothing else.

## Layout

```
images.txt                   pinned image list: <name>:<tag> <source>@sha256:<digest>
scripts/mirror.sh            copies images.txt to the registry and checks each digest
.github/workflows/mirror.yml runs mirror.sh daily, on a push to images.txt and by hand
php/Dockerfile               Laravel, Symfony and plain PHP apps
php/template.json            frameworks, detect rules, port, start command, placeholders
apps/<id>/template.json      one-click app: image, port, volume, database, env, setup
apps/<id>/README.md          what the app gets and how its owner signs in (optional)
```

Node.js, Python, Ruby and other stacks build with Nixpacks today, so they have no recipe here
yet. A stack gets a folder when CloudPloy starts generating its Dockerfile.

## How CloudPloy uses it

Brain (the CloudPloy API) does not fetch from this repo while it deploys. It vendors a copy of
the recipe folders and `apps/` at one commit (`src/recipes/` in brain, with the commit in
`src/recipes/COMMIT`) and compiles them in. Brain's CI fails when the vendored copy differs
from this repo at that commit. A change here reaches customers only when brain is moved to
the new commit and released.

Placeholders such as `{PHP_IMAGE}` are filled by brain with images from
`ghcr.io/cloudployhq`, pinned by digest.

## Add or change a build recipe

1. Add a folder `<stack>/` with a `Dockerfile` and a `template.json` like `php/`.
2. Add every image the Dockerfile pulls to `images.txt`, pinned by its multi-arch index
   digest. Prefer the `public.ecr.aws/docker/library` copy of an official image as the source.
3. Merge to `main`. The mirror workflow copies new images; check its run is green.
4. In brain, run `scripts/sync-templates.sh <commit>` and open a PR.

To bump an image, change its digest here and in brain together. Moving a tag keeps the old
digest in the package, so servers pinned to it can still pull it.

## Add an app template

1. Add `apps/<id>/template.json`. The id is lowercase letters, digits and `-`, and starts the
   app's address. Copy a folder that is close (`uptime-kuma/` has no database, `n8n/` has
   Postgres, `ghost/` and `wordpress/` have MySQL). Fields:

   | Field | Required | Meaning |
   |---|---|---|
   | `id`, `name`, `description` | yes | shown in the console and to MCP clients |
   | `image` | yes | `{{registry}}/<name>:<tag>@sha256:<digest>`, a line in `images.txt` |
   | `port` | yes | the container port Traefik routes |
   | `memory_mb` | yes | the app's own free-memory minimum (at least 64); the database's cap comes on top |
   | `volume` | no | absolute path of one lasting volume; the app then runs one copy |
   | `database` | no | `postgres`, `mysql` or `redis`: made with the app, linked, deleted with it |
   | `env` | no | variables CloudPloy owns for the app |
   | `setup` | no | `command` (sh, the admin secret on stdin), optional pinned `image` and `user`, optional `ready` file on the volume that the command creates last |
   | `admin` | no | `user` and `path` of the admin account; needs a `setup` |

   Env values may use `{{secret}}` (generated once, stored encrypted), `{{app.url}}` and
   `{{database.host}}`, `.port`, `.user`, `.password`, `.name`, `.url`. Anything else is
   literal text. Never put a real secret in a template.
2. If the app has a first-visit sign-up page, claim it in `setup` and set `setup.ready`, so
   the app is never public before the setup ran.
3. Add the image (and the setup image) to `images.txt`, merge, and check the mirror run is
   green.
4. Optionally add `apps/<id>/README.md` with what the app gets and its limits.
5. In brain, run `scripts/sync-templates.sh <commit>`, add the id to the list test, and open a
   PR. Brain's tests check every template file.
