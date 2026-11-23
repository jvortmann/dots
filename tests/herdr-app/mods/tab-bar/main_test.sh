#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MAIN="$ROOT/herdr-app/mods/tab-bar/main.js"
ICON="$ROOT/herdr-app/mods/tab-bar/program-icon.js"

function set_up() {
  [[ -f $MAIN ]] || bashunit::fail "missing the file under test: $MAIN"
}

function test_a_tab_takes_the_width_of_its_label_up_to_a_cap() {
  assert_same "" "$(tab_chain | grep -oE '\.w\([0-9]+\)')"
  assert_contains ".max_w(" "$(tab_chain)"
}

function test_a_tab_shows_its_number_then_its_icon_then_its_name() {
  assert_same "number icon text " "$(tab_chain | tab_parts)"
}

function test_no_tab_shows_a_path_named_or_not() {
  assert_contains "const tab = (c) =>" "$(tab_chain)"
  assert_same "" "$(tab_chain | grep -oE '\.cwd\b' | tr '\n' ' ')"
}

function test_the_tray_and_the_space_chip_have_corners_of_at_most_2_px() {
  assert_contains ".rounded(" "$(space_chip_chain)"
  assert_same "" "$({ space_chip_chain; tray_chain; } | round_corners_over 2)"
}

function test_the_shown_tab_rounds_all_four_corners_a_little_like_a_button() {
  assert_same ".rounded(4) " "$(tab_chain | grep -oE '\.rounded[_a-z]*\([0-9]*\)' | tr '\n' ' ')"
}

function test_the_space_chip_and_the_tabs_fill_the_height_of_the_bar_up_to_the_panes() {
  assert_same ".h_full() .h_full() .h_full() .h_full() " "$({ row_of_the_space_chip; space_chip_chain; tray_chain; tab_chain; } | heights)"
}

# The same command as ctrl-a f, ctrl-a ctrl-f and cmd-p in keys.json.
function test_a_click_on_the_space_chip_opens_the_recent_picker_as_its_keys_do() {
  assert_same '"mod.open:recent-picker" "mod.open:recent-picker" "mod.open:recent-picker"' "$(jq -c '.global["ctrl-a f"], .global["ctrl-a ctrl-f"], .global["cmd-p"]' "$ROOT/herdr-app/keys.json" | tr '\n' ' ' | sed 's/ $//')"
  assert_contains '.on_click(() => run("mod.open", { name: "recent-picker" }))' "$(space_chip_chain)"
  assert_not_contains 'openOverlay(' "$(space_chip_chain)"
}

function test_the_space_chip_shows_a_hand_cursor_and_lightens_under_the_pointer_like_the_other_buttons() {
  assert_contains '.cursor_pointer()' "$(space_chip_chain)"
  assert_contains '.hover((s) => s.text_color(C.text))' "$(space_chip_chain)"
}

function test_the_space_chip_touches_the_tray_of_the_tabs() {
  assert_contains "h_flex()" "$(row_of_the_space_chip)"
  assert_same "" "$(row_of_the_space_chip | gaps)"
  assert_same "" "$({ space_chip_chain; tray_chain; } | margins)"
}

function test_the_shown_tab_has_the_same_slim_edge_on_all_four_sides_like_a_button() {
  assert_same ".border_1() " "$(shown_tab_style | border_widths)"
  assert_contains ".border_color(C.tabEdge)" "$(shown_tab_style)"
}

function test_the_edge_of_the_shown_tab_is_the_border_color_at_a_quarter_strength() {
  assert_contains 'import { alpha } from "./alpha.js";' "$(cat "$MAIN")"
  assert_contains 'tabEdge: alpha(t.border, 1 / 4),' "$(colors_function)"
}

function test_the_shown_tab_takes_the_surface_fill_one_step_up_from_the_bar() {
  assert_contains ".bg(C.tab)" "$(shown_tab_style)"
  assert_contains "tab: t.surface," "$(colors_function)"
}

function test_a_tab_that_is_not_shown_has_no_border_and_no_fill() {
  assert_contains ".when(!c.active," "$(other_tab_style)"
  assert_same "" "$(other_tab_style | grep -oE '\.(border[_a-z0-9]*|bg)\(' | tr '\n' ' ')"
}

