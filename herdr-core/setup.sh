#!/bin/bash
echo; echo ">> Configuring the Herdr core"

echo; echo ">> Setting symlink for the Herdr core configuration"
mkdir -p ~/.config/
if [[ -d ~/.config/herdr-core && ! -L ~/.config/herdr-core ]]; then
  backup=~/.config/herdr-core.pre-dots
  [[ -e $backup ]] && backup+="-$(date +%Y%m%d%H%M%S)"
  mv -v ~/.config/herdr-core "$backup"
fi
ln -sfnv ~/.dots/herdr-core ~/.config/herdr-core
