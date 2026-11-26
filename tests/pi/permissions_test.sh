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
  "rm -rf /tmp/out" "rm -r /private/tmp/out" "rm -Rf /var/folders/ab/cd/T/tmp.X"
  "rm -fr /private/var/folders/ab/cd/T/out" "rm -fR /tmp/out" "rm -R /tmp/out"
)
OTHER_TEMP_DELETES=()
for folder in /tmp /private/tmp /var/folders/ab/cd/T /private/var/folders/ab/cd/T; do
  OTHER_TEMP_DELETES+=("rmdir $folder/x" "trash $folder/x" "find $folder/x -delete")
done
FILE_DELETES=(
  "rm -f /tmp/msg.txt" 'rm "$M"' 'rm -f "$dir/report.txt"' "rm -f /tmp/a.txt /tmp/b.txt" "rm -f a.txt b.txt"
  "find /tmp/x -type f -name '*.log'" 'rm -f "/tmp/$f.txt"' 'rm -f /tmp/$f.txt; ls'
)
CLIMBING_DELETES=(
  "rm -rf /tmp/../Users/someone/prj" "rm -R /var/folders/ab/cd/T/../../x" "rmdir /tmp/../x"
  "trash /private/tmp/../x" "find /tmp/../x -delete" "rm -rf /tmp/{x,../y}" "rm -r /tmp/../x; ls"
  'rm -r "/tmp/scratch/../x"' 'rm -r /tmp/scratch/${d:?}/..' 'rm -r "/tmp/scratch/${d:?}/../x"; ls'
)
UI_CONTROL=(
  "osascript -e 'tell application \"Herdr\" to quit'" "cd repo && osascript -e 'beep'"
  $'cat > /tmp/keys.applescript <<\'EOF\'\ntell application "System Events" to keystroke "a"\nEOF'
  $'cat > /tmp/press.swift <<\'EOF\'\nlet e = CGEvent(keyboardEventSource: nil, virtualKey: 120, keyDown: true)\nEOF\ntimeout 60 swift /tmp/press.swift 4664 120'
  "swift -e 'event.postToPid(4664)'" "swift -e 'AXUIElementCreateApplication(4664)'"
  "cliclick c:100,200" "cd repo && cliclick kp:return" "screencapture -x /tmp/s.png" "cd repo && screencapture /tmp/s.png"
)
WIDE_SEARCHES=(
  "rg --files -g 'herdr.d.ts' ~ 2>/dev/null | head -3" "find ~ -maxdepth 4 -name hc -type f"
  "find / -path /proc -prune -o -name tui.js -print" "cd repo && find / -name tui.js"
  "ls ~" "find ~/ -name hc" "ls ~/" 'find $HOME -name hc' 'ls $HOME' 'find "$HOME" -name hc' 'ls "$HOME"'
)
PROTECTED_READS=("ls -lt ~/.Trash" 'cd repo && ls "$HOME/Library/Mobile Documents"')
for folder in Pictures .Trash Library/CloudStorage "Library/Mobile Documents" Library/Containers; do
  PROTECTED_READS+=("ls ~/$folder" "ls \"\$HOME/$folder\"" "ls /Users/someone/$folder")
done
NARROW_READS=(
  "ls ~/.config/pi" "ls ~/.local/state/herdr-core" "rg -n foo ~/prj/config/dots" "find /tmp/x -name y" "ls /tmp"
  "defaults read com.apple.HIToolbox" "ls ~/Desktop" 'ls "$HOME/Documents"' "git show HEAD~"
)
RESEARCH_FOLDERS=(
  /Users/someone/.dots /Users/someone/.config/{pi,nvim,git,herdr,herdr-app,ghostty,zsh,aerospace}
  /Users/someone/.local/share/mise/installs/npm-earendil-works-pi-coding-agent /Users/someone/.local/share/nvim
  /Users/someone/.local/state/herdr-core /Users/someone/.local/state/dots /opt/homebrew/share
  /opt/homebrew/Cellar/neovim/0.11.0/share /Users/someone/Documents /Users/someone/Desktop
)
RESEARCH_READS=()
RESEARCH_WRITES=()
for folder in "${RESEARCH_FOLDERS[@]}"; do
  RESEARCH_READS+=("external_directory:$folder" "external_directory:$folder/x")
  RESEARCH_WRITES+=("write:$folder/x" "edit:$folder/x")
done
PROTECTED_INSIDE_OPEN=(
  "external_directory:/Users/someone/Library/Containers/com.x/Data/Documents/x"
  "external_directory:/Users/someone/Library/Containers/com.x/Data/tmp/x"
  "external_directory:/Users/someone/Library/Mobile Documents/com~apple~CloudDocs/Desktop/x"
  "external_directory:/Users/someone/Library/CloudStorage/Drive/Documents/x"
  "external_directory:/Users/someone/.Trash/Desktop/x" "external_directory:/Users/someone/Pictures/Documents/x"
)
GH_TOKEN_READS=("external_directory:/Users/someone/.config/gh" "external_directory:/Users/someone/.config/gh/hosts.yml")
WORK_FOLDERS=(/Users/someone/prj/config /Users/someone/tmp)
WORK_READS=()
WORK_WRITES=()
for folder in "${WORK_FOLDERS[@]}"; do
  WORK_READS+=("external_directory:$folder" "external_directory:$folder/x")
  WORK_WRITES+=("write:$folder/x" "edit:$folder/x")
done
WORK_WRITES+=("write:/Users/someone/prj/config/vim-files/Documents/x" "edit:/Users/someone/prj/config/vim-files/Desktop/x")
MIXED_DELETES=(
  "rm -rf /tmp/x build" "rm -rf build /tmp/x" "rm -rf /tmp/x && rm -rf build" "rm -f /tmp/x && rm -rf build"
  "rmdir /tmp/x build" "trash /tmp/x && rm -rf build" "find /tmp/x build -delete"
  "find /tmp/x -delete && find build -delete" "rm -rf /tmp/x build; ls" "rm -rf /tmp/x build && ls"
  "rm -r /tmp/x && rmdir build" "rm -r /tmp/x; trash build" "rm -r /tmp/x && find build -delete"
  "rm -r /tmp/x; /usr/bin/find build -delete" "rm -r /tmp/x && git clean -fd" "rm -r /tmp/x; git -C repo clean -fd"
  'rm -r /tmp/scratch/${d:?} build' 'rm -r build "/tmp/scratch/${d:?}"' 'rm -f -r build "/tmp/scratch/x"'
  'rm --recursive build "/tmp/scratch/x"' 'rm -r /var/folders/ab /etc/T/${d:?}' 'rm -r /tmp/${d:?} /etc/${e:?}'
)
SCRATCH_DELETES=(
  "rm -r /tmp/scratch/step42.Ab12Cd" 'rm -r "/tmp/scratch/step42.Ab12Cd"' 'rm -rf "/tmp/scratch/step42.Ab12Cd"'
)
SCRATCH_GUARDED_DELETES=('rm -r "/tmp/scratch/${d:?}"' 'rm -r /tmp/scratch/${d:?}' 'rm -Rf "/tmp/scratch/${d:?}"')
SCRATCH_EMPTY_NAMES=(
  'rm -r /tmp/scratch/$d' 'rm -r "/tmp/scratch/$d"' 'rm -r /tmp/scratch/${d}' 'rm -r /tmp/scratch/$d; ls'
  'rm -r "/tmp/scratch/$d" && ls' 'rm -r "/tmp/scratch/${d:-}"' 'rm -r /tmp/scratch/${d:+}' 'rm -r /tmp/scratch/${d:=}'
  'rm -r /tmp/scratch/${d}; ls ${e:?}' 'rm -r /tmp/scratch/${d:+:?}' 'rm -r "/tmp/scratch/${d#*:?}"'
  'rm -r "/tmp/scratch/${d%%*:?}"' 'rm -r "/tmp/scratch/`true`"'
)
SCRATCH_ROOT_DELETES=(
  "rm -r /tmp/scratch/" "rm -r /tmp/scratch" 'rm -r "/tmp/scratch/"' 'rm -rf "/tmp/scratch"' "rm -r /tmp/scratch/ && ls"
  "rm -r /tmp/scratch/; ls" "rm -r /tmp/scratch; ls" "rm -r /tmp/scratch/*" "rm -rf /tmp/scratch/* && ls"
  "rm -r /tmp/scratch/*; ls"
)
TEMP_GUARDED_DELETES=(
  'rm -r /tmp/${d:?}' 'rm -rf /private/tmp/${d:?}' 'rm -R /var/folders/ab/cd/T/${d:?}'
  'rm -fr /private/var/folders/ab/cd/T/${d:?}' 'rm -r /tmp/${d:?}; ls' 'rm -rf /private/tmp/${d:?} && ls'
  'rm -r /var/folders/ab/cd/T/${d:?}; ls' 'rm -Rf /private/var/folders/ab/cd/T/${d:?} && git status'
)
TEMP_EMPTY_NAMES=(
  'rm -r /tmp/$d' 'rm -r /tmp/${d}' 'rm -rf /private/tmp/$d' 'rm -R /var/folders/ab/cd/T/$d'
  'rm -fr /private/var/folders/ab/cd/T/$d' 'rm -r /tmp/$d; ls' 'rm -r /tmp/$d && ls' 'rm --recursive /tmp/$d; ls'
  'rm -r /tmp/"$d"' 'rm -rf /private/var/folders/ab/cd/T/"$d"; ls' 'rm -r /tmp//$d' 'rm -rf /private/var/folders/ab/cd/T//$d; ls' 'rm -r /tmp/$(true)' 'rm -r /tmp/${d:-}' 'rm -r /private/tmp/${d:+}' 'rm -r /tmp/${d:=}' 'rm -r /tmp/${d:+:?}'
  'rm -r /var/folders/ab/cd/T/${d#*:?}' 'rm -r /private/var/folders/ab/cd/T/${d%%*:?}' 'rm -r /tmp/`true`'
  'rm -rf /private/var/folders/ab/cd/T/`true`; ls' 'rm -r /tmp/${d}; ls ${e:?}' 'rm -r /var/folders/ab/cd/T/${d}; ls ${e:?}'
)
TEMP_ROOT_DELETES=(
  "rm -r /tmp/" "rm -rf /private/tmp/" "rm -r /var/folders/ab/cd/T/" "rm -R /private/var/folders/ab/cd/T/"
  "rm -r /tmp/ && ls" "rm -r /tmp/; ls" "rm -rf /private/tmp/; ls" "rm -r /var/folders/ab/cd/T/ && ls"
  "rm -r /tmp/*" "rm -rf /private/tmp/*" "rm -r /var/folders/ab/cd/T/*" "rm -fr /private/var/folders/ab/cd/T/*"
  "rm -r /tmp/* && ls" "rm -r /tmp/*; ls" "rm -rf /private/tmp/*; ls" "rm -R /var/folders/ab/cd/T/* && ls"
)
DANGER_AFTER_TEMP_DELETES=(
  "rm -r /tmp/x; rm -rf ~" "rm -r /tmp/x && rm -rf /" 'rm -r /tmp/x; rm -r "$d"' "rm -r /tmp/x && rm -r /Users"
  'rm -r "/tmp/scratch/${d:?}"; rm -rf ~'
)
FOLLOWED_TEMP_DELETES=(
  "rm -r /tmp/out; ls /tmp" "rm -r /tmp/out && git status" "rm -rf /private/tmp/out; ls"
  "rm -R /var/folders/ab/cd/T/out && ls" "rm -fr /private/var/folders/ab/cd/T/out; ls"
  'rm -r "/tmp/scratch/step42.Ab12Cd"; ls /tmp/scratch' 'rm -r "/tmp/scratch/step42.Ab12Cd" && git status'
  'rm -r "/tmp/scratch/${d:?}"; ls /tmp/scratch' 'rm -rf /tmp/scratch/${d:?} && git status'
)
# Each ~ below stays as text, because the policy checks the command as text.
# shellcheck disable=SC2088
END_SCRATCH_CALLS=(
  '~/.config/pi/end-scratch-processes.sh 4242 4343' '$HOME/.config/pi/end-scratch-processes.sh 4242'
  '"$HOME/.config/pi/end-scratch-processes.sh" 4242' "pi/end-scratch-processes.sh 4242"
  "/Users/someone/prj/config/dots/pi/end-scratch-processes.sh 4242"
)
# shellcheck disable=SC2088
PROCESS_SIGNALS=(
  "kill 4242" "kill -9 4242" "cd repo && kill 4242" "pkill -f bashunit" "killall tmux" "cd repo && killall tmux"
  '~/.config/pi/end-scratch-processes.sh 4242; kill 4343' '~/.config/pi/end-scratch-processes.sh 4242 && pkill tmux'
)
SCRATCH_PKILLS=(
  "pkill -f /tmp/scratch/step57.Ab12Cd" "pkill -KILL -f /tmp/scratch/step57.Ab12Cd/fake"
  "pkill -TERM -f /tmp/scratch/step57"
)
WORK_FOLDER_PKILLS=(
  "pkill -f /tmp/tests-run.Ab12Cd" "pkill -KILL -f /var/folders/ab/cd/T/tests-run.Ab12Cd"
  "pkill -TERM -f /var/folders/ab/cd/T/tests-run.Ab12Cd/bashunit"
)
SOCKET_PKILLS=(
  'pkill -f "tmux -L tests-run-4242"' "pkill -KILL -f 'tmux -L tests-run-4242'" 'pkill -TERM -f "tmux -L tests-run-4242 "'
)
CHAINED_PKILLS=(
  "pkill -f /tmp/scratch/x; kill 1" "pkill -f /tmp/scratch/x && kill 1" "pkill -KILL -f /tmp/scratch/x || killall tmux"
  "pkill -f /tmp/scratch/x | sh" "pkill -f /tmp/scratch/x&kill 1" $'pkill -f /tmp/scratch/x\nkill 1'
  'pkill -f /tmp/scratch/x$(kill 1)' 'pkill -f /tmp/scratch/x`kill 1`' "pkill -f /tmp/tests-run.x>/tmp/out.txt"
  'pkill -f /tmp/scratch/x<(kill 1)'
  'pkill -f "tmux -L tests-run-4242"; kill 1' "pkill -TERM -f 'tmux -L tests-run-4242' && kill 1"
  'pkill -f "tmux -L tests-run-$(kill 1)"' "ls; pkill -f /tmp/scratch/x" "cd repo && pkill -f /tmp/scratch/x"
)
SECOND_PATTERN_PKILLS=(
  "pkill -f /tmp/scratch/x bash" "pkill -KILL -f /var/folders/a bash /T/tests-run.x" "pkill -f /tmp/scratch/x' bash'"
  'pkill -f "tmux -L tests-run-4242" "bash"' "pkill -TERM -f 'tmux -L tests-run-4242' 'bash'"
  $'pkill -f /tmp/scratch/x\tbash'
)
CLIMBING_PKILLS=(
  "pkill -f /tmp/scratch/../x" "pkill -KILL -f /var/folders/../../etc/T/tests-run.x"
  'pkill -f /var/folders/\(/T/tests-run.x\)\?'
)
SCRATCH_ROOT_PKILLS=(
  "pkill -f /tmp/scratch" "pkill -f /tmp/scratch/" "pkill -KILL -f /tmp/scratch/*" "pkill -f /tmp/scratch/.*"
  "pkill -f /tmp/scratch/''" 'pkill -TERM -f /tmp/scratch/""' "pkill -f /tmp/scratch/[^/]" "pkill -f /tmp/scratch/x{0}"
  'pkill -f /tmp/scratch/\.\*'
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
    "cd /tmp && rm -rf pt" "rm -rf build" "cd repo && rm -rf x" 'rm -rf "$d/out"' \
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
    "${FOLLOWED_TEMP_DELETES[@]}" "${DANGER_AFTER_TEMP_DELETES[@]}" "${SCRATCH_DELETES[@]}" "${SCRATCH_EMPTY_NAMES[@]}" "${SCRATCH_GUARDED_DELETES[@]}" \
    "${SCRATCH_ROOT_DELETES[@]}" "${TEMP_EMPTY_NAMES[@]}" "${TEMP_GUARDED_DELETES[@]}" "${TEMP_ROOT_DELETES[@]}" \
    'rm -rf build && echo $?' "rm -f out.txt; printf '%s' \"\$x\"" "rm -rf build && cd ~" \
    "rm -rf /tmp/out && /usr/bin/find . -name y" "rm -rf build && ls ~/Library/Logs" "rm -rf Game/Library" \
    "${UI_CONTROL[@]}" "${WIDE_SEARCHES[@]}" "${PROTECTED_READS[@]}" "${NARROW_READS[@]}" \
    "${RESEARCH_READS[@]}" "${RESEARCH_WRITES[@]}" "${WORK_READS[@]}" "${WORK_WRITES[@]}" \
    "${PROTECTED_INSIDE_OPEN[@]}" "${GH_TOKEN_READS[@]}" "${END_SCRATCH_CALLS[@]}" "${PROCESS_SIGNALS[@]}" \
    "${SCRATCH_PKILLS[@]}" "${WORK_FOLDER_PKILLS[@]}" "${SOCKET_PKILLS[@]}" "${CHAINED_PKILLS[@]}" "${SECOND_PATTERN_PKILLS[@]}" "${CLIMBING_PKILLS[@]}" "${SCRATCH_ROOT_PKILLS[@]}" \
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

function test_allows_a_temp_delete_that_another_command_follows() {
  assert_same "$(printf 'allow %s\n' "${FOLLOWED_TEMP_DELETES[@]}")" "$(decisions_for "${FOLLOWED_TEMP_DELETES[@]}")"
}

function test_allows_a_delete_of_a_scratch_folder_by_its_name_quoted_or_not() {
  assert_same "$(printf 'allow %s\n' "${SCRATCH_DELETES[@]}")" "$(decisions_for "${SCRATCH_DELETES[@]}")"
}

function test_allows_a_delete_of_a_scratch_folder_by_a_variable_that_stops_when_empty() {
  assert_same "$(printf 'allow %s\n' "${SCRATCH_GUARDED_DELETES[@]}")" "$(decisions_for "${SCRATCH_GUARDED_DELETES[@]}")"
}

function test_asks_when_a_scratch_delete_has_a_name_that_can_be_empty() {
  assert_same "$(printf 'ask %s\n' "${SCRATCH_EMPTY_NAMES[@]}")" "$(decisions_for "${SCRATCH_EMPTY_NAMES[@]}")"
}

function test_allows_a_temp_delete_by_a_variable_that_stops_when_empty() {
  assert_same "$(printf 'allow %s\n' "${TEMP_GUARDED_DELETES[@]}")" "$(decisions_for "${TEMP_GUARDED_DELETES[@]}")"
}

function test_asks_when_a_temp_delete_has_a_name_that_can_be_empty() {
  assert_same "$(printf 'ask %s\n' "${TEMP_EMPTY_NAMES[@]}")" "$(decisions_for "${TEMP_EMPTY_NAMES[@]}")"
}

function test_asks_before_a_delete_of_a_whole_temp_folder() {
  assert_same "$(printf 'ask %s\n' "${TEMP_ROOT_DELETES[@]}")" "$(decisions_for "${TEMP_ROOT_DELETES[@]}")"
}

function test_asks_before_a_delete_of_the_whole_scratch_folder() {
  assert_same "$(printf 'ask %s\n' "${SCRATCH_ROOT_DELETES[@]}")" "$(decisions_for "${SCRATCH_ROOT_DELETES[@]}")"
}

function test_denies_a_dangerous_delete_after_a_temp_delete() {
  assert_same "$(printf 'deny %s\n' "${DANGER_AFTER_TEMP_DELETES[@]}")" "$(decisions_for "${DANGER_AFTER_TEMP_DELETES[@]}")"
}

function test_asks_when_a_temp_delete_climbs_out_of_the_temp_folder() {
  assert_same "$(printf 'ask %s\n' "${CLIMBING_DELETES[@]}")" "$(decisions_for "${CLIMBING_DELETES[@]}")"
}

function test_does_not_deny_for_a_later_command_that_names_a_variable_or_a_protected_folder() {
  assert_same "ask rm -rf build && echo \$?
allow rm -f out.txt; printf '%s' \"\$x\"
ask rm -rf build && cd ~
allow rm -rf /tmp/out && /usr/bin/find . -name y
ask rm -rf build && ls ~/Library/Logs
ask rm -rf Game/Library" \
    "$(decisions_for 'rm -rf build && echo $?' "rm -f out.txt; printf '%s' \"\$x\"" "rm -rf build && cd ~" \
      "rm -rf /tmp/out && /usr/bin/find . -name y" "rm -rf build && ls ~/Library/Logs" "rm -rf Game/Library")"
}

function test_asks_before_a_command_that_controls_the_user_interface() {
  assert_same "$(printf 'ask %s\n' "${UI_CONTROL[@]}")" "$(decisions_for "${UI_CONTROL[@]}")"
}

function test_asks_before_a_search_from_the_root_or_the_home_folder() {
  assert_same "$(printf 'ask %s\n' "${WIDE_SEARCHES[@]}")" "$(decisions_for "${WIDE_SEARCHES[@]}")"
}

function test_asks_before_a_read_of_a_protected_folder() {
  assert_same "$(printf 'ask %s\n' "${PROTECTED_READS[@]}")" "$(decisions_for "${PROTECTED_READS[@]}")"
}

function test_still_allows_a_read_of_a_folder_that_macos_does_not_protect() {
  assert_same "$(printf 'allow %s\n' "${NARROW_READS[@]}")" "$(decisions_for "${NARROW_READS[@]}")"
}

function test_allows_a_subagent_to_read_the_research_folders() {
  assert_same "$(printf 'allow %s\n' "${RESEARCH_READS[@]}")" "$(decisions_for "${RESEARCH_READS[@]}")"
}

function test_asks_before_a_write_or_an_edit_in_the_research_folders() {
  assert_same "$(printf 'ask %s\n' "${RESEARCH_WRITES[@]}")" "$(decisions_for "${RESEARCH_WRITES[@]}")"
}

function test_asks_before_a_subagent_reads_a_protected_folder_that_an_open_folder_name_matches() {
  assert_same "$(printf 'ask %s\n' "${PROTECTED_INSIDE_OPEN[@]}")" "$(decisions_for "${PROTECTED_INSIDE_OPEN[@]}")"
}

function test_asks_before_a_subagent_reads_the_config_folder_that_holds_the_gh_token() {
  assert_same "$(printf 'ask %s\n' "${GH_TOKEN_READS[@]}")" "$(decisions_for "${GH_TOKEN_READS[@]}")"
}

function test_allows_a_subagent_to_read_the_sibling_repositories_and_home_tmp() {
  assert_same "$(printf 'allow %s\n' "${WORK_READS[@]}")" "$(decisions_for "${WORK_READS[@]}")"
}

function test_allows_a_write_or_an_edit_in_the_sibling_repositories_and_home_tmp() {
  assert_same "$(printf 'allow %s\n' "${WORK_WRITES[@]}")" "$(decisions_for "${WORK_WRITES[@]}")"
}

function test_allows_the_script_that_ends_leftover_processes_by_its_path() {
  assert_same "$(printf 'allow %s\n' "${END_SCRATCH_CALLS[@]}")" "$(decisions_for "${END_SCRATCH_CALLS[@]}")"
}

function test_asks_before_kill_pkill_or_killall_also_after_the_script() {
  assert_same "$(printf 'ask %s\n' "${PROCESS_SIGNALS[@]}")" "$(decisions_for "${PROCESS_SIGNALS[@]}")"
}

function test_allows_a_pkill_of_the_processes_in_a_scratch_folder() {
  assert_same "$(printf 'allow %s\n' "${SCRATCH_PKILLS[@]}")" "$(decisions_for "${SCRATCH_PKILLS[@]}")"
}

function test_allows_a_pkill_of_the_processes_in_a_work_folder_of_tests_run() {
  assert_same "$(printf 'allow %s\n' "${WORK_FOLDER_PKILLS[@]}")" "$(decisions_for "${WORK_FOLDER_PKILLS[@]}")"
}

function test_allows_a_pkill_of_a_tmux_server_on_a_socket_of_tests_run() {
  assert_same "$(printf 'allow %s\n' "${SOCKET_PKILLS[@]}")" "$(decisions_for "${SOCKET_PKILLS[@]}")"
}

function test_asks_before_a_pkill_of_scratch_processes_with_another_command_in_the_line() {
  assert_same "$(printf 'ask %s\n' "${CHAINED_PKILLS[@]}")" "$(decisions_for "${CHAINED_PKILLS[@]}")"
}

function test_asks_before_a_pkill_that_holds_a_second_pattern() {
  assert_same "$(printf 'ask %s\n' "${SECOND_PATTERN_PKILLS[@]}")" "$(decisions_for "${SECOND_PATTERN_PKILLS[@]}")"
}

function test_asks_before_a_pkill_whose_pattern_climbs_out_of_the_folder() {
  assert_same "$(printf 'ask %s\n' "${CLIMBING_PKILLS[@]}")" "$(decisions_for "${CLIMBING_PKILLS[@]}")"
}

function test_asks_before_a_pkill_of_every_process_in_the_scratch_folder() {
  assert_same "$(printf 'ask %s\n' "${SCRATCH_ROOT_PKILLS[@]}")" "$(decisions_for "${SCRATCH_ROOT_PKILLS[@]}")"
}

# Prints "<decision> <command>" for each argument, from the decisions of
# set_up_before_script.
decisions_for() {
  local wanted encoded state line
  for wanted in "$@"; do
    state=missing
    while IFS= read -r line; do
      encoded=${wanted//\\/\\\\}
      [[ ${line#* } == "${encoded//$'\n'/\\n}" ]] && state=${line%% *}
    done < "$DECISIONS"
    echo "$state $wanted"
  done
}

# Prints "<decision> <command>" for each argument after the first, which is
# the scratch folder, as the extension decides under the real policy file. It
# checks each command and never runs it. An argument such as `write:/path`
# checks that path for that tool, in the form of a policy key.
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
      const path = command.match(/^(external_directory|write|edit):(\/.*)$/);
      const check = path
        ? manager.checkPermission(path[1], { path: path[2], cwd: process.env.EMPTY })
        : manager.checkPermission("bash", { command });
      console.log(check.state + " " + command.replaceAll("\\", "\\\\").replaceAll("\n", "\\n"));
    }
  ' "$@"
}
