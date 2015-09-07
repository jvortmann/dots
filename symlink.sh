#!/bin/bash

echo "Setting symlinks for default configurations"
ln -sfhv $(pwd) ~/.dots
ln -sfhv ~/.dots/ag/agignore ~/.agignore
ln -sfhv ~/.dots/git/gitignore ~/.gitignore
ln -sfhv ~/.dots/git/gitconfig ~/.gitconfig
ln -sfhv ~/.dots/input/inputrc ~/.inputrc
ln -sfhv ~/.dots/gem/gemrc ~/.gemrc
ln -sfhv ~/.dots/irb/irbrc ~/.irbrc
ln -sfhv ~/.dots/tmux/tmux.conf ~/.tmux.conf