function test_a_tab_keeps_its_content_in_place_when_it_is_shown() {
  assert_same "$(tab_base_style | side_paddings 1)" "$(shown_tab_style | side_paddings 0)"
  assert_same "" "$(shown_tab_style | grep -oE '\.p[tby]\(' | tr '\n' ' ')"
}

function test_the_tabs_sit_in_the_bar_with_no_box_around_them() {
  assert_same "" "$(tray_chain | box_styles)"
}

function test_the_bar_keeps_its_space_between_the_parts_on_the_right() {
  assert_contains ".gap(8)" "$(bar_row)"
}

function test_the_status_on_the_right_takes_no_accent_color() {
  assert_same "" "$(grep -oE 't\.accent|C\.status\b' "$MAIN" | tr '\n' ' ')"
}

function test_the_right_side_shows_the_agents_then_the_changes_button_then_the_machine_then_the_time() {
  assert_same "agents dots needs changes machine time " "$(right_side | right_parts)"
}

function test_the_changes_button_shows_the_icon_of_the_stock_changes_mod_then_the_word() {
  assert_contains '.child(svg("mods/changes/changes.svg").size(14)).child("Changes")' "$(changes_button_function)"
}

function test_a_click_on_the_changes_button_shows_or_hides_the_changes_panel_of_the_shown_layout() {
  assert_contains 'toggleChanges } from "./changes-panel.js";' "$(cat "$MAIN")"
  assert_contains '.on_click(() => toggleChanges(layout()).forEach(([command, args]) => run(command, args)))' "$(changes_button_function)"
}

function test_the_changes_button_shows_a_hand_cursor_and_lightens_under_the_pointer_like_the_agent_count() {
  assert_contains '.gap(6).items_center().cursor_pointer().hover((s) => s.text_color(C.text))' "$(changes_button_function)"
}

function test_the_changes_button_stays_bright_while_the_panel_shows_the_changes() {
  assert_contains '.child(changesButton(C, changesShown(layout())))' "$(right_side | tr -d '\n' | tr -s ' ' | sed 's/) \./)./g')"
  assert_contains '.when(shown, (el) => el.text_color(C.text))' "$(changes_button_function)"
}

# The list shows each agent, so the bar shows each status once.
function test_each_status_of_the_agents_shows_one_mark_for_the_bar() {
  assert_contains 'import { barMark } from "./status-mark.js";' "$(cat "$MAIN")"
  assert_contains '.child(h_flex().children(barStatuses(list).map((status) => barMark(t, status))))' "$(right_side | tr -d '\n' | tr -s ' ')"
}

function test_the_agents_that_need_you_take_the_blocked_color() {
  assert_contains "text_color(t.blocked).child(needsText(" "$(right_side)"
}

function test_the_bar_has_no_command_palette_button() {
  assert_same "" "$(grep -oE 'tm-keys|app\.palette' "$MAIN" | tr '\n' ' ')"
}

function test_the_bar_has_no_new_tab_button() {
  assert_same "" "$(grep -oE 'tm-new|tab\.new' "$MAIN" | tr '\n' ' ')"
}

function test_a_click_on_the_machine_label_opens_the_add_machine_dialog() {
  assert_contains 'on_click(() => run("mod.open", { name: "machine-add" }))' "$(machine_function)"
}

function test_a_press_on_the_machine_label_does_not_drag_the_window() {
  assert_contains "return own(h_flex())" "$(machine_function)"
}

function test_the_machine_label_shows_a_hand_cursor_like_the_other_controls() {
  assert_contains ".cursor_pointer()" "$(machine_function)"
}

function test_the_machine_label_lightens_under_the_pointer_like_the_space_chip() {
  assert_contains ".hover((s) => s.text_color(C.text))" "$(machine_function)"
}

# The icon takes the color of the count, as the icon of the Changes button
# takes the color of its word.
function test_the_agent_count_shows_the_agent_icon_of_the_app_at_the_size_of_the_changes_icon() {
  assert_contains ".gap(6).items_center()" "$(agents_group)"
  assert_contains '.child(svg("mods/tab-bar/agent.svg").size(14)).child(agentsText(list))' "$(agents_group)"
}

