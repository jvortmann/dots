#!/bin/bash
echo; echo ">> Configuring the Herdr app"

echo; echo ">> Setting symlink for the Herdr app configurations"
# One folder link: the app writes its own state into this folder and git/ignore
# keeps it out. A new mod, layout or theme shows up with no new run.
mkdir -p ~/.config/
if [[ -d ~/.config/herdr-app && ! -L ~/.config/herdr-app ]]; then
  backup=~/.config/herdr-app.pre-dots
  [[ -e $backup ]] && backup+="-$(date +%Y%m%d%H%M%S)"
  mv -v ~/.config/herdr-app "$backup"
fi
ln -sfnv ~/.dots/herdr-app ~/.config/herdr-app
