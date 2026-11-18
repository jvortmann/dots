#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
VIEW="$ROOT/herdr-app/mods/copy-mode/view.sh"

function set_up() {
  [[ -f $VIEW ]] || bashunit::fail "missing the file under test: $VIEW"
  SCRATCH=$(bashunit::temp_dir "copy-mode")
  mkdir -p "$SCRATCH/bin"
  fake hc "$(cat << 'EOF'
printf '%s\n' "$*" > "$SCRATCH/hc.args"
case " $* " in
  *" --json "*) printf '{"complete":%s,"text":"line one\\nline two"}\n' "${COMPLETE:-true}" ;;
  *) printf 'line one\nline two\n'
    [ "${COMPLETE:-true}" = true ] || printf '[hc] incomplete: older output may be missing\n' ;;
esac
EOF
  )"
  fake nvim 'for file; do :; done; cp "$file" "$SCRATCH/shown"; printf "%s" "$file" > "$SCRATCH/path"
    printf "%s\n" "$*" > "$SCRATCH/nvim.args"'
}

function test_shows_the_text_of_the_terminal_in_nvim() {
  view t7

  assert_same $'line one\nline two' "$(cat "$SCRATCH/shown")"
}

function test_leaves_out_the_note_that_older_output_is_missing() {
  COMPLETE=false view t7

  assert_same $'line one\nline two' "$(cat "$SCRATCH/shown")"
}

function test_opens_no_nvim_when_hc_cannot_read_the_terminal() {
  fake hc 'exit 3'

  view t7

  assert_file_not_exists "$SCRATCH/shown"
}

function test_reads_the_screen_and_10000_lines_of_history_above_it() {
  view t7

  assert_same "read --json --lines 10000 t7" "$(cat "$SCRATCH/hc.args")"
}

function test_removes_the_text_when_nvim_closes() {
  view t7

  assert_file_not_exists "$(cat "$SCRATCH/path")"
}

function test_removes_the_text_when_the_terminal_hangs_up() {
  fake nvim 'for file; do :; done; printf "%s" "$file" > "$SCRATCH/path"; kill -HUP $PPID; exit 129'

  view t7

  assert_file_not_exists "$(cat "$SCRATCH/path")"
}

function test_opens_the_text_read_only_with_the_copy_mode_config_and_no_user_config() {
  view t7

  assert_same "--clean -u $(dirname "$VIEW")/nvim.lua --noplugin -n -R -M -- $(cat "$SCRATCH/path")" \
    "$(cat "$SCRATCH/nvim.args")"
}

function test_finds_hc_and_nvim_on_the_bare_path_of_the_core() {
  mkdir -p "$SCRATCH/home/.local"
  mv "$SCRATCH/bin" "$SCRATCH/home/.local/bin"

  HOME="$SCRATCH/home" SCRATCH="$SCRATCH" PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/sh "$VIEW" t7

  assert_same $'line one\nline two' "$(cat "$SCRATCH/shown")"
}

view() {
  SCRATCH="$SCRATCH" PATH="$SCRATCH/bin:$PATH" sh "$VIEW" "$@"
}

# Puts a program called $1 first on the PATH of view, which runs the shell
# code in $2.
fake() {
  printf '#!/bin/sh\n%s\n' "$2" > "$SCRATCH/bin/$1"
  chmod +x "$SCRATCH/bin/$1"
}
