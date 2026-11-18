#!/bin/sh
set -eu
PATH=$PATH:$HOME/.local/bin:/opt/homebrew/bin

capture=$(mktemp)
trap 'rm -f "$capture"' EXIT
reply=$(hc read --json --lines 10000 "$1")
printf '%s' "$reply" | jq -er .text > "$capture"
nvim --clean -u "$(dirname "$0")/nvim.lua" --noplugin -n -R -M -- "$capture"
