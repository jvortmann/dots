# vim: ft=tmux

# status line
set-option -g status-left-length 50
set-option -g status-style "bg=brightwhite,fg=green"
set-option -g status-left "#[fg=green]#{?client_prefix,#[fg=blue],} #S #[fg=green]#{?client_prefix,#[fg=blue],}"
set-option -g status-right "#[bg=default,fg=green,nobold,nounderscore,noitalics] #(hostname -s) %a %d/%m/%y %R "

# windows
set-window-option -g window-status-format "#[bg=default,fg=green] #I #W "
set-window-option -g window-status-current-format "#[bg=white,fg=blue] #I #W "
set-window-option -g window-status-activity-style "bg=default,fg=green"

# panes
set-option -g pane-border-style "fg=white"
set-option -g pane-active-border-style "fg=brightwhite"
set-option -g display-panes-active-colour "blue"
set-option -g display-panes-colour "green"

# popup
set-option -g popup-border-style "fg=white"
set-option -g popup-style "fg=default"

## message text
set-option -g message-style "bg=default,fg=brightred"

## clock
set-window-option -g clock-mode-colour "blue"