function test_a_click_on_the_agent_count_opens_the_agent_list_of_the_tab_bar_as_a_popup() {
  assert_contains 'own(h_flex(),(e)=>this.placeCount(e.bounds)).id("tm-agents")' "$(agents_group)"
  assert_contains ".on_click(()=>this.openAgents())" "$(agents_group)"
  assert_contains "openList(" "$(open_agents_method)"
  assert_contains 'openOverlay({ mod: "tab-bar", kind: "popup",' "$(open_list_function)"
  assert_contains 'props: { popup: "agents",' "$(open_list_function)"
}

# keys.json binds alt-a to tab-bar.agents.
function test_the_agents_command_opens_the_agent_list_as_a_click_on_the_count_does() {
  assert_contains 'else if (command === "agents") this.openAgents();' "$(sed -n '/^  init(/,/^  }/p' "$MAIN")"
}

# A key carries no bounds, so the count keeps its place from the pointer, as
# distances from the right and bottom edges of the window.
function test_the_agent_list_opens_above_the_count_also_from_a_key() {
  assert_contains ".on_mouse_move((e)=>this.placeCount(e.bounds))" "$(agents_group)"
  assert_contains "own(h_flex(),(e)=>this.placeCount(e.bounds)).id(\"tm-agents\")" "$(agents_group)"
  assert_contains "const { width, height } = window.viewport_size();" "$(place_count_method)"
  assert_contains "setShared(COUNT_AT, at);" "$(place_count_method)"
  assert_contains "const at = shared(COUNT_AT);" "$(open_agents_method)"
  assert_contains "x: width - at.right - LIST_WIDTH, bottom: height - at.bottom - 6" "$(open_agents_method)"
}

function test_the_agent_list_copy_takes_no_tab_commands_so_a_swap_does_not_run_twice() {
  assert_same "    if (props()?.popup) return this.initList(cx);" "$(sed -n '/^  init(/,/^  }/p' "$MAIN" | sed -n 2p)"
}

function test_the_agent_list_copy_draws_only_the_list_and_moves_no_tab() {
  assert_same "    if (this.listing) return this.renderList();" "$(sed -n '/^  render(/,/^  }/p' "$MAIN" | sed -n 2p)"
}

function test_the_agent_list_shows_a_row_for_each_agent_in_the_order_and_numbers_of_alt_n() {
  assert_contains "return agentList(agents(), this.records, changesOf(), Date.now(), shared(AGENTS) ?? []);" "$(all_rows_method)"
  assert_contains "const all = this.allRows();" "$(render_list_method)"
  assert_contains "agentRows(t, rows" "$(render_list_method)"
}

# The search and the filter tab choose the rows. The counts follow the search.
function test_the_agent_list_shows_the_search_field_and_the_filter_tabs_over_the_rows_they_keep() {
  assert_contains "const rows = filterRows(all, this.filter, this.query);" "$(render_list_method)"
  assert_contains ".child(agentHead(t, this.input, this.filter, filterCounts(all, this.query), (f, cx) => this.pickFilter(f, cx)))" "$(render_list_method)"
  assert_contains 'this.input = InputState.new({ placeholder: "Search agents", value: this.query });' "$(init_list_method)"
  assert_contains 'this.query = props().query ?? "";' "$(init_list_method)"
  assert_contains 'this.filter = props().filter ?? "all";' "$(init_list_method)"
}

# terminals() and agents() do not carry the child records, and hc get does.
# The bar reads no records, so it costs nothing while the list is closed.
function test_the_agent_list_reads_the_records_of_each_agent_with_hc_while_it_is_open() {
  assert_contains "this.records = shared(RECORDS) ?? {};" "$(init_list_method)"
  assert_contains "if (!checking()) cx.timer.every(2000, (cx) => this.readRecords(cx));" "$(init_list_method)"
  assert_contains 'hc(["get", address, "--json"])' "$(records_of_function)"
  assert_contains "return agentList(agents(), this.records, changesOf(), Date.now(), shared(AGENTS) ?? []);" "$(all_rows_method)"
  assert_same "1" "$(grep -c 'hc(\[' "$MAIN")"
}

