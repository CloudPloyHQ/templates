#!/usr/bin/env bash
# Copies every image in images.txt to ghcr.io/<owner>/<name>:<tag>, every architecture, byte for
# byte (same digest), then checks that an anonymous pull gets the pinned digest. Needs crane
# (logged in to ghcr.io), curl and jq.
#
#   REGISTRY=ghcr.io/cloudployhq scripts/mirror.sh [images.txt]
set -euo pipefail

: "${REGISTRY:?set REGISTRY}"
list=${1:-images.txt}
failed=0
ACCEPT=application/vnd.oci.image.index.v1+json,application/vnd.docker.distribution.manifest.list.v2+json,application/vnd.oci.image.manifest.v1+json,application/vnd.docker.distribution.manifest.v2+json

# The digest an anonymous client gets for ghcr.io/<repo>:<tag>; nothing when it cannot pull.
anon_digest() {
  local path=${1#ghcr.io/} token
  local repo=${path%:*} tag=${path##*:}
  token=$(curl -fsS "https://ghcr.io/token?scope=repository:$repo:pull" | jq -r .token) || return 0
  curl -fsSI -H "Authorization: Bearer $token" -H "Accept: $ACCEPT" "https://ghcr.io/v2/$repo/manifests/$tag" |
    tr -d '\r' | awk -F': ' 'tolower($1) == "docker-content-digest" { print $2 }' || true
}

while read -r target source; do
  case "$target" in '' | '#'*) continue ;; esac
  digest=${source##*@}
  [[ $digest == sha256:* ]] || { echo "::error::$target: source is not pinned by digest"; exit 1; }
  dest="$REGISTRY/$target"
  # A tag or a digest, not both; the tag in images.txt is for people.
  ref=${source%@*}
  from="${ref%:*}@$digest"
  # A copy that is already there is skipped, so the schedule costs one manifest read per image.
  if [ "$(anon_digest "$dest")" = "$digest" ]; then
    echo "up to date: $dest@$digest"
    continue
  fi
  echo "copying $from -> $dest"
  if ! crane copy "$from" "$dest"; then
    echo "::error::$target: copy failed"
    failed=1
    continue
  fi
  # Anonymous on purpose: a private package fails here, so the run is red until it is public.
  got=$(anon_digest "$dest")
  if [ "$got" != "$digest" ]; then
    echo "::error::$target: an anonymous pull of $dest gets '${got:-nothing}', not $digest (is the package public?)"
    failed=1
  fi
done <"$list"

exit $failed
