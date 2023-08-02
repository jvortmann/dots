# vim: ft=zsh

fpath=($ZSH_HOME/completions /usr/local/share/zsh/site-functions /usr/local/share/zsh-completions $fpath)

# Load and run compinit
autoload -U compinit
#compinit -i

unsetopt MENU_COMPLETE   # do not autoselect the first completion entry
setopt AUTO_MENU         # show completion menu on succesive tab press

setopt COMPLETE_IN_WORD  # in word completion
setopt ALWAYS_TO_END

WORDCHARS='~!#$%^&*(){}[]<>?+;' # for the "normal" style

zmodload -i zsh/complist

## all, partial-word and then substring completion
zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'  'r:|[._-]=* r:|=*' '+l:|=* r:|=*'

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
cdpath=(.)

zstyle ':completion:*:hosts' hosts $hosts

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
#zstyle ':completion::complete:*' cache-path ~/.oh-my-zsh/cache/

expand-or-complete-with-dots() {
  echo -n "\e[31m......\e[0m"
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots
