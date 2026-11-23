#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
ROUTE="$ROOT/herdr-app/mods/nav/route.js"

function set_up() {
  [[ -f $ROUTE ]] || bashunit::fail "missing the file under test: $ROUTE"
}

function test_a_key_in_nvim_goes_on_to_nvim_so_that_it_moves_between_its_own_windows() {
  assert_same '{"exec":["/home/me/.local/bin/hc",["keys","t7","ctrl+j"]]}' \
    "$(route_of down "$(focus)" "$(panes_with nvim)")"
}

# hc keys waits for 3 s of quiet after a key of the person, so a key goes to
# the server that nvim gives in the label nvim.server. When that send fails,
# nvim is gone, and the pane moves.
function test_a_key_in_nvim_goes_to_the_server_that_nvim_gives_in_its_label() {
  assert_same '{"exec":["/opt/homebrew/bin/nvim",["--server","/tmp/nv.sock","--remote-send","<C-j>"]],"failed":["pane.go",{"direction":"down"}]}' \
    "$(route_of down "$(focus)" "$(panes_with nvim)" "$(terminals_with /tmp/nv.sock)")"
}

# Herdr shows the program that started nvim, such as git for its editor.
function test_a_key_in_nvim_under_another_program_goes_to_the_server_in_the_label() {
  assert_same '{"exec":["/opt/homebrew/bin/nvim",["--server","/tmp/nv.sock","--remote-send","<C-h>"]],"failed":["pane.go",{"direction":"left"}]}' \
    "$(route_of left "$(focus)" "$(panes_with program)" "$(terminals_with /tmp/nv.sock)")"
}

# Herdr shows a bash script, such as bashunit, as the program shell.
function test_a_key_while_the_shell_runs_a_command_moves_the_pane_in_its_direction() {
  assert_same '{"run":["pane.go",{"direction":"down"}]}' "$(route_of down "$(focus)" "$(panes_with shell)")"
}

# Copy mode shows its nvim in the pane with terminal.show. pane.go keeps
# copy mode shown in its pane.
function test_a_key_in_copy_mode_moves_the_pane_in_its_direction_though_copy_mode_runs_nvim() {
  assert_same '{"run":["pane.go",{"direction":"up"}]}' "$(route_of up "$(focus '"t9"')" "$(panes_with nvim)")"
}

function test_a_key_in_copy_mode_over_nvim_with_its_label_moves_the_pane_in_its_direction() {
  assert_same '{"run":["pane.go",{"direction":"up"}]}' \
    "$(route_of up "$(focus '"t9"')" "$(panes_with nvim)" "$(terminals_with /tmp/nv.sock)")"
}

function test_a_key_while_nothing_has_the_focus_runs_pane_go_in_its_direction() {
  assert_same '{"run":["pane.go",{"direction":"left"}]}' "$(route_of left null "$(panes_with nvim)")"
}

function test_a_key_in_pi_moves_the_pane_in_its_direction() {
  assert_same '{"run":["pane.go",{"direction":"right"}]}' "$(route_of right "$(focus)" "$(panes_with pi)")"
}

function test_a_key_moves_the_pane_in_its_direction_while_the_panes_do_not_list_the_focused_one_yet() {
  assert_same '{"run":["pane.go",{"direction":"left"}]}' \
    "$(route_of left "$(focus)" '[{"pane":"p2","terminal":"t8","program":{"key":"shell"}}]')"
}

# Prints, as JSON, what the nav mod does with the command $1 while the
# focus is $2, the JSON of focused(), over the panes $3, the JSON of panes(),
# and the terminals $4, the JSON of terminals() (default: none). The home
# folder is /home/me.
route_of() {
  COMMAND="$1" FOCUSED="$2" PANES="$3" TERMINALS="${4:-[]}" ROUTE="$ROUTE" mise x node@latest -- node --input-type=module -e '
    const { route } = await import(process.env.ROUTE);
    const { COMMAND, FOCUSED, PANES, TERMINALS } = process.env;
    console.log(JSON.stringify(route(COMMAND, JSON.parse(FOCUSED), JSON.parse(PANES), JSON.parse(TERMINALS), "/home/me")));
  '
}

# Prints terminals(): terminal t8, and terminal t7 with the label nvim.server
# set to $1.
terminals_with() {
  printf '[{"address":"t8","labels":{}},{"address":"t7","labels":{"nvim.server":"%s"}}]' "$1"
}

# Prints focused() on pane p1 with terminal t7, and the terminal $1 shown
# over it when set.
focus() {
  printf '{"space":"s1","tab":"w1","pane":"p1","terminal":"t7","shown":%s}' "${1:-null}"
}

# Prints panes(): pane p2 with a shell, and the focused pane p1 with
# terminal t7, which runs the program $1.
panes_with() {
  printf '[{"pane":"p2","terminal":"t8","program":{"key":"shell"},"focused":false},'
  printf '{"pane":"p1","terminal":"t7","program":{"key":"%s"},"focused":true}]' "$1"
}
