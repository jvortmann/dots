echo ">> Setup of tools"

tools='
bat
ctags
fd
ghostty
iex
karabiner
mise
orbstack
pi
tmux
zsh
'

for tool in $tools; do
  setup_file="$HOME/.dots/$tool/setup.sh"

  [ -f "$setup_file" ] && $setup_file
done
