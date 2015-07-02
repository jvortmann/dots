#!/bin/bash

command -v brew > /dev/null || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install caskroom/cask/brew-cask
brew tap homebrew/versions
brew tap caskroom/versions
brew tap caskroom/fonts

export HOMEBREW_CASK_OPTS="--appdir=/Applications"
cat apps/brew-cask | tr '\n' ' ' | xargs brew cask install
cat apps/brew | tr '\n' ' ' | xargs brew install
