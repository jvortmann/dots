echo ">> Setup of tools"

tools='asdf iex ctags'

for tool in $tools; do
  setup_file="$HOME/.dots/$tool/setup.sh"

  [ -f "$setup_file" ] && $setup_file
done
