#!/bin/bash

echo ">> Creating ~/.config folder"
mkdir -p ~/.config/

echo ">> Setting symlinks for default configurations"
ln -sfhv $(pwd) ~/.dots
ln -sfhv ~/.dots/ag/agignore ~/.agignore

echo ">> Setting symlinks for git"
mkdir -p ~/.config/git
ln -sfhv ~/.dots/git/ignore ~/.config/git/ignore
ln -sfhv ~/.dots/git/config ~/.config/git/config

ln -sfhv ~/.dots/input/inputrc ~/.inputrc
ln -sfhv ~/.dots/gem/gemrc ~/.gemrc
ln -sfhv ~/.dots/irb/irbrc ~/.irbrc
ln -sfhv ~/.dots/tmux/tmux.conf ~/.tmux.conf
ln -sfhv ~/.dots/ctags/ctags ~/.ctags
ln -sfhv ~/.dots/guard/guard.rb ~/.guard.rb
