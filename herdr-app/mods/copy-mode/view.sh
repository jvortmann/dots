#!/bin/sh
set -eu
PATH=$PATH:$HOME/.local/bin:/opt/homebrew/bin

COPY_MODE_TERMINAL=$1 exec nvim --clean -u "$(dirname "$0")/nvim.lua" --noplugin -n