function test_going_to_an_agent_from_the_list_closes_the_list_and_focuses_the_agent() {
  assert_contains "agentRows(t, rows, Math.min(this.chosen, rows.length - 1), (a) => this.goTo(a)," "$(render_list_method)"
  assert_contains "closeOverlay(props().overlay);" "$(go_to_method)"
  assert_contains 'run("agent.focus", { terminal: a.address });' "$(go_to_method)"
}

# The search field holds the keyboard, as in the recent picker. A key it does
# not take goes on to the list.
function test_the_agent_list_takes_the_keyboard_and_reads_each_key_as_listkey_says() {
  assert_contains "this.input.focus();" "$(init_list_method)"
  assert_contains "cx.timer.after(600, () => this.input.focus());" "$(init_list_method)"
  assert_contains ".track_focus(this.handle)" "$(render_list_method)"
  assert_contains ".on_key_down((e, cx) => this.listKeyDown(e, rows, cx))" "$(render_list_method)"
  assert_contains "listKey(e.keystroke, this.chosen, rows)" "$(sed -n '/^  listKeyDown(/,/^  }/p' "$MAIN")"
}

# A key the list takes stops there, so Tab does not move the keyboard on.
function test_tab_switches_the_filter_and_escape_clears_the_search_before_it_closes_the_list() {
  assert_contains "cx.stop_propagation();" "$(list_key_down_method)"
  assert_contains 'if ("filter" in key) return this.pickFilter(nextFilter(this.filter, key.filter), cx);' "$(list_key_down_method)"
  assert_contains 'if ("escape" in key) return this.query ? this.clearSearch(cx) : closeOverlay(props().overlay);' "$(list_key_down_method)"
  assert_contains 'this.input.set_value("");' "$(sed -n '/^  clearSearch(/,/^  }/p' "$MAIN")"
  assert_contains 'this.search("", cx);' "$(sed -n '/^  clearSearch(/,/^  }/p' "$MAIN")"
}

# The field can take Enter as its submit, as in the recent picker, and the key
# can reach the list too. The list goes to the agent once.
function test_enter_in_the_search_field_goes_to_the_chosen_agent_once() {
  assert_contains 'this.input.on("submit", () => this.goChosen());' "$(init_list_method)"
  assert_contains "const rows = this.shownRows();" "$(sed -n '/^  goChosen(/,/^  }/p' "$MAIN")"
  assert_contains "if (this.gone) return;" "$(go_to_method)"
  assert_contains "this.gone = true;" "$(go_to_method)"
}

# The popup takes the height of its content. The rows keep the height the
# popup opened for, so the list does not shrink to the field while a search
# leaves fewer rows.
function test_the_rows_keep_the_height_the_list_opened_for() {
  assert_contains '"No agents").h(props().height - HEAD));' "$(render_list_method)"
}

# A command reaches every shown copy, so the list takes only the filter
# commands, and a swap still runs once.
function test_the_list_takes_the_filter_commands_of_its_keys_and_no_other_command() {
  assert_contains "const wanted = filterOfCommand(await nextCommand());" "$(init_list_method)"
  assert_contains "if (wanted) this.pickFilter(pickedFilter(this.filter, wanted), cx);" "$(init_list_method)"
}

# With agents, an empty list means that the search or the filter hides them.
function test_a_list_that_the_search_or_filter_empties_says_no_matches() {
  assert_contains '(a) => this.goTo(a), all.length ? "No matches" : "No agents")' "$(render_list_method)"
}

function list_key_down_method() {
  sed -n '/^  listKeyDown(/,/^  }/p' "$MAIN"
}

function test_the_agent_list_opens_above_the_agent_count_with_its_right_edge_on_the_count() {
  assert_contains "return 8 + HEAD + Math.min(Math.max(count, 1), 12) * ROW;" "$(sed -n '/^function listHeight(/,/^}/p' "$MAIN")"
  assert_contains "openList(at && { x: width - at.right - LIST_WIDTH, bottom: height - at.bottom - 6 }," "$(open_agents_method)"
  assert_contains "at: anchor ? { x: anchor.x, y: anchor.bottom - height } : \"pointer\"" "$(open_list_function)"
}

