#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
CONFIG="$ROOT/herdr-app/mods/copy-mode/nvim.lua"

function set_up() {
  SERVER=""
  [[ -f $CONFIG ]] || bashunit::fail "missing the file under test: $CONFIG"
  command -v nvim > /dev/null || bashunit::skip "needs nvim"
  SCRATCH=$(bashunit::temp_dir "copy-mode")
  mkdir -p "$SCRATCH/bin"
  fake pbcopy 'cat > "$SCRATCH/clipboard"'
  fake hc 'case $1 in
    get) printf "{\"cols\":40,\"rows\":%s}\n" "$(cat "$SCRATCH/rows")" ;;
    label) printf "%s %s\n" "$2" "$3" >> "$SCRATCH/labels" ;;
    *) printf "%s\n" "$*" > "$SCRATCH/hc.args"; cat "$SCRATCH/paint"; exec sleep 5 ;;
  esac'
  paint "old 1|old 2" "out a|out b|prompt> ls" 3 11
}

function tear_down() {
  [[ -n ${SERVER:-} ]] || return 0
  nvim --server "$SERVER" --remote-expr 'execute("qa!")' < /dev/null > /dev/null 2>&1 || true
}

function test_tells_the_mod_where_its_server_listens() {
  start_standby

  SERVER=$(wait_for_label "t5 copy-mode.standby=")

  assert_same "2" "$(nvim --server "$SERVER" --remote-expr '1+1' < /dev/null)"
}

function test_opens_copy_mode_on_the_terminal_the_mod_names() {
  start_standby
  SERVER=$(wait_for_label "t5 copy-mode.standby=")

  nvim --server "$SERVER" --remote-expr 'v:lua.copy_mode_open("t8")' < /dev/null > /dev/null 2>&1

  assert_same "attach --observe --history 10000 t8" "$(cat "$SCRATCH/hc.args")"
}

function test_is_no_longer_ready_for_the_mod_once_copy_mode_opens() {
  start_standby
  SERVER=$(wait_for_label "t5 copy-mode.standby=")

  nvim --server "$SERVER" --remote-expr 'v:lua.copy_mode_open("t8")' < /dev/null > /dev/null 2>&1

  assert_same "t5 copy-mode.standby=" "$(tail -1 "$SCRATCH/labels")"
}

function test_counts_the_lines_from_the_cursor_to_the_last_line_as_the_cursor_moves() {
  press "k"

  assert_same "$(top_row 'out a' '[1/4]')" "$(cat "$SCRATCH/top")"
}

function test_reads_0_on_the_blank_rows_below_the_last_line_with_text() {
  press "G"

  assert_same "$(top_row 'out a' '[0/4]')" "$(cat "$SCRATCH/top")"
}

function test_reads_0_on_the_last_line_with_text_above_blank_rows() {
  paint "old 1|old 2" "prompt>" 1 8

  press ""

  assert_same "$(top_row 'prompt>' '[0/2]')" "$(cat "$SCRATCH/top")"
}

function test_reads_0_of_0_when_no_line_has_text() {
  paint "" "" 1 1

  press ""

  assert_same "[0/0]" "$(grep -o '\[.*\]' "$SCRATCH/top")"
}

function test_reads_all_lines_on_the_first_line() {
  press "gg"

  assert_same "$(top_row 'old 1' '[4/4]')" "$(cat "$SCRATCH/top")"
}

function test_stops_at_the_first_and_the_last_line() {
  press "ggk"
  assert_same "[4/4]" "$(grep -o '\[.*\]' "$SCRATCH/top")"

  press "Gj"
  assert_same "[0/4]" "$(grep -o '\[.*\]' "$SCRATCH/top")"
}

