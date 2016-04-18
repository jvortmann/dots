#!/bin/bash

echo "Adding Zsh to /etc/shells and set it as default shell (needs sudo)"
sudo grep "$(which zsh)" /etc/shells || echo $(which zsh) | sudo tee -a /etc/shells
chsh -s $(which zsh) jv

echo "Symlink Zsh configs to ~/zshrc"
ln -sfhv ~/.dots/zsh/zshrc ~/.zshrc
