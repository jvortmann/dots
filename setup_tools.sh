echo ">> Setup of tools"

tools='asdf bat ctags karabiner'

for tool in $tools; do
  setup_file="$HOME/.dots/$tool/setup.sh"

  [ -f "$setup_file" ] && $setup_file
done
