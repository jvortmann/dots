#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
CONFIG="$ROOT/herdr-app/mods/copy-mode/nvim.lua"

function set_up() {
  [[ -f $CONFIG ]] || bashunit::fail "missing the file under test: $CONFIG"
  command -v nvim > /dev/null || bashunit::skip "needs nvim"
  SCRATCH=$(bashunit::temp_dir "copy-mode")
  mkdir -p "$SCRATCH/bin"
  fake pbcopy 'cat > "$SCRATCH/clipboard"'
  fake hc 'case $1 in
    get) printf "{\"cols\":40,\"rows\":%s}\n" "$(cat "$SCRATCH/rows")" ;;
    *) printf "%s\n" "$*" > "$SCRATCH/hc.args"; cat "$SCRATCH/paint"; exec sleep 5 ;;
  esac'
  paint "old 1|old 2" "out a|out b|prompt> ls" 3 11
}

function test_shows_the_history_above_the_screen() {
  press "ggVy"

  assert_same "old 1" "$(cat "$SCRATCH/clipboard")"
}

function test_reads_10000_lines_of_history_above_the_screen() {
  press "q"

  assert_same "attach --observe --history 10000 t7" "$(cat "$SCRATCH/hc.args")"
}

function test_keeps_the_oldest_of_10000_lines_of_history() {
  paint "$(seq -f 'line %g' 1 10000 | paste -sd '|' -)" "prompt>" 1 8

  press "ggVy"

  assert_same "line 1" "$(cat "$SCRATCH/clipboard")"
}

function test_starts_on_the_line_of_the_terminal_cursor() {
  press "Vy"

  assert_same "prompt> ls" "$(cat "$SCRATCH/clipboard")"
}

function test_starts_on_the_column_of_the_terminal_cursor() {
  paint "" "∴ ls -la" 1 3

  press "yiw"

  assert_same "ls" "$(cat "$SCRATCH/clipboard")"
}

function test_fits_the_window_to_the_rows_of_the_terminal() {
  ROWS=6 paint "old 1" "s1|s2|s3|s4|s5|prompt>" 6 8

  press "LVy"

  assert_same "prompt>" "$(cat "$SCRATCH/clipboard")"
}

function test_shows_the_screen_of_the_terminal_at_the_top_of_the_window() {
  press "HVy"

  assert_same "out a" "$(cat "$SCRATCH/clipboard")"
}

function test_leaves_out_output_that_comes_after_the_first_paint() {
  fake hc 'cat "$SCRATCH/paint"; sleep 0.2; printf "\033[3;1Hlive output"; exec sleep 5'

  press "Vy"

  assert_same "prompt> ls" "$(cat "$SCRATCH/clipboard")"
}

function test_puts_no_blank_line_between_the_history_and_the_screen() {
  press "ggjjVy"

  assert_same "out a" "$(cat "$SCRATCH/clipboard")"
}

function test_closes_when_hc_cannot_read_the_terminal() {
  fake hc 'echo "t7 was removed" >&2; exit 1'

  press ""

  assert_file_not_exists "$SCRATCH/open"
}

function test_y_copies_the_selection_to_the_clipboard() {
  press "kVy"

  assert_same "out b" "$(cat "$SCRATCH/clipboard")"
}

function test_y_closes_copy_mode() {
  press "Vy"

  assert_file_not_exists "$SCRATCH/open"
}

function test_q_closes_copy_mode() {
  press "q"

  assert_file_not_exists "$SCRATCH/open"
}

function test_q_closes_copy_mode_after_a_key_for_insert_mode() {
  press "iq"

  assert_file_not_exists "$SCRATCH/open"
}

function test_escape_closes_copy_mode() {
  press '<Esc>'

  assert_file_not_exists "$SCRATCH/open"
}

function test_escape_in_a_selection_cancels_only_the_selection() {
  press 'V<Esc>'

  assert_file_exists "$SCRATCH/open"
}

function test_a_modeline_in_the_text_changes_no_option() {
  paint "" "foo-bar|# vim: set iskeyword+=-:" 1 1

  press "0yiw"

  assert_same "foo" "$(cat "$SCRATCH/clipboard")"
}

# Opens copy mode on the terminal t7, which hc gives a size of 40 columns
# and the rows of the last paint, and types the keys in $1. After 400 ms it
# writes "open" to the file open, so the file exists only when copy mode is
# still running after the keys.
press() {
  SCRATCH="$SCRATCH" COPY_MODE_TERMINAL=t7 PATH="$SCRATCH/bin:$PATH" \
    nvim --clean --headless -u "$CONFIG" --noplugin -n \
    -c "lua vim.api.nvim_input('$1')" \
    -c "lua vim.defer_fn(function() vim.fn.writefile({'open'}, '$SCRATCH/open') vim.cmd('qa!') end, 400)" \
    < /dev/null
}

# Writes the first paint that hc attach prints for a terminal of ROWS rows
# (default 10): the history lines in $1 and the screen lines in $2, each split
# at "|", and the cursor at row $3 and column $4.
paint() {
  local rows=${ROWS:-10}
  printf '%s' "$rows" > "$SCRATCH/rows"
  {
    printf '\033[H\033[2J%s\r\n' "${1//|/$'\r\n'}"
    printf '\n%.0s' $(seq 1 "$rows")
    printf '\033[H\033[2J%s\033[%d;%dH' "${2//|/$'\r\n'}" "$3" "$4"
  } > "$SCRATCH/paint"
}

# Puts a program called $1 first on the PATH of nvim, which runs the shell
# code in $2.
fake() {
  printf '#!/bin/sh\n%s\n' "$2" > "$SCRATCH/bin/$1"
  chmod +x "$SCRATCH/bin/$1"
}
