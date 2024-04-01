#!/bin/bash

xcode-select --install
sudo xcodebuild -license accept

command -v brew > /dev/null || (echo; echo ">> Homebrew" && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)")

echo; echo ">> Installing Apps"
brew bundle --verbose --no-lock

echo; echo ">> Installing Basher"
git clone https://github.com/basherpm/basher.git ~/.basher
