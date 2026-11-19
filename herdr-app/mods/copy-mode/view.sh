#!/bin/sh
set -eu
# A terminal from `hc run` gets the environment of the core, with a PATH of
# /usr/bin:/bin:/usr/sbin:/sbin. Without this, nvim, hc and Homebrew tools
# are missing.
PATH=$PATH:$HOME/.local/bin:/opt/homebrew/bin

exec nvim --clean -u "$(dirname "$0")/nvim.lua" --noplugin -n
