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
  local state=~/.local/state/dots
  [[ -d $state ]] || mkdir -p $state
  print $2 > $state/theme
  print "theme = solarized-$2" > $state/theme.ghostty
  print "[delta]\n  syntax-theme = \"Solarized ($2)\"" > $state/theme.gitconfig
  print "source \"\$HOME/.dots/tmux/style/$2.tmux\"" > $state/theme.tmux
  gsed -i"" -E "s/(\"appearance\": \")$1\"/\1$2\"/" ~/.dots/herdr-app/settings.json
}

swap-theme-refresh()
{
  if tmux has-session 2>/dev/null;
  then
    tmux source ~/.dots/tmux/theme.tmux
    tmux source ~/.dots/tmux/switch-popup.tmux
  fi
  source ~/.dots/zsh/conf/plugins/fzf.zsh
}

swap-theme()
{
  local state=~/.local/state/dots/theme
  if [[ -f $state && $(<$state) == light ]];
  then
    swap-theme-to-dark
  else
    swap-theme-to-light
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
