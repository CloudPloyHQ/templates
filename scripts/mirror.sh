#!/usr/bin/env bash
# Copies every image in images.txt to $REGISTRY/<name>:<tag>, all architectures, same digest,
# then checks the copy answers anonymously with the pinned digest. Needs skopeo; log in first.
#
#   REGISTRY=ghcr.io/cloudployhq scripts/mirror.sh [images.txt]
set -euo pipefail

: "${REGISTRY:?set REGISTRY}"
list=${1:-images.txt}
failed=0

while read -r target source; do
  case "$target" in '' | '#'*) continue ;; esac
  digest=${source##*@}
  [[ $digest == sha256:* ]] || { echo "::error::$target: source is not pinned by digest"; exit 1; }
  dest="$REGISTRY/$target"
  # skopeo takes a tag or a digest, not both; the tag in images.txt is for people.
  ref=${source%@*}
  from="${ref%:*}@$digest"
  # A copy that is already there is skipped, so the schedule costs one manifest read per image.
  if [ "$(skopeo inspect --raw --no-creds "docker://$dest" 2>/dev/null | sha256sum | cut -d' ' -f1)" = "${digest#sha256:}" ]; then
    echo "up to date: $dest@$digest"
    continue
  fi
  echo "copying $from -> $dest"
  if ! skopeo copy --all --preserve-digests --retry-times 3 "docker://$from" "docker://$dest"; then
    echo "::error::$target: copy failed"
    failed=1
    continue
  fi
  got=$(skopeo inspect --raw --no-creds "docker://$dest" | sha256sum | cut -d' ' -f1)
  if [ "$got" != "${digest#sha256:}" ]; then
    echo "::error::$target: mirrored digest sha256:$got is not the pinned $digest"
    failed=1
  fi
done <"$list"

exit $failed
