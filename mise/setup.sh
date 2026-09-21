echo; echo ">> Setting symlink for 'mise' language version manager"
mkdir -p ~/.config/mise/
# The file, and not the folder every other tool here links. mise writes its
# settings into config.toml itself, so a folder link would only offer its state
# a place to land in the repository.
ln -sfnv ~/.dots/mise/config.toml ~/.config/mise/config.toml