# The bar reads no records, so the height counts the ones the list saw last.
function test_the_height_of_the_agent_list_counts_the_child_rows_that_the_list_saw_last() {
  assert_contains "const rows = agentList(agents(), shared(RECORDS) ?? {}, {}, 0, shared(AGENTS) ?? []);" "$(open_agents_method)"
}

function test_the_agent_list_opens_on_the_row_that_openingrow_chooses_in_the_recency_order() {
  assert_contains "const chosen = openingRow(rows);" "$(open_agents_method)"
  assert_contains "openList(at && { x: width - at.right - LIST_WIDTH, bottom: height - at.bottom - 6 }, rows.length, chosen, { prefer: rows[chosen]?.key ?? null });" "$(open_agents_method)"
}

function test_a_new_search_or_filter_chooses_the_agent_the_list_opened_on_while_it_shows_or_else_the_first_row() {
  assert_contains "this.prefer = props().prefer ?? null;" "$(init_list_method)"
  assert_contains 'this.input.on("change", (_e, cx) => this.search(this.input.value(), cx));' "$(init_list_method)"
  assert_contains "this.chosen = rowOf(this.shownRows(), this.prefer);" "$(sed -n '/^  choose(/,/^  }/p' "$MAIN")"
  assert_contains "return filterRows(this.allRows(), this.filter, this.query);" "$(sed -n '/^  shownRows(/,/^  }/p' "$MAIN")"
  assert_contains "this.choose();" "$(sed -n '/^  search(/,/^  }/p' "$MAIN")"
  assert_contains "this.choose();" "$(sed -n '/^  pickFilter(/,/^  }/p' "$MAIN")"
}

# A popup cannot change its size, so the list opens again in its place.
function test_the_agent_list_opens_again_at_the_new_height_when_the_records_change_its_rows() {
  assert_contains "if (anchor && listHeight(count) !== height) {" "$(read_records_method)"
  assert_contains "closeOverlay(overlay);" "$(read_records_method)"
  assert_contains "openList(anchor, count, this.chosen, { query: this.query, filter: this.filter, prefer: this.prefer });" "$(read_records_method)"
  assert_contains "function openList(anchor, count, chosen = 0, state = {}) {" "$(open_list_function)"
  assert_contains 'props: { popup: "agents", anchor, height, chosen, ...state },' "$(open_list_function)"
  assert_contains "this.chosen = props().chosen ?? 0;" "$(init_list_method)"
}

# hc can take more than 2 s, and two reads could each open the list again.
function test_the_agent_list_starts_no_read_while_a_read_runs() {
  assert_contains "if (this.reading) return;" "$(read_records_method)"
  assert_contains "this.reading = true;" "$(read_records_method)"
  assert_contains "this.reading = false;" "$(read_records_method)"
}

function test_the_agent_count_shows_a_hand_cursor_and_lightens_under_the_pointer_like_the_machine_label() {
  assert_contains ".cursor_pointer()" "$(agents_group)"
  assert_contains ".hover((s)=>s.text_color(C.text))" "$(agents_group)"
}

function test_select_agent_n_goes_to_the_agent_that_the_list_numbers_n_without_the_list() {
  assert_same "select-agent- select- " "$(grep -oE 'command\.startsWith\("[a-z-]+"\)' "$MAIN" | grep -oE '"[a-z-]+"' | tr -d '"' | tr '\n' ' ')"
  assert_contains "agentList(agents()).find((a) => a.number === number)" "$(select_agent_method)"
  assert_contains 'run("agent.focus", { terminal: agent.address })' "$(select_agent_method)"
}

function test_the_program_icon_draws_plain_with_no_box_and_no_border() {
  assert_contains "function programIcon(" "$(icon_function)"
  assert_same "" "$(icon_function | grep -oE '\.border[_a-z0-9]*\(' | tr '\n' ' ')"
  assert_same "" "$(icon_function | grep -oE '\.(rounded|bg)\([^)]*\)' | grep -v '^\.bg(dot)$' | tr '\n' ' ')"
}

