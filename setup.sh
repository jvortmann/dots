#!/usr/bin/env bash

if [ $# -ne 3 ]
then
  echo 'Usage: ./setup "computer_name" "User Name" "user@email.com"'
  exit 1
fi

computer_name="$1"
user_name="$2"
user_email="$3"


echo ">> Symlinking"
./symlink.sh  # setup symlinks

echo; echo ">> Entering /osx"
cd osx/

echo; echo ">> Installing apps"
./install-apps.sh       # install apps, command line utilities and fonts

echo; echo ">> Downloading widgets"
./download-widgets.sh   # download widgets to ~/Downloads

echo; echo ">> Configuring macOS"
./configure-osx.sh "$computer_name" # configure a Mac machine

echo; echo ">> Leaving /osx"
cd -

echo; echo ">> Configuring zsh"
./setup-zsh.sh   # creates the config folders and set zsh as default shell

echo; echo ">> Configuring Tmux"
./setup-tmux.sh   # creates the plugin manager folder and clone it

./setup-git-user.sh "$user_name" "$user_email" # creates the file with git user and email

./setup-ssh-key.sh "$computer_name" "$user_email" # creates ssh keys named after computer name using user email
