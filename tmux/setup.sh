#!/bin/bash
echo; echo ">> Configuring Tmux"

echo; echo ">> Setting symlinks for tmux configurations"
mkdir -p ~/.config/tmux/
ln -sfnv ~/.dots/tmux/tmux.conf ~/.config/tmux/tmux.conf

echo "Cloning Tmux Plugin Manager to ~/.tmux/plugins"
mkdir -pv ~/.tmux/plugins/
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "Press 'prefix + I' after starting tmux to install the plugins"
