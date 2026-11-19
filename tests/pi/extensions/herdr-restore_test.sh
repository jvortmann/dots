#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
EXTENSION="$ROOT/pi/extensions/herdr-restore.ts"

function set_up() {
  [[ -f $EXTENSION ]] || bashunit::fail "missing the file under test: $EXTENSION"
  command -v mise > /dev/null || bashunit::skip "needs mise"
  NODE=$(mise x node@latest -- node -p process.execPath 2> /dev/null)
  [[ -x $NODE ]] || bashunit::skip "needs node from mise"
  HOME_DIR=$(bashunit::temp_dir "home")
  LOG="$HOME_DIR/hc.log"
  SESSION_FILE="$HOME_DIR/sessions/2026-11-19_a b.jsonl"
  mkdir -p "$HOME_DIR/.local/bin" "$HOME_DIR/sessions"
  printf '#!/bin/sh\necho "$*" >> %q\n' "$LOG" > "$HOME_DIR/.local/bin/hc"
  chmod +x "$HOME_DIR/.local/bin/hc"
}

function test_a_session_with_a_file_records_the_file_at_its_start() {
  touch "$SESSION_FILE"

  run_events session_start

  assert_same "label t7 restore.pi=$SESSION_FILE" "$(hc_calls)"
}

function test_a_new_session_records_nothing_before_pi_writes_its_file() {
  run_events session_start message_end

  assert_same "" "$(hc_calls)"
}

function test_a_new_session_records_its_file_once_pi_writes_it() {
  run_events session_start message_end write message_end

  assert_same "label t7 restore.pi=$SESSION_FILE" "$(hc_calls)"
}

function test_a_session_records_its_file_once_and_not_for_each_message() {
  run_events session_start write message_end message_end message_end

  assert_same "label t7 restore.pi=$SESSION_FILE" "$(hc_calls)"
}

function test_pi_outside_herdr_calls_no_hc() {
  touch "$SESSION_FILE"

  TERMINAL_ID="" run_events session_start

  assert_file_not_exists "$LOG"
}

function test_pi_carries_on_in_silence_without_hc() {
  rm "$HOME_DIR/.local/bin/hc"
  touch "$SESSION_FILE"

  local output
  output=$(run_events session_start)

  assert_successful_code
  assert_same "" "$output"
}

# pi also shuts down on SIGTERM and SIGHUP, as at a reboot, and the next start
# needs the record then.
function test_a_session_keeps_its_record_when_pi_shuts_down() {
  touch "$SESSION_FILE"

  run_events session_start session_shutdown

  assert_same "label t7 restore.pi=$SESSION_FILE" "$(hc_calls)"
}

hc_calls() {
  cat "$LOG" 2> /dev/null
}

# Loads the extension in node, in a Herdr terminal with the id t7, and sends
# it each event that the arguments name, in order. The event "write" is no
# event of pi: it creates the session file, as pi does after the first message.
# Node ends only when each hc that the extension started has ended. set_up
# finds node with the real HOME, and only node runs with the scratch HOME.
# Mise with the scratch HOME finds no install, and it starts many npm processes.
run_events() {
  HOME="$HOME_DIR" HC_TERMINAL_ID=${TERMINAL_ID-t7} EXTENSION="$EXTENSION" SESSION_FILE="$SESSION_FILE" \
    "$NODE" --input-type=module -e '
    import { writeFileSync } from "node:fs";
    const handlers = {};
    const extension = (await import(process.env.EXTENSION)).default;
    extension({ on: (name, handler) => { handlers[name] = handler; } });
    const ctx = { sessionManager: { getSessionFile: () => process.env.SESSION_FILE } };
    for (const event of process.argv.slice(1)) {
      if (event === "write") writeFileSync(process.env.SESSION_FILE, "{}\n");
      else await handlers[event]?.({ type: event }, ctx);
    }
  ' "$@" 2>&1
}
