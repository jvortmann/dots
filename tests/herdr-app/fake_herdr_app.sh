#!/bin/bash

# The herdr-app of the user is not on PATH, so the code under test runs
# ~/.local/bin/herdr-app. This fake goes in $HOME_DIR/.local/bin. It prints
# what the real one prints, and logs its arguments to $LOG. $1 is a shell
# line that runs first.
fake_herdr_app() {
  printf '#!/bin/sh\n%s\necho "{\\"ok\\": true}"\necho "$*" >> %q\n' "$1" "$LOG" > "$HOME_DIR/.local/bin/herdr-app"
  chmod +x "$HOME_DIR/.local/bin/herdr-app"
}
