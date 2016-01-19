#!/bin/bash

echo "Adding Fish to /etc/shells and set it as default shell (needs sudo)"
sudo grep "fish" /etc/shells || echo $(which fish) | sudo tee -a /etc/shells
chsh -s $(which fish)

echo "Adding Fish configs to ~/.config/fish"
mkdir -pv .config/fish/
ln -sfhv ~/.dots/fish/conf/ ~/.config/fish/conf
ln -sfhv ~/.dots/fish/config.fish ~/.config/fish/config.fish
ln -sfhv ~/.dots/fish/functions/ ~/.config/fish/functions
