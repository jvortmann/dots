#!/bin/bash
# Update the impeccable skill in pi/skills from upstream's latest release.
set -euo pipefail

dots=${DOTS:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
skill="$dots/pi/skills/impeccable"
tmp=$(mktemp -d)
trap 'rm -r "$tmp"' EXIT

(cd "$tmp" && "${IMPECCABLE:-impeccable}" install --scope=project --providers=pi --yes --no-hooks)
# Keep our files, which upstream's folder does not have. Leave out its engine
# binary, because mise installs the engine.
rsync -a --delete --exclude=LICENSE --exclude=NOTICE.md --exclude=UPSTREAM \
  --exclude=scripts/bin "$tmp/.pi/skills/impeccable/" "$skill/"
