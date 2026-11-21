# vim: ft=zsh

# In a Herdr terminal, record the command line of nvim or pi in the label
# restore.cmd of the terminal, so that a lost terminal can start it again. The
# label goes when the command ends. A shell clears only a label that it wrote,
# because a new shell in a lost terminal must keep the label of the program
# that it replaces. hc is not on PATH, and it runs in the background, so the
# prompt does not wait for it.

# The names of nvim: the command and its aliases in zsh/conf/lib/aliases.
_herdr_restore_nvim='(nvim|vim|vi|v|n)'

_herdr_restore_preexec() {
  unset _herdr_restore_ending
  [[ -n $HC_TERMINAL_ID && ${${(Az)1}[1]} == ($~_herdr_restore_nvim|pi) ]] || return
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

# At its first prompt, each Herdr shell reads the labels of its terminal. A lost
# terminal still has them, so the shell starts nvim or pi again. A new terminal
# has none, and its shell stays a shell. The shell types the line after the
# whole zsh config loads, so the aliases and the PATH from mise apply. The line
# runs as a typed command: the shell stays when it ends, and preexec records it
# again. pi resumes its session file, or continues the last session when pi
# wrote no file. nvim loads its session file when restore.nvim names a file that
# exists. A clean quit of nvim removes the file, so the shell then runs the
# typed line. A restore.pi label with no pi in restore.cmd comes from a pi
# that ended, so the shell stays a shell. The shell removes the labels before it
# runs the line, so a program that fails at once does not start again in the
# next shell.
_herdr_restore_relaunch() {
  add-zle-hook-widget -d line-init _herdr_restore_relaunch
  local -a labels=("${(@0)$($HOME/.local/bin/hc get $HC_TERMINAL_ID --json 2> /dev/null |
    jq --raw-output0 '.labels | .["restore.cmd"] // "", .["restore.pi"] // "", .["restore.nvim"] // ""' 2> /dev/null)}")
  local cmd=$labels[1] file=$labels[2] session=$labels[3]
  case ${${(Az)cmd}[1]} in
    (pi)
      if [[ -f $file ]]; then
        BUFFER="pi --session ${(q)file}"
      else
        BUFFER="pi --continue"
      fi
      ;;
    ($~_herdr_restore_nvim)
      if [[ -f $session ]]; then
        BUFFER="nvim -S ${(q)session}"
      else
        BUFFER=$cmd
      fi
      ;;
    (*) return ;;
  esac
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
