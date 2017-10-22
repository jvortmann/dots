# vim: ft=zsh

cache() {
  local cache_path="$1"
  local cache_time="$2"
  local cache_command="$3"
  local else_command="$4"
  local cache_is_old=$(find "$cache_path" -mtime -"$cache_time" 2> /dev/null)

  if [ ! -r "$cache_is_old" ]; then
    eval "$cache_command" > $cache_path
  else
    eval "$else_command"
  fi
}
