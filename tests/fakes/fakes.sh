#!/bin/bash

FAKE_PROGRAM="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/fake"

# Shell code for a fake that reports the end of its work. It writes a line to
# the channel of its link, <link>.channel, when the test opened that channel.
# The open does not block, so a fake with no test to read the line goes on.
# shellcheck disable=SC2016
FAKE_REPORT='perl -MFcntl -e '\''sysopen(my $f, $ARGV[0], O_WRONLY | O_NONBLOCK) or exit; syswrite($f, "done\n")'\'' "$0.channel"'

# Shell code for a fake that blocks until the test ends. It opens the gate of
# its link, <link>.gate, reports, and reads the gate. The test holds the gate
# open, and the read ends when the test ends and closes it. If the code under
# test waits for this fake, the test cannot end. So the read also stops after
# 5 seconds, and that test fails and does not hang the suite.
FAKE_GATE='exec 3< "$0.gate"; '"$FAKE_REPORT"'; read -r -t 5 _ <&3; exit'

# Shell code for a fake that stays until the code under test stops it. A
# program that keeps a connection open does the same. It blocks with no poll.
# When a broken run never stops it, it ends after 10 seconds.
# shellcheck disable=SC2016
FAKE_STAY='exec perl -e '\''alarm 10; select(undef, undef, undef, undef)'\'''

# Puts a program called $2 in the folder $1. It runs the shell code in $3 with
# the arguments of the call. The program is a link to the one fake program.
fake_program() {
  mkdir -p "$1"
  printf '%s\n' "$3" > "$1/$2.sh"
  ln -sf "$FAKE_PROGRAM" "$1/$2"
}

# Opens the channel of the fake at the path $1, for the rest of the test.
open_channel() {
  mkfifo "$1.channel"
  exec {FAKE_CHANNEL}<> "$1.channel"
}

# Opens the gate of the fake at the path $1, for the rest of the test.
open_gate() {
  mkfifo "$1.gate"
  exec {FAKE_GATE_FD}<> "$1.gate"
}

# Reads $1 reports from the open channel. Each read returns when a fake
# reports. A fake that never reports fails the test after 5 seconds, so a
# broken test cannot stop the suite.
read_reports() {
  local i
  for ((i = 0; i < $1; i++)); do
    IFS= read -r -t 5 -u "$FAKE_CHANNEL" _ || return 1
  done
}
