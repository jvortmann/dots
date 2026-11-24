#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT/pi/update-impeccable.sh"
# shellcheck source=../fakes/fakes.sh
source "$ROOT/tests/fakes/fakes.sh"

function set_up() {
  [[ -f $SCRIPT ]] || bashunit::fail "missing the file under test: $SCRIPT"
  DOTS=$(bashunit::temp_dir "dots")
  SKILL="$DOTS/pi/skills/impeccable"
  mkdir -p "$SKILL/reference" "$DOTS/mise"
  printf -- '---\nname: impeccable\ndescription: Our own description.\n---\nOld body.\n' > "$SKILL/SKILL.md"
  printf 'old\n' > "$SKILL/reference/old.md"
  printf '"github:pbakaus/impeccable" = { version = "latest", version_prefix = "engine-v", postinstall = "$HOME/.dots/pi/update-impeccable.sh" }\n' \
    > "$DOTS/mise/config.toml"
  CALLER=$(bashunit::temp_dir "caller")
  local bin
  bin=$(bashunit::temp_dir "bin")
  fake_program "$bin" impeccable "$(fake_installer)"
  INSTALLER="$bin/impeccable"
}

function test_replaces_the_skill_files_with_the_new_release() {
  run_update

  assert_file_exists "$SKILL/reference/new.md"
  assert_file_not_exists "$SKILL/reference/old.md"
}

function test_takes_the_new_skill_description_and_body() {
  run_update

  assert_same "---
name: impeccable
description: Upstream description.
---
New body." "$(cat "$SKILL/SKILL.md")"
}

function test_removes_the_license_notice_and_upstream_notes() {
  printf 'license\n' > "$SKILL/LICENSE"
  printf 'notice\n' > "$SKILL/NOTICE.md"
  printf 'upstream\n' > "$SKILL/UPSTREAM"

  run_update

  assert_same "SKILL.md reference scripts" "$(LC_ALL=C ls "$SKILL" | paste -sd' ' -)"
}

function test_leaves_out_the_engine_binary() {
  run_update

  assert_directory_not_exists "$SKILL/scripts/bin"
}

function test_leaves_the_mise_engine_version_alone() {
  run_update

  assert_same '"github:pbakaus/impeccable" = { version = "latest", version_prefix = "engine-v", postinstall = "$HOME/.dots/pi/update-impeccable.sh" }' \
    "$(cat "$DOTS/mise/config.toml")"
}

function test_removes_its_temporary_folder() {
  run_update

  assert_file_exists "$INSTALLER.root"
  assert_directory_not_exists "$(cat "$INSTALLER.root")"
}

function test_removes_its_temporary_folder_when_the_install_fails() {
  touch "$INSTALLER.fail"

  run_update

  assert_file_exists "$INSTALLER.root"
  assert_directory_not_exists "$(cat "$INSTALLER.root")"
}

function test_leaves_the_folder_it_runs_from_alone() {
  run_update

  assert_is_directory_empty "$CALLER"
}

run_update() {
  (cd "$CALLER" && DOTS="$DOTS" IMPECCABLE="$INSTALLER" "$SCRIPT" > /dev/null 2>&1)
}

# A stand-in for upstream's installer: it writes release 9.9.9 where upstream
# writes a project pi install, under the current folder. It records that folder
# in $0.root, and fails when $0.fail exists.
fake_installer() {
  cat <<'EOF'
case " $* " in *" --scope=project "*) ;; *) exit 1 ;; esac
printf '%s\n' "$PWD" > "$0.root"
[ ! -e "$0.fail" ] || exit 1
new="$PWD/.pi/skills/impeccable"
mkdir -p "$new/reference" "$new/scripts/bin"
printf -- '---\nname: impeccable\ndescription: Upstream description.\n---\nNew body.\n' > "$new/SKILL.md"
printf 'new\n' > "$new/reference/new.md"
printf '9.9.9\n' > "$new/scripts/VERSION"
printf 'binary\n' > "$new/scripts/bin/impeccable"
EOF
}
