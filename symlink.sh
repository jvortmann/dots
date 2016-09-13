#!/bin/bash

echo; echo ">> Creating ~/.config folder"

mkdir -p ~/.config/

echo; echo ">> Setting symlinks for dots folder"
ln -sfhv $(pwd) ~/.dots

echo; echo ">> Setting symlinks for default configurations"
ln -sfhv ~/.dots/ag/agignore ~/.agignore
ln -sfhv ~/.dots/input/inputrc ~/.inputrc
ln -sfhv ~/.dots/ctags/ctags ~/.ctags

echo; echo ">> Setting symlinks for ruby configurations"
ln -sfhv ~/.dots/gem/gemrc ~/.gemrc
ln -sfhv ~/.dots/irb/irbrc ~/.irbrc
ln -sfhv ~/.dots/guard/guard.rb ~/.guard.rb

echo; echo ">> Setting symlinks for tmux configurations"
ln -sfhv ~/.dots/tmux/tmux.conf ~/.tmux.conf

echo; echo ">> Setting symlinks for git"
mkdir -p ~/.config/git
ln -sfhv ~/.dots/git/ignore ~/.config/git/ignore
ln -sfhv ~/.dots/git/config ~/.config/git/config
