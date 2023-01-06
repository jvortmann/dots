swap-theme-to-dark()
{
  swap-theme-from-to "light" "dark"

  swap-theme-refresh
}

swap-theme-to-light()
{
  swap-theme-from-to "dark" "light"

  swap-theme-refresh
}

swap-theme-from-to()
{
  gsed -i"" -E "s/^(colors:.*)-$1/\1-$2/" ~/.dots/alacritty/alacritty.yml
  gsed -i"" -E "s/_$1/_$2/" ~/.dots/tmux/theme.tmux
  gsed -i"" -E "s/(--color=)$1/\1$2/" ~/.dots/tmux/switch-popup.tmux
  gsed -i"" -E "s/$1/$2/" ~/.dots/zsh/conf/plugins/bat.zsh
  gsed -i"" -E "s/(--color=)$1/\1$2/" ~/.dots/zsh/conf/plugins/fzf.zsh
  gsed -i"" -E "s/(set background=)$1/\1$2/" ~/.config/nvim/conf/guioptions
  if [[ $1 == "light" ]];
  then
    gsed -i"" -E "s/(light = )true/\1false/" ~/.dots/git/config
  else
    gsed -i"" -E "s/(light = )false/\1true/" ~/.dots/git/config
  fi
}

swap-theme-refresh()
{
  tmux source ~/.dots/tmux/theme.tmux
  tmux source ~/.dots/tmux/switch-popup.tmux
  source ~/.dots/zsh/conf/plugins/bat.zsh
  source ~/.dots/zsh/conf/plugins/fzf.zsh
  echo "reopen Vim or run ':source ~/.config/nvim/conf/guioptions' to refresh"
}

swap-theme()
{
  if grep -q "^colors:.*-dark" ~/.dots/alacritty/alacritty.yml;
  then
    swap-theme-to-light
  else
    swap-theme-to-dark
  fi
}
