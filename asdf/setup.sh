echo ">> [ASDF] language version mannager"
echo ">> [ASDF]  Setting symlink for 'asdfrc'"
ln -sfnv ~/.dots/asdf/asdfrc ~/.asdfrc

echo; echo ">> [ASDF] Adding plugins"
asdf plugin-add clojure
asdf install clojure latest
asdf global clojure latest
asdf plugin-add elixir
asdf install elixir latest
asdf global elixir latest
asdf plugin-add elm
asdf install elm latest
asdf global elm latest
asdf plugin-add erlang
asdf install erlang latest
asdf global erlang latest
asdf plugin-add golang
asdf install golang latest
asdf global golang latest
asdf plugin-add java
asdf install java latest
asdf global java latest
asdf plugin-add lua
asdf install lua latest
asdf global lua latest
asdf plugin-add nodejs
asdf install nodejs latest
asdf global nodejs latest
asdf plugin-add python
asdf install python latest
asdf global python latest
asdf plugin-add ruby
asdf install ruby latest
asdf global ruby latest
asdf plugin-add rust
asdf install rust latest
asdf global rust latest
asdf plugin-add yarn
asdf install yarn latest
asdf global yarn latest
