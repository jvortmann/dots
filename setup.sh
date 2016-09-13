#!/usr/bin/env bash

if [ $# -ne 3 ]
then
  echo 'Usage: ./setup "computer_name"  "User Name"  "user@email.com"'
  exit 1
fi

computer_name="$1"
user_name="$2"
user_email_name="$3"


echo ">> Symlinking"
./symlink.sh  # setup and symlinks

echo; echo ">> Installing apps"
cd osx/
./install-apps.sh       # install apps, command line utilities and fonts

echo; echo ">> Downloading widgets"
./download-widgets.sh   # download widgets to ~/Downloads

echo; echo ">> Configuring macOS"
./configure-osx.sh "$computer_name" "$user_name"  "$user_email" # configure a Mac machine
cd -

echo; echo ">> Configuring zsh"
./setup-zsh.sh   # creates the config folders and set zsh as default shell

echo; echo ">> Configuring Tmux"
./setup-tmux.sh   # creates the config folders and set zsh as default shell

echo; echo ">> Setting git User and Email"
git config --global user.name "$user_name"
git config --global user.email "$user_email"
