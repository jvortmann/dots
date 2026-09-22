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
  gsed -i"" -E "s/^(theme = .*)-$1$/\1-$2/" ~/.dots/ghostty/config
  gsed -i"" -E "s/$1/$2/" ~/.dots/tmux/theme.tmux
  gsed -i"" -E "s/(--color=)$1/\1$2/" ~/.dots/tmux/switch-popup.tmux
  gsed -i"" -E "s/$1/$2/" ~/.config/bat/config
  gsed -i"" -E "s/(--color=)$1/\1$2/" ~/.dots/zsh/conf/plugins/fzf.zsh
  gsed -i"" -E "s/(vim\.opt\.background = )'$1'/\1'$2'/" ~/.config/nvim/lua/config/guioptions.lua
  gsed -i"" -E "s/(syntax-theme = \"[^\"]*\()$1(\)\")/\1$2\2/" ~/.dots/git/config
}

swap-theme-refresh()
{
  tmux source ~/.dots/tmux/theme.tmux
  tmux source ~/.dots/tmux/switch-popup.tmux
  source ~/.dots/zsh/conf/plugins/fzf.zsh
  echo "In Vim, run ':source ~/.config/nvim/lua/config/guioptions.lua', or open Vim again."
  echo "After a change to this script, run 'source ~/.dots/zsh/conf/plugins/theme.zsh'."
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
  gsed -i"" -E "s/Solarized \((.*)\)/Catppuccin-\1/" ~/.config/bat/config
  gsed -i"" -E "s/(colorscheme )Solarized8/\1catppuccin/" ~/.config/nvim/conf/guioptions

  swap-theme-refresh
}

swap-theme-to-solarized()
{
  gsed -i"" -E "s/Catppuccin-(.*)\"/Solarized (\1)\"/" ~/.config/bat/config
  gsed -i"" -E "s/(colorscheme )catppuccin/\1Solarized8/" ~/.config/nvim/conf/guioptions

  swap-theme-refresh
}
