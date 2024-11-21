# vim: ft=tmux

# List of plugins
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-pain-control'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/vim-tmux-focus-events'
set -g @plugin 'wfxr/tmux-fzf-url'

# restore sessions when tmux server starts
set -g @continuum-restore 'on'

# change save and restore key binding to less error prone ones
set -g @resurrect-save 'M-s'
set -g @resurrect-restore 'M-r'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
