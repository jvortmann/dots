#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MARK="$ROOT/herdr-app/mods/tab-bar/status-mark.js"
# shellcheck source=./fake_gpui_kit.sh
source "$ROOT/tests/herdr-app/mods/tab-bar/fake_gpui_kit.sh"

function set_up() {
  [[ -f $MARK ]] || bashunit::fail "missing the file under test: $MARK"
}

function test_a_working_agent_shows_the_spinner_of_the_sidebar_in_the_working_color() {
  assert_same 'svg("mods/workspace-chrome/spinner.svg").size(12).mx(1).flex_none().text_color("#b58900").spin(900)' \
    "$(drawn_by "$MARK" 'statusMark(t, "working")')"
}

# The sidebar rounds the pill 5 px. The list keeps the 4 px corners of its rows.
function test_a_blocked_agent_shows_the_needs_you_pill_of_the_sidebar_with_square_corners() {
  assert_same 'div().flex_none().px(6).h(18).rounded(4).bg("#dc322f26").text_size(10.5).font_semibold().text_color("#dc322f").flex().items_center().child("Needs you")' \
    "$(drawn_by "$MARK" 'statusMark(t, "blocked")')"
}

function test_a_done_agent_shows_the_dot_of_the_sidebar_in_the_done_color() {
  assert_same 'div().size(7).mx(3).flex_none().rounded(4).bg("#859900")' "$(drawn_by "$MARK" 'statusMark(t, "done")')"
}

function test_an_idle_agent_shows_the_ring_of_the_sidebar_in_the_idle_color() {
  assert_same 'div().size(7).mx(3).flex_none().rounded(4).border(1.5).border_color("#586e75")' "$(drawn_by "$MARK" 'statusMark(t, "idle")')"
}

# A child record can have no state. The sidebar draws a clear dot for it.
function test_a_status_with_no_mark_keeps_the_place_of_the_mark_empty() {
  assert_same 'div().size(7).mx(3).flex_none()' "$(drawn_by "$MARK" 'statusMark(t, undefined)')"
}
