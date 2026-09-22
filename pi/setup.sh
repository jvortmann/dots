echo ">> [pi] Coding agent"
echo ">> [pi] Setting symlink for 'pi config'"
# The folder, because pi writes auth.json, sessions, cache, npm and git into
# it. The entries in git/ignore keep that state out of the repository.
ln -sfnv ~/.dots/pi ~/.config/pi
