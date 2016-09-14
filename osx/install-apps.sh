#!/bin/bash

command -v brew > /dev/null || (echo; echo ">> Homebrew" && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)")

brew tap Homebrew/bundle

brew bundle --verbose

echo; echo ">> Installing Basher"
git clone https://github.com/basherpm/basher.git ~/.basher
