# CloudPloy templates

The build recipes and base images CloudPloy uses to run apps on your servers, in the open.

- **Recipes**: one folder per framework or runtime. Each holds the `Dockerfile` CloudPloy
  generates for that stack and a `template.json` describing it (frameworks, how they are
  detected, default port, start command, placeholders).
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
```

Node.js, Python, Ruby and other stacks build with Nixpacks today, so they have no recipe here
yet. A stack gets a folder when CloudPloy starts generating its Dockerfile.

## How CloudPloy uses it

Brain (the CloudPloy API) does not fetch from this repo while it deploys. It vendors a copy of
the recipe folders at one commit (`src/recipes/` in brain, with the commit in
`src/recipes/COMMIT`) and compiles them in. Brain's CI fails when the vendored copy differs
from this repo at that commit. A change here reaches customers only when brain is moved to
the new commit and released.

Placeholders such as `{PHP_IMAGE}` are filled by brain with images from
`ghcr.io/cloudployhq`, pinned by digest.

## Add or change a template

1. Add a folder `<stack>/` with a `Dockerfile` and a `template.json` like `php/`.
2. Add every image the Dockerfile pulls to `images.txt`, pinned by its multi-arch index
   digest. Prefer the `public.ecr.aws/docker/library` copy of an official image as the source.
3. Merge to `main`. The mirror workflow copies new images; check its run is green.
4. In brain, run `scripts/sync-templates.sh <commit>` and open a PR.

To bump an image, change its digest here and in brain together. Moving a tag keeps the old
digest in the package, so servers pinned to it can still pull it.