function test_stays_at_the_top_right_when_the_view_scrolls_without_the_cursor() {
  press 'k<C-y>'

  assert_same "$(top_row 'old 2' '[1/4]')" "$(cat "$SCRATCH/top")"
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

function test_starts_on_the_first_non_blank_of_the_line_of_the_terminal_cursor() {
  indented

  press "yiw"

  assert_same "l26" "$(cat "$SCRATCH/clipboard")"
}

function test_k_moves_to_the_first_non_blank_of_the_line_above() {
  indented

  press "kyiw"

  assert_same "l25" "$(cat "$SCRATCH/clipboard")"
}

function test_j_moves_to_the_first_non_blank_of_the_line_below() {
  indented

  press "kkjyiw"

  assert_same "l25" "$(cat "$SCRATCH/clipboard")"
}

function test_j_with_a_count_moves_that_many_lines_to_the_first_non_blank() {
  indented

  press "5k3jyiw"

  assert_same "l24" "$(cat "$SCRATCH/clipboard")"
}

function test_j_in_a_selection_moves_to_the_first_non_blank_of_the_line_below() {
  indented

  press "kkvjy"

  assert_same $'l24 tail\n l' "$(cat "$SCRATCH/clipboard")"
}

function test_k_in_a_selection_moves_to_the_first_non_blank_of_the_line_above() {
  indented

  press "kvky"

  assert_same $'l24 tail\n l' "$(cat "$SCRATCH/clipboard")"
}

function test_j_in_a_line_selection_copies_the_whole_lines() {
  indented

  press "kkVjy"

  assert_same $'      l24 tail\n l25 tail' "$(cat "$SCRATCH/clipboard")"
}

function test_j_in_a_block_selection_keeps_the_column() {
  indented

  press "kk<C-v>jy"

  assert_same $'l\na' "$(cat "$SCRATCH/clipboard")"
}

function test_k_in_a_block_selection_keeps_the_column() {
  indented

  press "k<C-v>ky"

  assert_same $' \nl' "$(cat "$SCRATCH/clipboard")"
}

function test_gg_moves_to_the_first_non_blank_of_the_first_line() {
  indented

  press "ggyiw"

  assert_same "l1" "$(cat "$SCRATCH/clipboard")"
}

function test_G_moves_to_the_first_non_blank_of_the_last_line() {
  indented

  press "0Gyiw"

  assert_same "l26" "$(cat "$SCRATCH/clipboard")"
}

function test_ctrl_u_moves_to_the_first_non_blank_half_a_window_up() {
  indented

  press "0<C-u>yiw"

  assert_same "l23" "$(cat "$SCRATCH/clipboard")"
}

function test_ctrl_d_moves_to_the_first_non_blank_half_a_window_down() {
  indented

  press "gg0<C-d>yiw"

  assert_same "l4" "$(cat "$SCRATCH/clipboard")"
}

function test_ctrl_f_moves_to_the_first_non_blank_a_window_down() {
  indented

  press "gg0<C-f>yiw"

  assert_same "l5" "$(cat "$SCRATCH/clipboard")"
}

function test_ctrl_b_moves_to_the_first_non_blank_a_window_up() {
  indented

  press "0<C-b>yiw"

  assert_same "l22" "$(cat "$SCRATCH/clipboard")"
}

function test_H_moves_to_the_first_non_blank_of_the_top_line_of_the_window() {
  indented

  press "0Hyiw"

  assert_same "l21" "$(cat "$SCRATCH/clipboard")"
}

function test_M_moves_to_the_first_non_blank_of_the_middle_line_of_the_window() {
  indented

  press "0Myiw"

  assert_same "l23" "$(cat "$SCRATCH/clipboard")"
}

function test_L_moves_to_the_first_non_blank_of_the_bottom_line_of_the_window() {
  indented

  press "gg0Lyiw"

  assert_same "l6" "$(cat "$SCRATCH/clipboard")"
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
# redraws and writes the top row of the screen to the file top. It then
# writes "open" to the file open, so that file exists only when copy mode is
# still running after the keys.
press() {
  SCRATCH="$SCRATCH" PATH="$SCRATCH/bin:$PATH" \
    nvim --clean --headless -u "$CONFIG" --noplugin -n \
    -c "lua copy_mode_open('t7')" \
    -c "lua vim.api.nvim_input('$1')" \
    -c "lua vim.defer_fn(function()
      vim.cmd('redraw')
      local top = {}
      for column = 1, vim.o.columns do top[column] = vim.fn.screenstring(1, column) end
      vim.fn.writefile({ table.concat(top) }, '$SCRATCH/top')
      vim.fn.writefile({ 'open' }, '$SCRATCH/open')
      vim.cmd('qa!')
    end, 400)" \
    < /dev/null
}

# Starts nvim in the background as the warm nvim of the terminal t5, the way
# the mod starts it. It ends after 10 seconds at the latest.
start_standby() {
  SCRATCH="$SCRATCH" HC_TERMINAL_ID=t5 PATH="$SCRATCH/bin:$PATH" perl -e 'use POSIX; setsid(); alarm 10; exec @ARGV' \
    nvim --clean --headless -u "$CONFIG" --noplugin -n < /dev/null > /dev/null 2>&1 &
}

# Waits about 2 seconds for nvim to set a label that starts with $1, and
# prints the rest of the label.
wait_for_label() {
  local line
  for _ in {1..200}; do
    line=$(grep -F "$1" "$SCRATCH/labels" 2> /dev/null | tail -1)
    [[ -n $line ]] && break
    sleep 0.01
  done
  printf '%s' "${line#"$1"}"
}

# Prints the top row that press writes to the file top, for a screen of 40
# columns: the text in $1 on the left, and the chip in $2 on the right.
top_row() {
  printf "%-$((40 - ${#2}))s%s" "$1" "$2"
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

# Paints the lines "l1 tail" to "l26 tail" for a terminal of 6 rows: 20 lines
# of history and 6 on the screen. An odd line has 1 space of indent and an even
# line has 6, so a move that keeps the column lands on "tail" or on a blank.
# The terminal cursor is on "tail" of the last line.
indented() {
  local lines=() i
  for i in {1..26}; do lines+=("$(printf '%*sl%d tail' $((i % 2 ? 1 : 6)) '' "$i")"); done
  ROWS=6 paint "$(IFS='|'; printf '%s' "${lines[*]:0:20}")" "$(IFS='|'; printf '%s' "${lines[*]:20}")" 6 12
}

# Puts a program called $1 first on the PATH of nvim, which runs the shell
# code in $2.
fake() {
  printf '#!/bin/sh\n%s\n' "$2" > "$SCRATCH/bin/$1"
  chmod +x "$SCRATCH/bin/$1"
}
