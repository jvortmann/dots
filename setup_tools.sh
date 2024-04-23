echo ">> Setup of tools"

tools='
bat
colima
ctags
fd
karabiner
mise
tmux
zsh
'

for tool in $tools; do
  setup_file="$HOME/.dots/$tool/setup.sh"

  [ -f "$setup_file" ] && $setup_file
done
