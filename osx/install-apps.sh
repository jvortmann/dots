#!/bin/bash

xcode-select --install
sudo xcodebuild -license accept

command -v brew > /dev/null || (echo; echo ">> Homebrew" && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)")
if [[ $(uname -m) = "x86_64" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo; echo ">> Installing Apps"
brew bundle --verbose --no-lock

echo; echo ">> Installing Basher"
test -d ~/.basher || git clone https://github.com/basherpm/basher.git ~/.basher
