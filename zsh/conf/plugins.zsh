zplug "$ZSH_HOME/conf/plugins", from:local

zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting"

zplug 'zplug/zplug', hook-build:'zplug --self-manage'

zplug load
