# vim: ft=zsh

# In a Herdr terminal, nvim and pi each name their session file in a label of
# the terminal: restore.nvim or restore.pi. When the user quits, nvim removes
# its file and pi removes its label. A signal or a crash removes neither. At
# shutdown, nvim or pi can end before zsh gets SIGTERM. zsh then reaches its
# prompt and clears restore.cmd. So a label that names a file that exists tells
# the new shell to start that program again.
#
# This plugin also records the command line of nvim or pi in the label
# restore.cmd, for a program that left no session file. The label goes when the
# command ends. A shell clears only a label that it wrote, because a new shell
# in a lost terminal must keep the label of the program that it replaces. hc is
# not on PATH. The writes of restore.cmd run in the background, so the command
# and the prompt do not wait for them. Only the clear of restore.nvim and
# restore.pi runs before the command starts.
#
# In a Herdr terminal, an nvim line also runs with HERDR_RESTORE_NVIM=1 in its
# environment. The variable tells nvim that a typed line started it, so nvim
# can save its session and a lost terminal can start it again. The shell gives
# the variable to no nvim that another program starts, such as the commit
# editor of git. preexec removes the variable before each command, so no other
# command keeps it.

# The names of nvim: the command and its aliases in zsh/conf/lib/aliases.
_herdr_restore_nvim='(nvim|vim|vi|v|n)'

_herdr_restore_preexec() {
  unset _herdr_restore_ending HERDR_RESTORE_NVIM
  local word=${${(Az)1}[1]}
  [[ -n $HC_TERMINAL_ID && $word == ($~_herdr_restore_nvim|pi) ]] || return
  _herdr_restore_label_after "$_herdr_restore_clearing" "$1"
  _herdr_restore_recorded=$!
  # A line of nvim or pi also clears restore.nvim and restore.pi, the labels of
  # an earlier program. The new program labels itself again, and a program that
  # saves no session, such as nvim --clean, leaves no label. So only the label
  # of the last program stays. The call runs in the foreground, because one in
  # the background could land after the label of the new program. It costs
  # about 9 milliseconds.
  $HOME/.local/bin/hc label $HC_TERMINAL_ID restore.nvim= restore.pi= > /dev/null 2>&1
  [[ $word == $~_herdr_restore_nvim ]] && export HERDR_RESTORE_NVIM=1
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

# At its first prompt, each Herdr shell reads the labels of its terminal. A lost
# terminal still has them, so the shell starts nvim or pi again. A new terminal
# has none, and its shell stays a shell. The shell types the line after the
# whole zsh config loads, so the aliases and the PATH from mise apply. The line
# runs as a typed command: the shell stays when it ends, and preexec records it
# again. When restore.nvim names a file that exists, nvim loads that session.
# If not, when restore.pi names a file that exists, pi resumes that session.
# Both work with no restore.cmd. With no session file, the shell uses
# restore.cmd: pi continues the last session, and nvim runs the typed line. The
# shell removes the labels before it runs the line, so a program that fails at
# once does not start again in the next shell.
_herdr_restore_relaunch() {
  add-zle-hook-widget -d line-init _herdr_restore_relaunch
  local -a labels=("${(@0)$($HOME/.local/bin/hc get $HC_TERMINAL_ID --json 2> /dev/null |
    jq --raw-output0 '.labels | .["restore.cmd"] // "", .["restore.pi"] // "", .["restore.nvim"] // ""' 2> /dev/null)}")
  local cmd=$labels[1] file=$labels[2] session=$labels[3]
  if [[ -f $session ]]; then
    BUFFER="nvim -S ${(q)session}"
  elif [[ -f $file ]]; then
    BUFFER="pi --session ${(q)file}"
  else
    case ${${(Az)cmd}[1]} in
      (pi) BUFFER="pi --continue" ;;
      ($~_herdr_restore_nvim) BUFFER=$cmd ;;
      (*) return ;;
    esac
  fi
  $HOME/.local/bin/hc label $HC_TERMINAL_ID restore.cmd= restore.pi= restore.nvim= > /dev/null 2>&1
  zle .accept-line
}

preexec_functions+=(_herdr_restore_preexec)
precmd_functions+=(_herdr_restore_precmd)
# Herdr starts zsh as a login shell. A subshell and the shell in nvim :terminal
# are not login shells, and outside Herdr HC_TERMINAL_ID is not set. hc and jq
# take about 5 milliseconds, once for each new Herdr shell.
if [[ -n $HC_TERMINAL_ID && -o login ]]; then
  autoload -Uz add-zle-hook-widget
  add-zle-hook-widget line-init _herdr_restore_relaunch
fi
