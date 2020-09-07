# vim: ft=conf

#### COLOUR (Solarized light)
## default statusbar colors
set-option -g status-style bg=white #base2
set-option -g status-style fg=yellow #yellow
set-option -g status-style attr=default

## default window title colors
set-window-option -g window-status-style fg=brightyellow #base00
set-window-option -g window-status-style bg=default
#set-window-option -g window-status-style attr=dim

## active window title colors
set-window-option -g window-status-current-style fg=brightred #orange
set-window-option -g window-status-current-style bg=default
#set-window-option -g window-status-current-style attr=bright

## pane border
set-option -g pane-border-style fg=white #base2
set-option -g pane-active-border-style fg=brightcyan #base1

## message text
set-option -g message-style bg=white #base2
set-option -g message-style fg=brightred #orange

## pane number display
set-option -g display-panes-active-colour blue #blue
set-option -g display-panes-colour brightred #orange

## clock
set-window-option -g clock-mode-colour green #green
