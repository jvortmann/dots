#!/bin/bash

# shellcheck source=../fakes/fakes.sh
source "$(dirname "${BASH_SOURCE[0]}")/../fakes/fakes.sh"

# The herdr-app of the user is not on PATH, so the code under test runs
# ~/.local/bin/herdr-app. This fake goes in $HOME_DIR/.local/bin. It prints
# what the real one prints, logs its arguments to $LOG, and reports to its
# channel. $1 is a shell line that runs first.
fake_herdr_app() {
  fake_program "$HOME_DIR/.local/bin" herdr-app "$(printf '%s\necho "{\\"ok\\": true}"\necho "$*" >> %q\n%s' "$1" "$LOG" "$FAKE_REPORT")"
}
