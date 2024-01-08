#!/bin/bash

echo "Cloning Tmux Plugin Manager to ~/.tmux/plugins"
mkdir -pv ~/.tmux/plugins/
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "Press 'prefix + I' after starting tmux to install the plugins"
