#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
POLICY="$ROOT/pi/pi-permissions.jsonc"
EXTENSION="$ROOT/pi/git/github.com/jvortmann/pi-permission-system"
STASH_IN_A_BATCH='timeout 120 bashunit tests/x_test.sh </dev/null 2>&1 | tail -4; git stash list >/dev/null 2>&1; true'
SYSTEM_DELETES=(
  "rm -Rf /System" "rm -r /Library/Caches" "rm -r /Applications/Foo.app" "rm -r /usr/local/lib"
  "rm -r /bin" "rm -r /sbin" "rm -r /etc" "rm -r /private/etc/ssh" "rm -r /Users" "rm -r /opt"
  "rm -r /var" "rm -r /private" "rm -r /private/var" "cd repo && rm -fr /usr/bin"
)
LIBRARY_DELETES=(
  "rm -r ~/Library/Caches/x" "rm -Rf ~/Library" 'rm -r "$HOME/Library/Logs"' 'rm -r $HOME/Library'
  "rm -r /Users/someone/Library/Caches" "cd repo && rm -fr ~/Library/Mail"
)
TEMP_DELETES=(
  "rm -rf /tmp/x" "rm -r /private/tmp/x" "rm -Rf /var/folders/ab/cd/T/tmp.X"
  "rm -fr /private/var/folders/ab/cd/T/x" "rm -fR /tmp/x" "rm -R /tmp/x"
)
OTHER_TEMP_DELETES=()
for folder in /tmp /private/tmp /var/folders/ab/cd/T /private/var/folders/ab/cd/T; do
  OTHER_TEMP_DELETES+=("rmdir $folder/x" "trash $folder/x" "find $folder/x -delete")
done
FILE_DELETES=(
  "rm -f /tmp/msg.txt" 'rm "$M"' 'rm -f "$dir/report.txt"' "rm -f /tmp/a.txt /tmp/b.txt" "rm -f a.txt b.txt"
  "find /tmp/x -type f -name '*.log'"
)
CLIMBING_DELETES=(
  "rm -rf /tmp/../Users/someone/prj" "rm -R /var/folders/ab/cd/T/../../x" "rmdir /tmp/../x"
  "trash /private/tmp/../x" "find /tmp/../x -delete" "rm -rf /tmp/{x,../y}"
)
MIXED_DELETES=(
  "rm -rf /tmp/x build" "rm -rf build /tmp/x" "rm -rf /tmp/x && rm -rf build" "rm -f /tmp/x && rm -rf build"
  "rmdir /tmp/x build" "trash /tmp/x && rm -rf build" "find /tmp/x build -delete"
  "find /tmp/x -delete && find build -delete"
)

