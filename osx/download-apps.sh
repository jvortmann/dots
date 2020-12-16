#!/bin/bash

echo ">> Setting remaining apps"
while read -r line
do
  name=$(echo "$line" | cut -d'|' -f1 | tr -d '[:space:]')
  mode=$(echo "$line" | cut -d'|' -f2  | tr -d '[:space:]')
  url=$(echo "$line" | cut -d'|' -f3  | tr -d '[:space:]')

  case "$mode"  in
    "download")
      echo ">> Downloading $name"
      (cd "$HOME/Downloads" && curl --progress-bar -LO "$url");;
    "open")
      echo ">> Opening $name"
      open "$url";;
  esac
done < apps
