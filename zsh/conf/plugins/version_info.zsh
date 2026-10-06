# vim: ft=zsh

language_info() {
  local tools=$(active_tools)
  [[ -z $tools ]] && return

  local result=""
  local tool version

  while read -r tool version; do
    result+="$(format_version $tool $version)"
  done <<< "$tools"

  echo "$result"
}

active_tools() {
  if command -v mise &> /dev/null; then
    # mise prints the resolved path, so inside the dots repository the global
    # config shows as ~/prj/... and never as ~/.config/mise/config.toml.
    local global_config=~/.config/mise/config.toml
    global_config=${global_config:A}
    global_config=${global_config/#$HOME/\~}

    # One row per language: a backend tool such as npm: carries a colon and
    # never changes per project, and a tool with two versions repeats.
    local all_tools=$(mise ls --current 2>/dev/null | awk '$1 !~ /:/ && !seen[$1]++')
    [[ -z $all_tools ]] && return

    # Keep the tools of a project config. No grep here, for the same reason
    # as in git_status.
    local row local_tools=()
    for row in ${(f)all_tools}; do
      [[ $row == *"$global_config"* || $row == *.config/mise/config.toml* ]] && continue
      local_tools+=("${${=row}[1]} ${${=row}[2]}")
    done

    if (( $#local_tools )); then
      print -rl -- $local_tools
    else
      awk '{print $1, $2}' <<< "$all_tools"
    fi
  elif [[ -f "$PWD/.tool-versions" ]]; then
    awk '{print $1, $2}' "$PWD/.tool-versions"
  else
    local tool version
    for tool in clojure deno elixir erlang go java lua node python ruby rust; do
      if [[ -f "$PWD/.${tool}-version" ]]; then
        version=$(< "$PWD/.${tool}-version")
        [[ -n $version ]] && echo "$tool $version"
      fi
    done
  fi
}

format_version() {
  local tool=$1
  local version=$2
  local color=$(tool_color $tool)

  echo "${color}[${tool}:${version}]${RESET}"
}

tool_color() {
  local tool=$1

  case $tool in
    clojure) echo "$ORANGE" ;;
    deno)    echo "$GREEN" ;;
    elixir)  echo "$PURPLE" ;;
    erlang)  echo "$MAGENTA" ;;
    go)      echo "$LIGHT_BLUE" ;;
    java)    echo "$BROWN" ;;
    lua)     echo "$DEEP_PURPLE" ;;
    node)    echo "$HI_YELLOW" ;;
    python)  echo "$HI_BLUE" ;;
    ruby)    echo "$RED" ;;
    rust)    echo "$LIGHT_BROWN" ;;
    *)       echo "" ;;
  esac
}
