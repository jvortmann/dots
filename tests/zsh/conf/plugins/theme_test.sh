#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
# shellcheck source=../../../fakes/fakes.sh
source "$ROOT/tests/fakes/fakes.sh"
PLUGIN="$ROOT/zsh/conf/plugins/theme.zsh"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh

function set_up() {
  [[ -f $PLUGIN ]] || bashunit::fail "missing the file under test: $PLUGIN"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  HOME_DIR=$(bashunit::temp_dir "home")
  DOTS=$(bashunit::temp_dir "dots")
  mkdir "$DOTS/herdr-app"
  ln -s "$DOTS" "$HOME_DIR/.dots"
  SETTINGS="$DOTS/herdr-app/settings.json"
}

function test_a_swap_to_light_changes_only_the_herdr_app_appearance() {
  settings_with_appearance '"appearance": "dark"' > "$SETTINGS"

  swap_theme_from_to dark light

  assert_same "$(settings_with_appearance '"appearance": "light"')" "$(cat "$SETTINGS")"
}

function test_a_swap_to_dark_changes_only_the_herdr_app_appearance() {
  settings_with_appearance '"appearance": "light"' > "$SETTINGS"

  swap_theme_from_to light dark

  assert_same "$(settings_with_appearance '"appearance": "dark"')" "$(cat "$SETTINGS")"
}

function test_a_swap_leaves_herdr_app_settings_with_no_appearance_unchanged() {
  settings_with_appearance '"sounds": {}' > "$SETTINGS"

  swap_theme_from_to dark light

  assert_same "$(settings_with_appearance '"sounds": {}')" "$(cat "$SETTINGS")"
}

# The app rewrites settings.json on its own. The swap must still find the
# appearance line in the form that the app writes.
function test_a_swap_changes_the_appearance_of_the_real_herdr_app_settings() {
  cp "$ROOT/herdr-app/settings.json" "$SETTINGS"
  local from=light to=dark
  [[ $(jq -r '.appearance' "$SETTINGS") == dark ]] && from=dark to=light

  swap_theme_from_to "$from" "$to"

  assert_same "$to" "$(jq -r '.appearance' "$SETTINGS")"
}

# Bat picks the light or dark theme from the terminal background, so the swap
# must leave its config alone.
function test_a_swap_leaves_the_bat_config_unchanged() {
  mkdir -p "$HOME_DIR/.config/bat"
  cp "$ROOT/bat/config" "$HOME_DIR/.config/bat/config"

  swap_theme_from_to light dark

  assert_same "$(cat "$ROOT/bat/config")" "$(cat "$HOME_DIR/.config/bat/config")"
}

function test_a_swap_leaves_the_nvim_background_unchanged() {
  local guioptions="$HOME_DIR/.config/nvim/lua/config/guioptions.lua"
  mkdir -p "$(dirname "$guioptions")"
  echo "vim.opt.background = 'dark'" > "$guioptions"

  swap_theme_from_to dark light

  assert_same "vim.opt.background = 'dark'" "$(cat "$guioptions")"
}

function test_after_a_swap_to_light_the_real_fzf_config_sets_the_light_fzf_theme() {
  swap_theme_from_to dark light

  assert_same "light" "$(fzf_theme_of_the_real_fzf_config)"
}

function test_the_fzf_config_of_a_new_machine_sets_the_dark_fzf_theme_quietly() {
  assert_same "dark" "$(fzf_theme_of_the_real_fzf_config)"
}

function test_swap_theme_on_a_new_machine_swaps_to_light_and_then_back_to_dark() {
  mkdir -p "$DOTS/zsh/conf/plugins"
  cp "$ROOT/zsh/conf/plugins/fzf.zsh" "$DOTS/zsh/conf/plugins/fzf.zsh"
  fake_tmux 'exit 1'

  assert_same "light
dark" "$(swap_theme_twice)"
}

function test_after_a_swap_to_light_ghostty_loads_the_light_theme() {
  command -v ghostty > /dev/null || bashunit::skip "needs ghostty"
  mkdir -p "$HOME_DIR/.config/ghostty"
  cp "$ROOT/ghostty/config" "$HOME_DIR/.config/ghostty/config"

  swap_theme_from_to dark light

  assert_same "theme = solarized-light" \
    "$(HOME="$HOME_DIR" XDG_CONFIG_HOME="$HOME_DIR/.config" ghostty +show-config --no-pager | rg '^theme = ')"
}

function test_after_a_swap_to_light_the_real_git_config_gives_delta_the_light_theme() {
  swap_theme_from_to dark light

  assert_same "Solarized (light)" \
    "$(HOME="$HOME_DIR" git config -f "$ROOT/git/config" --includes delta.syntax-theme)"
}

