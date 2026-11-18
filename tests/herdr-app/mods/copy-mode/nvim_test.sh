#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
CONFIG="$ROOT/herdr-app/mods/copy-mode/nvim.lua"

function set_up() {
  [[ -f $CONFIG ]] || bashunit::fail "missing the file under test: $CONFIG"
  command -v nvim > /dev/null || bashunit::skip "needs nvim"
  SCRATCH=$(bashunit::temp_dir "copy-mode")
  mkdir -p "$SCRATCH/bin"
  printf '#!/bin/sh\ncat > "%s/clipboard"\n' "$SCRATCH" > "$SCRATCH/bin/pbcopy"
  chmod +x "$SCRATCH/bin/pbcopy"
  printf 'first line\nsecond line\nlast line\n' > "$SCRATCH/text"
}

function test_y_copies_the_selection_to_the_clipboard() {
  press "ggVy"

  assert_same "first line" "$(cat "$SCRATCH/clipboard")"
}

function test_y_closes_copy_mode() {
  press "ggVy"

  assert_file_not_exists "$SCRATCH/open"
}

function test_copy_mode_starts_on_the_last_line() {
  press "Vy"

  assert_same "last line" "$(cat "$SCRATCH/clipboard")"
}

function test_q_closes_copy_mode() {
  press "q"

  assert_file_not_exists "$SCRATCH/open"
}

function test_escape_closes_copy_mode() {
  press '\<Esc>'

  assert_file_not_exists "$SCRATCH/open"
}

function test_escape_in_a_selection_cancels_only_the_selection() {
  press 'V\<Esc>'

  assert_file_exists "$SCRATCH/open"
}

# Opens the text in copy mode with the flags of view.sh, and presses the keys
# in $1. Then it writes "open" to the file open, so the file exists only when
# copy mode is still running after the keys.
press() {
  PATH="$SCRATCH/bin:$PATH" nvim --clean --headless -u "$CONFIG" --noplugin -n -R -M \
    -c "call feedkeys(\"$1\", 'x')" -c "sleep 100m" \
    -c "call writefile(['open'], '$SCRATCH/open')" -c "qa!" -- "$SCRATCH/text" < /dev/null
}
