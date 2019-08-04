echo ">> [ASDF] language version mannager"
echo ">> [ASDF]  Setting symlink for 'asdfrc'"
ln -sfnv ~/.dots/asdf/asdfrc ~/.asdfrc

echo; echo ">> [ASDF] Adding plugins"
asdf plugin-add ruby
asdf plugin-add rust
asdf plugin-add elixir
asdf plugin-add python
asdf plugin-add golang
asdf plugin-add erlang