# One bun decides each command that a test checks, before the first test.
# A command that is not in this list gives "missing", not a decision.
function set_up_before_script() {
  PI_MODULES="$(mise where npm:@earendil-works/pi-coding-agent 2> /dev/null)/lib/node_modules"
  DECISIONS=""
  [[ -f $POLICY && -f $EXTENSION/src/permission-manager.ts && -d $PI_MODULES/@earendil-works/pi-coding-agent ]] || return 0
  command -v bun > /dev/null || return 0
  local scratch
  scratch=$(bashunit::temp_dir "permissions")
  DECISIONS="$scratch/decisions"
  decide "$scratch" \
    "env" "env -0" "env | sort" "env|sort" "env > vars.txt" "env; ls" "env && ls" \
    "cd repo && env" "cd repo && env | sort" "cd repo ; env" "cd repo ; env | sort" \
    "printenv" "printenv | sort" "printenv > vars.txt" "printenv -0" \
    "cd repo && printenv" "cd repo && printenv | sort" \
    "export" "export -p" "set" "set | less" "set > vars.txt" \
    "declare -x" "declare -x | sort" "declare -p" "declare -p | sort" \
    'echo $(env)' 'echo $(printenv)' 'echo `env`' \
    "printenv HOME" "printenv HOME | head" 'echo $PI_SESSION_FILE' \
    "declare -p FOO" "set -e" "export FOO=1" \
    "env FOO=bar make" "env -i make" "envsubst < template.txt" "python -m venv env" \
    "git stash list" "git stash" "git -C repo stash list" "cd repo && git stash" \
    "$STASH_IN_A_BATCH" \
    "rm -rf /tmp/x" "cd /tmp && rm -rf pt" "rm -rf build" "cd repo && rm -rf x" 'rm -rf "$d/out"' \
    "rm -r build" "rm -R build" "rm -fr build" "rm -fR build" "rm -Rf build" \
    "rm -r -f build" "rm -f -r build" "rm --recursive build" \
    "cd repo && rm -r x" "cd repo && rm -R x" "cd repo && rm -fr x" "cd repo && rm -fR x" \
    "cd repo && rm -f -r x" "cd repo && rm --recursive x" "command rm -r build" "/bin/rm -r build" \
    "/bin/rm -Rf build" "/bin/rm -fr build" "/bin/rm -fR build" \
    "rmdir build" "trash build" "cd repo && rmdir x" "cd repo && trash x" \
    "find build -delete" "/usr/bin/find build -delete" "cd repo && find . -name '*.o' -delete" \
    "git clean -fd" "git -C repo clean -fdx" "cd repo && git clean -fd" "cd repo && git -C sub clean -fd" \
    "rm -rf /" "rm -r /" "rm -Rf /" "rm -r /*" "rm -rf / --no-preserve-root" "cd repo && rm -fr /" "/bin/rm -r /" \
    "rm -rf ~" "rm -r ~" "rm -r ~/" "rm -Rf ~/*" "cd repo && rm -fr ~" "rm -r ~ build" \
    'rm -rf "$d"' 'rm -r "$d"' 'rm -r $d' 'rm -r ${dir}' 'cd repo && rm -fr "$out"' \
    'rm -Rf "$HOME"' 'rm -r "$HOME/"' 'rm -r $HOME/*' \
    'rm -r "$d/out"' 'rm -r $d/out' 'cd repo && rm -fR "${out}/cache"' 'rm -R "$HOME/prj/x"' \
    "${SYSTEM_DELETES[@]}" "${LIBRARY_DELETES[@]}" "${TEMP_DELETES[@]}" "${MIXED_DELETES[@]}" "${OTHER_TEMP_DELETES[@]}" "${FILE_DELETES[@]}" "${CLIMBING_DELETES[@]}" \
    'rm -rf build && echo $?' "rm -f out.txt; printf '%s' \"\$x\"" "rm -rf build && cd ~" \
    "rm -rf /tmp/x && /usr/bin/find . -name y" "rm -rf build && ls ~/Library/Logs" "rm -rf Game/Library" \
    > "$DECISIONS"
}

