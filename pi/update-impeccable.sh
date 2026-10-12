#!/bin/bash
# Update the impeccable skill in pi/skills from upstream's latest release.
set -euo pipefail

dots=${DOTS:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
skill="$dots/pi/skills/impeccable"
home=$(mktemp -d)
# Keep our description, which makes agents load the skill on their own.
description=$(grep -m1 '^description: ' "$skill/SKILL.md")

HOME="$home" "${IMPECCABLE:-impeccable}" install --global --providers=pi --yes --no-hooks
# Keep our files, which upstream's folder does not have. Leave out its engine
# binary, because mise installs the engine.
rsync -a --delete --exclude=LICENSE --exclude=NOTICE.md --exclude=UPSTREAM \
  --exclude=scripts/bin "$home/.pi/agent/skills/impeccable/" "$skill/"
DESCRIPTION="$description" perl -i -pe 's/^description: .*/$ENV{DESCRIPTION}/ if $. < 10' "$skill/SKILL.md"

# The engine that mise installs must match the release of the skill.
VERSION=$(tr -d '[:space:]' < "$skill/scripts/VERSION") perl -i -pe \
  's/^("github:pbakaus\/impeccable" = \{ version = ")[^"]*/$1$ENV{VERSION}/' "$dots/mise/config.toml"
