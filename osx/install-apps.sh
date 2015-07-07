#!/bin/bash

command -v brew > /dev/null || (echo; echo ">> Homebrew Versions" && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)")

echo; echo ">> Homebrew Versions"
brew tap homebrew/versions
echo; echo ">> Homebrew Cask"
brew install caskroom/cask/brew-cask
echo; echo ">> Homebrew Cask Versions"
brew tap caskroom/versions
echo; echo ">> Homebrew Cask Fonts"
brew tap caskroom/fonts

export HOMEBREW_CASK_OPTS="--appdir=/Applications"
echo; echo ">> Installing Apps"
cat apps/brew-cask | tr '\n' ' ' | xargs brew cask install
echo; echo ">> Installing Command Line Tools"
cat apps/brew | tr '\n' ' ' | xargs brew install