function set_up() {
  [[ -f $POLICY ]] || bashunit::fail "missing the file under test: $POLICY"
  [[ -f $EXTENSION/src/permission-manager.ts ]] || bashunit::skip "needs the pi-permission-system extension installed"
  command -v bun > /dev/null || bashunit::skip "needs bun"
  [[ -d $PI_MODULES/@earendil-works/pi-coding-agent ]] || bashunit::skip "needs pi installed with mise"
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

function test_denies_git_stash_in_any_form() {
  assert_same "deny git stash list
deny git stash
deny git -C repo stash list" \
    "$(decisions_for "git stash list" "git stash" "git -C repo stash list")"
}

function test_denies_git_stash_after_another_command() {
  assert_same "deny cd repo && git stash" "$(decisions_for "cd repo && git stash")"
}

function test_denies_git_stash_list_inside_a_batch_of_checks() {
  assert_same "deny $STASH_IN_A_BATCH" "$(decisions_for "$STASH_IN_A_BATCH")"
}

function test_asks_before_a_forced_recursive_delete_outside_the_temp_folders() {
  assert_same 'ask rm -rf build
ask cd repo && rm -rf x
ask cd /tmp && rm -rf pt
ask rm -rf "$d/out"' \
    "$(decisions_for "rm -rf build" "cd repo && rm -rf x" "cd /tmp && rm -rf pt" 'rm -rf "$d/out"')"
}

function test_asks_before_a_recursive_delete_in_any_spelling() {
  assert_same "ask rm -r build
ask rm -R build
ask rm -fr build
ask rm -fR build
ask rm -Rf build
ask rm -r -f build
ask rm -f -r build
ask rm --recursive build" \
    "$(decisions_for "rm -r build" "rm -R build" "rm -fr build" "rm -fR build" "rm -Rf build" \
      "rm -r -f build" "rm -f -r build" "rm --recursive build")"
}

function test_asks_before_a_recursive_delete_after_another_command_or_by_full_path() {
  assert_same "ask cd repo && rm -r x
ask cd repo && rm -R x
ask cd repo && rm -fr x
ask cd repo && rm -fR x
ask cd repo && rm -f -r x
ask cd repo && rm --recursive x
ask command rm -r build
ask /bin/rm -r build
ask /bin/rm -Rf build
ask /bin/rm -fr build
ask /bin/rm -fR build" \
    "$(decisions_for "cd repo && rm -r x" "cd repo && rm -R x" "cd repo && rm -fr x" "cd repo && rm -fR x" \
      "cd repo && rm -f -r x" "cd repo && rm --recursive x" "command rm -r build" "/bin/rm -r build" \
      "/bin/rm -Rf build" "/bin/rm -fr build" "/bin/rm -fR build")"
}

function test_asks_before_rmdir_or_trash() {
  assert_same "ask rmdir build
ask trash build
ask cd repo && rmdir x
ask cd repo && trash x" \
    "$(decisions_for "rmdir build" "trash build" "cd repo && rmdir x" "cd repo && trash x")"
}

function test_asks_before_a_find_that_deletes() {
  assert_same "ask find build -delete
ask /usr/bin/find build -delete
ask cd repo && find . -name '*.o' -delete" \
    "$(decisions_for "find build -delete" "/usr/bin/find build -delete" "cd repo && find . -name '*.o' -delete")"
}

function test_asks_before_git_clean() {
  assert_same "ask git clean -fd
ask git -C repo clean -fdx
ask cd repo && git clean -fd
ask cd repo && git -C sub clean -fd" \
    "$(decisions_for "git clean -fd" "git -C repo clean -fdx" "cd repo && git clean -fd" "cd repo && git -C sub clean -fd")"
}

function test_denies_a_recursive_delete_of_the_root() {
  assert_same "deny rm -rf /
deny rm -r /
deny rm -Rf /
deny rm -r /*
deny rm -rf / --no-preserve-root
deny cd repo && rm -fr /
deny /bin/rm -r /" \
    "$(decisions_for "rm -rf /" "rm -r /" "rm -Rf /" "rm -r /*" "rm -rf / --no-preserve-root" \
      "cd repo && rm -fr /" "/bin/rm -r /")"
}

function test_denies_a_recursive_delete_of_the_home_folder() {
  assert_same "deny rm -rf ~
deny rm -r ~
deny rm -r ~/
deny rm -Rf ~/*
deny cd repo && rm -fr ~
deny rm -r ~ build" \
    "$(decisions_for "rm -rf ~" "rm -r ~" "rm -r ~/" "rm -Rf ~/*" "cd repo && rm -fr ~" "rm -r ~ build")"
}

function test_denies_a_recursive_delete_of_a_bare_variable() {
  assert_same 'deny rm -rf "$d"
deny rm -r "$d"
deny rm -r $d
deny rm -r ${dir}
deny cd repo && rm -fr "$out"
deny rm -Rf "$HOME"
deny rm -r "$HOME/"
deny rm -r $HOME/*' \
    "$(decisions_for 'rm -rf "$d"' 'rm -r "$d"' 'rm -r $d' 'rm -r ${dir}' 'cd repo && rm -fr "$out"' \
      'rm -Rf "$HOME"' 'rm -r "$HOME/"' 'rm -r $HOME/*')"
}

function test_asks_before_a_recursive_delete_of_a_path_under_a_variable() {
  assert_same 'ask rm -r "$d/out"
ask rm -r $d/out
ask cd repo && rm -fR "${out}/cache"
ask rm -R "$HOME/prj/x"' \
    "$(decisions_for 'rm -r "$d/out"' 'rm -r $d/out' 'cd repo && rm -fR "${out}/cache"' 'rm -R "$HOME/prj/x"')"
}

function test_denies_a_recursive_delete_of_a_system_folder() {
  assert_same "$(printf 'deny %s\n' "${SYSTEM_DELETES[@]}")" "$(decisions_for "${SYSTEM_DELETES[@]}")"
}

function test_denies_a_recursive_delete_in_the_library_folder_of_a_user() {
  assert_same "$(printf 'deny %s\n' "${LIBRARY_DELETES[@]}")" "$(decisions_for "${LIBRARY_DELETES[@]}")"
}

function test_allows_a_recursive_delete_under_the_temp_folders() {
  assert_same "$(printf 'allow %s\n' "${TEMP_DELETES[@]}")" "$(decisions_for "${TEMP_DELETES[@]}")"
}

function test_allows_rmdir_trash_or_find_delete_under_the_temp_folders() {
  assert_same "$(printf 'allow %s\n' "${OTHER_TEMP_DELETES[@]}")" "$(decisions_for "${OTHER_TEMP_DELETES[@]}")"
}

function test_still_allows_a_delete_of_files_or_a_find_with_no_delete() {
  assert_same "$(printf 'allow %s\n' "${FILE_DELETES[@]}")" "$(decisions_for "${FILE_DELETES[@]}")"
}

function test_asks_when_a_temp_delete_also_deletes_another_folder() {
  assert_same "$(printf 'ask %s\n' "${MIXED_DELETES[@]}")" "$(decisions_for "${MIXED_DELETES[@]}")"
}

function test_asks_when_a_temp_delete_climbs_out_of_the_temp_folder() {
  assert_same "$(printf 'ask %s\n' "${CLIMBING_DELETES[@]}")" "$(decisions_for "${CLIMBING_DELETES[@]}")"
}

function test_does_not_deny_for_a_later_command_that_names_a_variable_or_a_protected_folder() {
  assert_same "ask rm -rf build && echo \$?
allow rm -f out.txt; printf '%s' \"\$x\"
ask rm -rf build && cd ~
ask rm -rf /tmp/x && /usr/bin/find . -name y
ask rm -rf build && ls ~/Library/Logs
ask rm -rf Game/Library" \
    "$(decisions_for 'rm -rf build && echo $?' "rm -f out.txt; printf '%s' \"\$x\"" "rm -rf build && cd ~" \
      "rm -rf /tmp/x && /usr/bin/find . -name y" "rm -rf build && ls ~/Library/Logs" "rm -rf Game/Library")"
}

# Prints "<decision> <command>" for each argument, from the decisions of
# set_up_before_script.
decisions_for() {
  local wanted state line
  for wanted in "$@"; do
    state=missing
    while IFS= read -r line; do
      [[ ${line#* } == "$wanted" ]] && state=${line%% *}
    done < "$DECISIONS"
    echo "$state $wanted"
  done
}

# Prints "<decision> <command>" for each argument after the first, which is
# the scratch folder, as the extension decides under the real policy file. It
# checks each command and never runs it.
decide() {
  local empty=$1
  shift
  NODE_PATH="$PI_MODULES" POLICY="$POLICY" EXTENSION="$EXTENSION" EMPTY="$empty" bun -e '
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
