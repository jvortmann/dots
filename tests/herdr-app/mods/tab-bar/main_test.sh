#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MAIN="$ROOT/herdr-app/mods/tab-bar/main.js"
# shellcheck source=../fixed_colors.sh
source "$ROOT/tests/herdr-app/mods/fixed_colors.sh"

function set_up() {
  [[ -f $MAIN ]] || bashunit::fail "missing the file under test: $MAIN"
}

function test_the_tab_bar_colors_follow_the_theme_in_both_appearances() {
  assert_same "" "$(fixed_colors "$MAIN")"
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
  assert_contains 'tabEdge: `${t.border}40`,' "$(colors_function)"
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

function test_the_right_side_shows_the_agents_then_the_machine_then_the_time() {
  assert_same "agents dots needs machine time " "$(right_side | right_parts)"
}

function test_each_agent_that_is_not_idle_shows_a_dot_in_its_status_color() {
  assert_contains '.children(list.filter((a) => a.status !== "idle").map((a) => div().size(6).rounded(3).bg(t[a.status])))' "$(right_side | tr -d '\n' | tr -s ' ')"
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

function test_the_agent_count_has_the_dim_dot_of_the_stock_status_bar() {
  assert_contains ".gap(6).items_center()" "$(agents_group)"
  assert_contains ".child(div().size(6).rounded(3).bg(C.dim)).child(agentsText(list))" "$(agents_group)"
}

function test_a_click_on_the_agent_count_opens_the_agent_list_of_the_tab_bar_as_a_popup() {
  assert_contains 'own(h_flex(),(e)=>(this.agentsAt=e.bounds)).id("tm-agents")' "$(agents_group)"
  assert_contains ".on_click(()=>this.openAgents())" "$(agents_group)"
  assert_contains 'openOverlay({ mod: "tab-bar", kind: "popup",' "$(open_agents_method)"
  assert_contains 'props: { popup: "agents" }' "$(open_agents_method)"
}

function test_the_agent_list_copy_takes_no_tab_commands_so_a_swap_does_not_run_twice() {
  assert_same "    if (props()?.popup) return this.initList(cx);" "$(sed -n '/^  init(/,/^  }/p' "$MAIN" | sed -n 2p)"
}

function test_the_agent_list_copy_draws_only_the_list_and_moves_no_tab() {
  assert_same "    if (this.listing) return this.renderList();" "$(sed -n '/^  render(/,/^  }/p' "$MAIN" | sed -n 2p)"
}

function test_the_agent_list_shows_a_row_for_each_agent_in_the_order_and_numbers_of_alt_n() {
  assert_contains "const rows = agentList(agents());" "$(render_list_method)"
  assert_contains "agentRows(theme(), rows" "$(render_list_method)"
}

function test_going_to_an_agent_from_the_list_closes_the_list_and_focuses_the_agent() {
  assert_contains "agentRows(theme(), rows, Math.min(this.chosen, rows.length - 1), (a) => this.goTo(a))" "$(render_list_method)"
  assert_contains "closeOverlay(props().overlay);" "$(go_to_method)"
  assert_contains 'run("agent.focus", { terminal: a.address });' "$(go_to_method)"
}

function test_the_agent_list_takes_the_keyboard_and_reads_each_key_as_listkey_says() {
  assert_contains "this.handle.focus();" "$(sed -n '/^  initList(/,/^  }/p' "$MAIN")"
  assert_contains ".track_focus(this.handle)" "$(render_list_method)"
  assert_contains ".on_key_down((e, cx) => this.listKeyDown(e, rows, cx))" "$(render_list_method)"
  assert_contains "listKey(e.keystroke, this.chosen, rows.length)" "$(sed -n '/^  listKeyDown(/,/^  }/p' "$MAIN")"
}

function test_the_agent_list_opens_above_the_agent_count_with_its_right_edge_on_the_count() {
  assert_contains "const height = 8 + Math.min(Math.max(agents().length, 1), 12) * ROW;" "$(open_agents_method)"
  assert_contains "at: at ? { x: at.x + at.width - LIST_WIDTH, y: at.y - height - 6 } : \"pointer\"" "$(open_agents_method)"
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

function test_each_render_records_the_spaces_by_recency_for_the_recent_picker() {
  assert_contains 'const SPACES = "tab-bar.space-history";' "$(grep -F 'const SPACES' "$MAIN")"
  assert_contains "this.observe();" "$(sed -n '/^  render(/,/^  }/p' "$MAIN")"
  assert_contains "const seen = shared(SPACES) ?? [];" "$(observe_method)"
  assert_contains "observeSpaces(seen, spaces())" "$(observe_method)"
  assert_contains "setShared(SPACES," "$(observe_method)"
}

function tab_chain() {
  sed -n '/const tab = (c) =>/,/^    };$/p' "$MAIN"
}

function right_side() {
  sed -n '/\.child(div()\.flex_1())/,$p' "$MAIN"
}

function right_parts() {
  awk '/agentsText\(/ { print "agents" } /status !== "idle"/ { print "dots" } /needsText\(/ { print "needs" } /machineLabel\(/ { print "machine" } /timeText\(/ { print "time" }' | tr '\n' ' '
}

function tab_parts() {
  awk '/numbers\[space\.id\]/ { print "number" } /programIcon\(t, C, p\)/ { print "icon" } /\.child\(text\)/ { print "text" }' | tr '\n' ' '
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

function render_list_method() {
  sed -n '/^  renderList(/,/^  }/p' "$MAIN"
}

function open_agents_method() {
  sed -n '/^  openAgents(/,/^  }/p' "$MAIN" | tr '\n' ' ' | tr -s ' '
}

function machine_function() {
  sed -n '/^function machine(/,/^}/p' "$MAIN"
}

function colors_function() {
  sed -n '/^function colors(/,/^}/p' "$MAIN"
}

function icon_function() {
  sed -n '/^function programIcon(/,/^}/p' "$MAIN"
}

function round_corners_over() {
  grep -oE '\.rounded(_full\(\)|\([0-9]+\))' | awk -v max="$1" -F'[()]' '$1 ~ /_full$/ || $2 > max' | tr '\n' ' '
}

function sizes_over() {
  grep -oE '\.(w|h|size)\([0-9]+\)' | awk -v max="$1" -F'[()]' '$2 > max' | tr '\n' ' '
}
