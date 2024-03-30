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

echo; echo ">> Downloading apps"
./download-apps.sh   # download apps to ~/Downloads

echo; echo ">> Configuring macOS"
./configure-osx.sh "$computer_name" # configure a Mac machine

echo; echo ">> Leaving /osx"
cd -

./setup_tools.sh

./setup-git-user.sh "$user_name" "$user_email" # creates the file with git user and email

./setup-ssh-key.sh "$computer_name" "$user_email" # creates ssh keys named after computer name using user email

./setup-ssh-config.sh "$computer_name" # creates ssh config using computer name
