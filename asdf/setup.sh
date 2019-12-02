echo ">> [ASDF] language version mannager"
echo ">> [ASDF]  Setting symlink for 'asdfrc'"
ln -sfnv ~/.dots/asdf/asdfrc ~/.asdfrc

echo; echo ">> [ASDF] Adding plugins"
asdf plugin-add clojure
asdf plugin-add elixir
asdf plugin-add erlang
asdf plugin-add golang
asdf plugin-add java
asdf plugin-add lua
asdf plugin-add nodejs
asdf plugin-add python
asdf plugin-add ruby
asdf plugin-add rust
asdf plugin-add yarn
