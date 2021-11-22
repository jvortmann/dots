# vim: ft=zsh

cleanup_episode_filename() {
  mv -v "$1" "$(echo "$1" | sed -E "s/(.*)\.([sS][[:digit:]]{2}[eE][[:digit:]]{2})(.*)?(\.1080|720).*(\..{3})$/\1 - \2 - \3\5/" | tr "." " " | tr -s " " | sed -E "s/(.*) (.{3})$/\1.\2/")"
}

line () {
  head -n"$1" "$2" | tail -n1
}
