# vim: ft=conf

#### COLOUR (Solarized dark)
# status line
set-option -g status-left-length 50
set-option -g status-left "#[bg=green,fg=black]#{?client_prefix,#[bg=yellow],} #S #[fg=green,bg=black]#{?client_prefix,#[fg=yellow],}"
set-option -g status-right "#[fg=blue,bg=default,nobold,nounderscore,noitalics] #(hostname -s) %a %d/%m/%y %R "

# windows
set-window-option -g window-status-current-format "#[fg=black,bg=blue] #I #W "
set-window-option -g window-status-format "#[fg=default]#[bg=default] #I #W "
set-window-option -g window-status-activity-style "bg=black,fg=yellow"

# panes
set-option -g pane-border-style "fg=black"
set-option -g pane-active-border-style "fg=green"
set-option -g display-panes-active-colour "green"
set-option -g display-panes-colour "blue"

# message text
set-option -g message-style "bg=black,fg=brightred"

# clock
set-window-option -g clock-mode-colour "green"
