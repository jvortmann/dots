#!/bin/bash

command -v brew > /dev/null || (echo; echo ">> Homebrew Versions" && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)")

brew tap Homebrew/bundle
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

brew bundle