function test_the_program_icon_is_at_most_18_px() {
  assert_contains "function programIcon(" "$(icon_function)"
  assert_same "" "$(icon_function | sizes_over 18)"
}

function test_a_program_glyph_takes_the_color_that_stands_out_on_the_canvas() {
  assert_contains 'import { programIcon } from "./program-icon.js";' "$(cat "$MAIN")"
  assert_contains "svg(g.icon).size(14).text_color(glyphColor(g, t.canvas, t.foreground, t))" "$(icon_function)"
}

function test_each_render_records_the_spaces_by_recency_for_the_recent_picker() {
  assert_contains 'const SPACES = "tab-bar.space-history";' "$(grep -F 'const SPACES' "$MAIN")"
  assert_contains "this.observe();" "$(sed -n '/^  render(/,/^  }/p' "$MAIN")"
  assert_contains "const seen = shared(SPACES) ?? [];" "$(observe_method)"
  assert_contains "observeSpaces(seen, spaces())" "$(observe_method)"
  assert_contains "setShared(SPACES," "$(observe_method)"
}

# Only a change of the history writes it, because a write to shared state makes the mods render again.
function test_each_render_records_the_agents_by_focus_recency_for_the_agent_list() {
  assert_contains 'const AGENTS = "tab-bar.agent-history";' "$(grep -F 'const AGENTS' "$MAIN")"
  assert_contains "const focusedBefore = shared(AGENTS) ?? [];" "$(observe_method)"
  assert_contains "const byFocus = observeAgents(focusedBefore, agents());" "$(observe_method)"
  assert_contains "if (JSON.stringify(byFocus) !== JSON.stringify(focusedBefore)) setShared(AGENTS, byFocus);" "$(observe_method)"
}

function test_the_bar_paints_the_pi_icon_in_color_13_of_the_theme_when_that_color_changes() {
  assert_contains "this.paintPi(cx, t.ansi13);" "$(sed -n '/^  render(/,/^  }/p' "$MAIN")"
  assert_contains "if (checking() || color === this.piColor) return;" "$(paint_pi_method)"
  assert_contains 'syncPiIcon({ readTextFile, writeTextFile }, `${appHome()}/${PI_ICON}`, color)' "$(paint_pi_method)"
}

function test_each_render_of_the_bar_stamps_the_changes_of_the_agents_in_its_storage_for_the_list() {
  assert_contains "this.stamp(list);" "$(sed -n '/^  render(/,/^  }/p' "$MAIN")"
  assert_contains "const after = stampChanges(before, list, Date.now());" "$(stamp_method)"
  assert_contains "localStorage.setItem(CHANGES, JSON.stringify(after));" "$(stamp_method)"
  assert_contains 'JSON.parse(localStorage.getItem(CHANGES) ?? "{}")' "$(sed -n '/^function changesOf(/,/^}/p' "$MAIN")"
  assert_contains "return agentList(agents(), this.records, changesOf(), Date.now(), shared(AGENTS) ?? []);" "$(all_rows_method)"
}

function test_stored_stamps_that_are_not_a_plain_object_read_as_none() {
  assert_contains 'return changes && typeof changes === "object" && !Array.isArray(changes) ? changes : {};' "$(sed -n '/^function changesOf(/,/^}/p' "$MAIN")"
}

function stamp_method() {
  sed -n '/^  stamp(/,/^  }/p' "$MAIN"
}

function paint_pi_method() {
  sed -n '/^  paintPi(/,/^  }/p' "$MAIN"
}

function tab_chain() {
  sed -n '/const tab = (c) =>/,/^    };$/p' "$MAIN"
}

function right_side() {
  sed -n '/\.child(div()\.flex_1())/,$p' "$MAIN"
}

function right_parts() {
  awk '/agentsText\(/ { print "agents" } /barStatuses\(/ { print "dots" } /needsText\(/ { print "needs" } /changesButton\(C/ { print "changes" } /machineLabel\(/ { print "machine" } /timeText\(/ { print "time" }' | tr '\n' ' '
}

function tab_parts() {
  awk '/numbers\[space\.id\]/ { print "number" } /programIcon\(t, p, p\?\.status\)/ { print "icon" } /\.child\(text\)/ { print "text" }' | tr '\n' ' '
}

