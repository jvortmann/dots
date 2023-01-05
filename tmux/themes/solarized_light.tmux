# vim: ft=conf

#### COLOUR (Solarized light)
# status line
set-option -g status-left-length 50
set-option -g status-style "bg=white,fg=yellow"
set-option -g status-left "#{?client_prefix,#[fg=blue],} #S #{?client_prefix,#[fg=blue],}"

set-option -g status-right "#[fg=green,bg=default,nobold,nounderscore,noitalics] #(hostname -s) %a %d/%m/%y %R "

# windows
set-window-option -g window-status-format "#[fg=default,bg=default] #I #W "
set-window-option -g window-status-current-format "#[fg=blue,bg=gray] #I #W "
set-window-option -g window-status-activity-style "bg=default,fg=green"

# panes
set-option -g pane-border-style "fg=white"
set-option -g pane-active-border-style "fg=gray"
set-option -g display-panes-active-colour "blue"
set-option -g display-panes-colour "green"

## message text
set-option -g message-style "bg=default,fg=brightred"

## clock
set-window-option -g clock-mode-colour "blue"
