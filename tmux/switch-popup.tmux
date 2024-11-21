# vim: ft=tmux

# sessions with fuzzy finder
bind C-f display-popup -E "tmux list-sessions -F '#{session_activity} #S#{?session_attached,*,}' | sort -r | cut -d' ' -f2-3 | grep -v '*' | fzf --reverse --border=none --color=dark | xargs tmux switch-client -t"