function test_after_a_swap_to_light_the_real_tmux_theme_loads_the_light_style() {
  mkdir -p "$DOTS/tmux/style"
  cp "$ROOT"/tmux/style/*.tmux "$DOTS/tmux/style/"

  swap_theme_from_to dark light

  assert_same "bg=brightwhite,fg=green" "$(tmux_status_style_of_the_real_theme)"
}

function test_the_session_popup_of_a_new_machine_runs_fzf_with_the_dark_colors() {
  assert_contains "--color=dark " "$(fzf_arguments_of_the_real_session_popup)"
}

function test_after_a_swap_to_light_the_session_popup_runs_fzf_with_the_light_colors() {
  swap_theme_from_to dark light

  assert_contains "--color=light " "$(fzf_arguments_of_the_real_session_popup)"
}

function test_a_swap_to_light_leaves_the_real_tracked_configs_unchanged() {
  local file files=(ghostty/config git/config tmux/switch-popup.tmux tmux/theme.tmux zsh/conf/plugins/fzf.zsh)
  for file in "${files[@]}"; do
    mkdir -p "$DOTS/$(dirname "$file")"
    cp "$ROOT/$file" "$DOTS/$file"
  done

  swap_theme_from_to dark light

  assert_same "" "$(for file in "${files[@]}"; do diff "$ROOT/$file" "$DOTS/$file"; done)"
}

function test_a_refresh_with_no_tmux_server_prints_nothing() {
  fake_tmux 'echo "error connecting to /private/tmp/tmux-501/default (No such file or directory)" >&2; exit 1'

  assert_same "" "$(swap_theme_refresh)"
}

function test_a_refresh_with_a_tmux_server_shows_the_errors_of_both_tmux_files() {
  fake_tmux '[ "$1" = has-session ] && exit 0; echo "error in $2" >&2; exit 1'

  assert_same "error in $HOME_DIR/.dots/tmux/theme.tmux
error in $HOME_DIR/.dots/tmux/switch-popup.tmux" "$(swap_theme_refresh)"
}

# Every path the swap edits starts at HOME. The scratch HOME holds only the
# files that the test writes, so the other gsed calls find no file and the run
# changes no file of the user.
swap_theme_from_to() {
  HOME="$HOME_DIR" "$HOMEBREW_ZSH" -f -c "source ${PLUGIN@Q}; swap-theme-from-to $1 $2" > /dev/null 2>&1
}

# Sources the real fzf config under the scratch HOME. Prints its output and
# its errors, then the fzf theme it sets.
fzf_theme_of_the_real_fzf_config() {
  HOME="$HOME_DIR" "$HOMEBREW_ZSH" -f -c "source ${ROOT@Q}/zsh/conf/plugins/fzf.zsh; print -r -- \$FZF_THEME" 2>&1 < /dev/null
}

# Runs the refresh with the fake tmux and an empty fzf config, and prints all
# that it writes.
swap_theme_refresh() {
  mkdir -p "$DOTS/zsh/conf/plugins"
  : > "$DOTS/zsh/conf/plugins/fzf.zsh"
  HOME="$HOME_DIR" PATH="$HOME_DIR/bin:$PATH" "$HOMEBREW_ZSH" -f -c "source ${PLUGIN@Q}; swap-theme-refresh" 2>&1 < /dev/null
}

# Runs swap-theme twice in one shell, with the fake tmux. Prints the fzf theme
# after each run.
swap_theme_twice() {
  HOME="$HOME_DIR" PATH="$HOME_DIR/bin:$PATH" "$HOMEBREW_ZSH" -f -c \
    "source ${PLUGIN@Q}; repeat 2 { swap-theme; print -r -- \$FZF_THEME }" 2> /dev/null < /dev/null
}

tmux_status_style_of_the_real_theme() {
  in_a_new_tmux_server source-file "$ROOT/tmux/theme.tmux" \; show-options -gv status-style
}

# Takes the shell command of the real session popup from its key binding, and
# runs it with a fake tmux and a fake fzf. Prints the arguments that fzf gets.
fzf_arguments_of_the_real_session_popup() {
  local command
  command=$(in_a_new_tmux_server source-file "$ROOT/tmux/switch-popup.tmux" \; list-keys -T prefix C-f)
  command=${command#*display-popup -E \"}
  fake_tmux ':'
  fake_program "$HOME_DIR/bin" fzf 'echo "$@ " > "$HOME/fzf-arguments"'
  HOME="$HOME_DIR" PATH="$HOME_DIR/bin:$PATH" sh -c "${command%\"}" < /dev/null
  cat "$HOME_DIR/fzf-arguments"
}

# Runs the tmux commands $@ in a tmux server of its own, under the scratch HOME.
# The server has no session, so it ends after the commands. Its socket stays,
# so this function removes it.
in_a_new_tmux_server() {
  local server="bashunit-$$-$RANDOM"
  HOME="$HOME_DIR" tmux -L "$server" -f /dev/null start-server \; "$@"
  rm -f "${TMUX_TMPDIR:-/tmp}/tmux-$UID/$server"
}

# Puts a fake tmux that runs the shell code $1 first on the PATH of the
# refresh.
fake_tmux() {
  fake_program "$HOME_DIR/bin" tmux "$1"
}

# Herdr app settings as the app writes them, with the given line before the
# theme.
settings_with_appearance() {
  printf '{\n  "zoom": 1.0,\n  "minimum_contrast": 1.0,\n  %s,\n  "theme": {\n    "light": "solarized-light",\n    "dark": "solarized-dark"\n  }\n}\n' "$1"
}
