# vim: ft=zsh

# In a Herdr terminal, record the command line of nvim or pi in the label
# restore.cmd of the terminal, so that a lost terminal can start it again. The
# label goes when the command ends. A shell clears only a label that it wrote,
# because a new shell in a lost terminal must keep the label of the program
# that it replaces. hc is not on PATH, and it runs in the background, so the
# prompt does not wait for it.
_herdr_restore_preexec() {
  unset _herdr_restore_ending
  [[ -n $HC_TERMINAL_ID && ${${(Az)1}[1]} == (nvim|vim|vi|v|pi) ]] || return
  _herdr_restore_label_after "$_herdr_restore_clearing" "$1"
  _herdr_restore_recorded=$!
}

_herdr_restore_precmd() {
  [[ -n $_herdr_restore_recorded && -z $_herdr_restore_ending ]] || return
  # A command that ends at once must not leave its label, so the clear waits
  # until the write ends.
  _herdr_restore_label_after "$_herdr_restore_recorded" ""
  _herdr_restore_clearing=$!
  unset _herdr_restore_recorded
}

# Sets restore.cmd to $2, or removes it when $2 is empty, in the background,
# after the process $1 ends. So the writes reach hc in the order of the commands.
_herdr_restore_label_after() {
  {
    while kill -0 $1 2> /dev/null; do sleep 0.1; done
    $HOME/.local/bin/hc label $HC_TERMINAL_ID "restore.cmd=$2" > /dev/null 2>&1
  } &!
}

# At a reboot, SIGTERM ends pi, but an interactive zsh ignores it and goes on to
# the prompt. The label must stay then, so the flag makes precmd skip the clear.
# The next command resets the flag, because a shell that lives on must clear its
# labels again.
# zsh ends on SIGHUP before the prompt, so SIGHUP needs no trap. A trap would
# keep zsh alive to clear the label.
TRAPTERM() {
  _herdr_restore_ending=1
}

preexec_functions+=(_herdr_restore_preexec)
precmd_functions+=(_herdr_restore_precmd)
