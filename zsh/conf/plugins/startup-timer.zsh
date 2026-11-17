# vim: ft=zsh

_startup_timer_start() {
  STARTUP_MARKS[precmd_start]=$EPOCHREALTIME
  precmd_functions=(${precmd_functions:#_startup_timer_start})
}
(( ${+STARTUP_MARKS[precmd_start]} )) ||
  precmd_functions=(_startup_timer_start $precmd_functions)

_startup_timer_stop() {
  STARTUP_MARKS[precmd_end]=$EPOCHREALTIME
  precmd_functions=(${precmd_functions:#_startup_timer_stop})
  _startup_first_mark
  (( LAST_COMMAND_TIME = (STARTUP_MARKS[precmd_end] - REPLY) * 1000 ))
}

startup-times() {
  local -a names=(shell init_start init_end precmd_start precmd_end)
  local -a labels=("system files" init.zsh "after init.zsh" precmd)
  local i
  for (( i = 1; i < $#names; i++ )); do
    [[ -n $STARTUP_MARKS[$names[i]] && -n $STARTUP_MARKS[$names[i+1]] ]] &&
      _startup_time_line $labels[i] $STARTUP_MARKS[$names[i]] $STARTUP_MARKS[$names[i+1]]
  done
  _startup_first_mark
  _startup_time_line total $REPLY $STARTUP_MARKS[precmd_end]
}

_startup_first_mark() {
  REPLY=${STARTUP_MARKS[shell]:-$STARTUP_MARKS[init_start]}
}

_startup_time_line() {
  printf '%-15s %6.1f ms\n' $1 $(( ($3 - $2) * 1000 ))
}
