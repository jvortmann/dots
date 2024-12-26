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
  gsed -i"" -E "s/^(.*themes\/.*)-$1.toml/\1-$2.toml/" ~/.dots/alacritty/alacritty.toml
  gsed -i"" -E "s/^(theme = .*)-$1$/\1-$2/" ~/.dots/ghostty/config
  gsed -i"" -E "s/$1/$2/" ~/.dots/tmux/theme.tmux
  gsed -i"" -E "s/(--color=)$1/\1$2/" ~/.dots/tmux/switch-popup.tmux
  gsed -i"" -E "s/$1/$2/" ~/.config/bat/config
  gsed -i"" -E "s/(--color=)$1/\1$2/" ~/.dots/zsh/conf/plugins/fzf.zsh
  gsed -i"" -E "s/(set background=)$1/\1$2/" ~/.config/nvim/conf/guioptions
  gsed -i"" -E "s/$1( = true)/$2\1/" ~/.dots/git/config
}

swap-theme-refresh()
{
  tmux source ~/.dots/tmux/theme.tmux
  tmux source ~/.dots/tmux/switch-popup.tmux
  source ~/.dots/zsh/conf/plugins/fzf.zsh
  echo "run 'swap-theme-refresh' on vim's window and reopen Vim or run ':source ~/.config/nvim/conf/guioptions' to refresh"
}

swap-theme()
{
  if grep -q "theme = .*-dark" ~/.dots/ghostty/config;
  then
    swap-theme-to-light
  else
    swap-theme-to-dark
  fi
}

swap-theme-to-catppuccin()
{
  gsed -i"" -E "s/^(.*themes\/)(.*)-(.*).toml/\1catppuccin-\3.toml/" ~/.dots/alacritty/alacritty.toml
  gsed -i"" -E "s/Solarized \((.*)\)/Catppuccin-\1/" ~/.config/bat/config
  gsed -i"" -E "s/(colorscheme )Solarized8/\1catppuccin/" ~/.config/nvim/conf/guioptions

  swap-theme-refresh
}

swap-theme-to-solarized()
{
  gsed -i"" -E "s/^(.*themes\/)(.*)-(.*).toml/\1solarized-\3.toml/" ~/.dots/alacritty/alacritty.toml
  gsed -i"" -E "s/Catppuccin-(.*)\"/Solarized (\1)\"/" ~/.config/bat/config
  gsed -i"" -E "s/(colorscheme )catppuccin/\1Solarized8/" ~/.config/nvim/conf/guioptions

  swap-theme-refresh
}
