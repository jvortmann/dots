#!/bin/bash
# Update the impeccable skill in pi/skills from upstream's latest release.
# The skill comes from https://github.com/pbakaus/impeccable, through its own
# installer. mise install and mise up install the newest engine, then run this
# script as their postinstall hook. Git ignores the skill folder. The release
# is in scripts/VERSION. When the folder is missing, run this script yourself.
set -euo pipefail

dots=${DOTS:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
skill="$dots/pi/skills/impeccable"
tmp=$(mktemp -d)
trap 'rm -r "$tmp"' EXIT

(cd "$tmp" && "${IMPECCABLE:-impeccable}" install --scope=project --providers=pi --yes --no-hooks)
# Leave out its engine binary, because mise installs the engine.
rsync -a --delete --exclude=scripts/bin "$tmp/.pi/skills/impeccable/" "$skill/"
