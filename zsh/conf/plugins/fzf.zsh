export FZF_DEFAULT_COMMAND="rg --files -. -g '!**/vendor/cache/**/*.gem' -g '!.git/**'"
export FZF_DEFAULT_OPTS="--color=dark --border=sharp --preview-window=border-sharp"

eval "$(fzf --zsh)"
