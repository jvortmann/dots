echo ">> [Bat] Smarter cat"
echo ">> [Bat] Setting symlink for 'bat config'"
ln -sfnv ~/.dots/bat ~/.config/bat

echo; echo ">> [Bat] Rebuilding cache"
bat cache --build
