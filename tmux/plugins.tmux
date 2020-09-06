# vim: ft=conf

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-pain-control'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/vim-tmux-focus-events'
set -g @plugin 'wfxr/tmux-fzf-url'

# theme
#set -g @plugin 'dracula/tmux'
#set -g @dracula-show-battery false
#set -g @dracula-show-network false
#set -g @dracula-show-weather false
#set -g @dracula-show-left-icon session
#set -g @dracula-border-contrast true
#set -g @dracula-cpu-usage false
#set -g @dracula-ram-usage false
#set -g @dracula-gpu-usage false
#set -g @dracula-day-month true

# restore sessions when tmux server starts
set -g @continuum-restore 'on'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
