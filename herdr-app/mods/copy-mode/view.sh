#!/bin/sh
set -eu
PATH=$PATH:$HOME/.local/bin:/opt/homebrew/bin

exec nvim --clean -u "$(dirname "$0")/nvim.lua" --noplugin -n
