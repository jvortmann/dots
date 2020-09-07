# vim: ft=conf

#### COLOUR (Solarized dark)
# status line
set-option -g status-left-length 32
set-option -g status-left "[#S]"
set-option -g status-right "\"#(hostname -s)\" %H:%M %d-%b-%y"

# default statusbar colors
set-option -g status-style bg=black,fg=yellow #,attr=default

# default window title colors
set-window-option -g window-status-style bg=default,fg=brightblue #,attr=dim

# active window title colors
set-window-option -g window-status-current-style bg=brightblue,fg=black #,attr=dim

# window with activity colors
set-window-option -g window-status-activity-style bg=black,fg=brightred

# pane border
set-option -g pane-border-style fg=black #base02
set-option -g pane-active-border-style fg=brightgreen #base01

# message text
set-option -g message-style bg=black,fg=brightred

# pane number display
set-option -g display-panes-active-colour blue #blue
set-option -g display-panes-colour brightred #orange

# clock
set-window-option -g clock-mode-colour green #green
