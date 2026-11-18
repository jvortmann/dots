#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
POLICY="$ROOT/pi/pi-permissions.jsonc"
EXTENSION="$ROOT/pi/git/github.com/jvortmann/pi-permission-system"

function set_up() {
  [[ -f $POLICY ]] || bashunit::fail "missing the file under test: $POLICY"
  [[ -f $EXTENSION/src/permission-manager.ts ]] || bashunit::skip "needs the pi-permission-system extension installed"
  command -v bun > /dev/null || bashunit::skip "needs bun"
  PI_MODULES="$(mise where npm:@earendil-works/pi-coding-agent 2> /dev/null)/lib/node_modules"
  [[ -d $PI_MODULES/@earendil-works/pi-coding-agent ]] || bashunit::skip "needs pi installed with mise"
  EMPTY=$(bashunit::temp_dir "permissions")
}

function test_denies_env_with_no_command_to_run() {
  assert_same "deny env
deny env -0" "$(decisions_for "env" "env -0")"
}

function test_denies_env_piped_or_redirected() {
  assert_same "deny env | sort
deny env|sort
deny env > vars.txt" \
    "$(decisions_for "env | sort" "env|sort" "env > vars.txt")"
}

function test_denies_env_followed_by_another_command() {
  assert_same "deny env; ls
deny env && ls" "$(decisions_for "env; ls" "env && ls")"
}

function test_denies_env_after_another_command() {
  assert_same "deny cd repo && env
deny cd repo && env | sort
deny cd repo ; env
deny cd repo ; env | sort" \
    "$(decisions_for "cd repo && env" "cd repo && env | sort" "cd repo ; env" "cd repo ; env | sort")"
}

function test_denies_printenv_with_no_variable_name() {
  assert_same "deny printenv
deny printenv | sort
deny printenv > vars.txt
deny printenv -0
deny cd repo && printenv
deny cd repo && printenv | sort" \
    "$(decisions_for "printenv" "printenv | sort" "printenv > vars.txt" "printenv -0" \
      "cd repo && printenv" "cd repo && printenv | sort")"
}

function test_denies_the_shell_builtins_that_list_every_variable() {
  assert_same "deny export
deny export -p
deny set
deny set | less
deny set > vars.txt
deny declare -x
deny declare -x | sort
deny declare -p
deny declare -p | sort" \
    "$(decisions_for "export" "export -p" "set" "set | less" "set > vars.txt" \
      "declare -x" "declare -x | sort" "declare -p" "declare -p | sort")"
}

function test_denies_a_dump_inside_a_command_substitution() {
  assert_same 'deny echo $(env)
deny echo $(printenv)
deny echo `env`' \
    "$(decisions_for 'echo $(env)' 'echo $(printenv)' 'echo `env`')"
}

function test_still_allows_a_command_that_reads_or_sets_one_variable() {
  assert_same 'allow printenv HOME
allow printenv HOME | head
allow echo $PI_SESSION_FILE
allow declare -p FOO
allow set -e
allow export FOO=1' \
    "$(decisions_for "printenv HOME" "printenv HOME | head" 'echo $PI_SESSION_FILE' \
      "declare -p FOO" "set -e" "export FOO=1")"
}

function test_still_allows_env_to_run_a_command() {
  assert_same "allow env FOO=bar make
allow env -i make" "$(decisions_for "env FOO=bar make" "env -i make")"
}

function test_still_allows_a_command_that_only_contains_the_word_env() {
  assert_same "allow envsubst < template.txt
allow python -m venv env" "$(decisions_for "envsubst < template.txt" "python -m venv env")"
}

# Prints "<decision> <command>" for each argument, as the extension decides
# under the real policy file. It checks each command and never runs it.
decisions_for() {
  NODE_PATH="$PI_MODULES" POLICY="$POLICY" EXTENSION="$EXTENSION" EMPTY="$EMPTY" bun -e '
    const { PermissionManager } = await import(process.env.EXTENSION + "/src/permission-manager.ts");
    const manager = new PermissionManager({
      globalConfigPath: process.env.POLICY,
      agentsDir: process.env.EMPTY + "/agents",
      legacyGlobalSettingsPath: process.env.EMPTY + "/settings.json",
      globalMcpConfigPath: process.env.EMPTY + "/mcp.json",
      mcpServerNames: [],
    });
    for (const command of process.argv.slice(1)) {
      console.log(manager.checkPermission("bash", { command }).state + " " + command);
    }
  ' "$@"
}
