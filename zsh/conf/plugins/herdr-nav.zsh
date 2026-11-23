# vim: ft=zsh

# In a Herdr terminal, ctrl-h/j/k/l move the Herdr pane left, down, up and
# right. keys.json no longer sends these keys to the program. The nav mod
# (herdr-app/mods/nav) moves the pane, and sends the key on to nvim for its
# windows. These widgets stay as a fallback. Herdr updates the program of a
# pane 0.4 to 0.9 seconds late, so just after nvim quits the mod can still send
# the key on to zsh. Here zsh loses their widgets, such as kill-line on ctrl-k
# and the clear on ctrl-l.
# keys.json sends ctrl-a ctrl-k as ctrl-alt-k in the CSI u form (\e[107;7u),
# and ctrl-a ctrl-j as ctrl-alt-j (\e[106;7u). It sends ctrl-a ctrl-l as the
# CSI u form of ctrl-l. pi cannot tell the CSI u form of ctrl-k from ctrl-k,
# so ctrl-k uses alt. This plugin binds these forms to the widgets that
# ctrl-k, ctrl-j and ctrl-l had. So ctrl-a ctrl-k kills, ctrl-a ctrl-j runs
# the line (accept-line), and ctrl-a ctrl-l clears. It reads those widgets
# when it loads, so it must load after lib/clear-screen. A second load keeps
# the widgets of these forms.
# herdr-app is not on PATH. The pane move runs in the background, so the shell
# does not wait, and its output stays off the screen.
# Outside Herdr, HC_TERMINAL_ID is not set and the keys keep their widgets.
# The plugin does not test TMUX, because a Herdr terminal can get TMUX from the
# shell that started the app.

_herdr_nav_go() {
  $HOME/.local/bin/herdr-app do pane.go "{\"direction\":\"${WIDGET#_herdr_nav_}\"}" &> /dev/null &!
}

if [[ -n $HC_TERMINAL_ID ]]; then
  () {
    local key csi_u widget direction
    for key csi_u in '^J' '\e[106;7u' '^K' '\e[107;7u' '^L' '\e[108;5u'; do
      widget=${${(z)"$(bindkey $key)"}[2]}
      [[ $widget == _herdr_nav_* ]] || bindkey $csi_u $widget
    done
    for key direction in '^H' left '^J' down '^K' up '^L' right; do
      zle -N _herdr_nav_$direction _herdr_nav_go
      bindkey $key _herdr_nav_$direction
    done
  }
fi