function space_chip_chain() {
  sed -n '/\.id("tm-space")/,/space\.name/p' "$MAIN"
}

function tray_chain() {
  sed -n '/space\.name/,/\.children(space\.tabs\.map(tab))/p' "$MAIN" | sed 1d
}

function row_of_the_space_chip() {
  awk '/h_flex\(\)$/ && !/own\(/ { row = ""; on = 1 } on { row = row $0 "\n" } /\.id\("tm-space"\)/ { printf "%s", row; exit }' "$MAIN"
}

function bar_row() {
  sed -n '/return h_flex()/,/\.child(/p' "$MAIN"
}

function shown_tab_style() {
  tab_chain | awk '/\.when\(!c\.active,/ { exit } /\.when\(c\.active,/ { on = 1 } on'
}

function tab_base_style() {
  tab_chain | awk '/\.when\(/ { exit } 1'
}

function side_paddings() {
  grep -oE '\.p[lr]\([0-9]+\)' | awk -v less="$1" -F'[()]' '{ printf "%s(%d) ", $1, $2 - less }'
}

function other_tab_style() {
  tab_chain | awk '/\.on_click\(/ { exit } /\.when\(!c\.active,/ { on = 1 } on'
}

function border_widths() {
  grep -oE '\.border_[a-z0-9]+\([0-9]*\)' | tr '\n' ' '
}

function box_styles() {
  grep -oE '\.(bg|p[xytblr]?|rounded[_a-z]*|border[_a-z0-9]*)\(' | tr '\n' ' '
}

function gaps() {
  grep -oE '\.gap\([0-9]+\)'
}

function margins() {
  grep -oE '\.m[lrx]?\([0-9]+\)'
}

function heights() {
  grep -oE '\.h(_full)?\([0-9]*\)' | tr '\n' ' '
}

function agents_group() {
  right_side | awk '/h_flex\(\)/ { group = "" } { group = group $0 } /agentsText\(/ { print group; exit }' | tr -d ' '
}

function select_agent_method() {
  sed -n '/^  selectAgent(/,/^  }/p' "$MAIN"
}

function observe_method() {
  sed -n '/^  observe(/,/^  }/p' "$MAIN"
}

function go_to_method() {
  sed -n '/^  goTo(/,/^  }/p' "$MAIN"
}

function init_list_method() {
  sed -n '/^  initList(/,/^  }/p' "$MAIN"
}

function read_records_method() {
  sed -n '/^  readRecords(/,/^  }/p' "$MAIN"
}

function records_of_function() {
  sed -n '/^async function recordsOf(/,/^}/p' "$MAIN"
}

function all_rows_method() {
  sed -n '/^  allRows(/,/^  }/p' "$MAIN"
}

function render_list_method() {
  sed -n '/^  renderList(/,/^  }/p' "$MAIN"
}

function open_agents_method() {
  sed -n '/^  openAgents(/,/^  }/p' "$MAIN" | tr '\n' ' ' | tr -s ' '
}

function place_count_method() {
  sed -n '/^  placeCount(/,/^  }/p' "$MAIN"
}

function open_list_function() {
  sed -n '/^function openList(/,/^}/p' "$MAIN" | tr '\n' ' ' | tr -s ' '
}

function changes_button_function() {
  sed -n '/^function changesButton(/,/^}/p' "$MAIN" | tr -d '\n' | tr -s ' ' | sed 's/) \./)./g'
}

function machine_function() {
  sed -n '/^function machine(/,/^}/p' "$MAIN"
}

function colors_function() {
  sed -n '/^function colors(/,/^}/p' "$MAIN"
}

function icon_function() {
  cat "$ICON"
}

function round_corners_over() {
  grep -oE '\.rounded(_full\(\)|\([0-9]+\))' | awk -v max="$1" -F'[()]' '$1 ~ /_full$/ || $2 > max' | tr '\n' ' '
}

function sizes_over() {
  grep -oE '\.(w|h|size)\([0-9]+\)' | awk -v max="$1" -F'[()]' '$2 > max' | tr '\n' ' '
}
