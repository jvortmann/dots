#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT/pi/update-impeccable.sh"

function set_up() {
  [[ -f $SCRIPT ]] || bashunit::fail "missing the file under test: $SCRIPT"
  DOTS=$(bashunit::temp_dir "dots")
  SKILL="$DOTS/pi/skills/impeccable"
  mkdir -p "$SKILL/reference" "$DOTS/mise"
  printf -- '---\nname: impeccable\ndescription: Our own description.\n---\nOld body.\n' > "$SKILL/SKILL.md"
  printf 'old\n' > "$SKILL/reference/old.md"
  printf '"github:pbakaus/impeccable" = { version = "0.1.8", version_prefix = "engine-v" }\n' \
    > "$DOTS/mise/config.toml"
  INSTALLER=$(bashunit::temp_file "impeccable")
  fake_installer > "$INSTALLER"
  chmod +x "$INSTALLER"
}

function test_replaces_the_skill_files_with_the_new_release() {
  run_update

  assert_file_exists "$SKILL/reference/new.md"
  assert_file_not_exists "$SKILL/reference/old.md"
}

function test_keeps_our_description_and_takes_the_new_body() {
  run_update

  assert_same "---
name: impeccable
description: Our own description.
---
New body." "$(cat "$SKILL/SKILL.md")"
}

function test_keeps_the_license_notice_and_upstream_notes() {
  printf 'license\n' > "$SKILL/LICENSE"
  printf 'notice\n' > "$SKILL/NOTICE.md"
  printf 'upstream\n' > "$SKILL/UPSTREAM"

  run_update

  assert_same "license notice upstream" "$(cat "$SKILL/LICENSE" "$SKILL/NOTICE.md" "$SKILL/UPSTREAM" | paste -sd' ' -)"
}

function test_leaves_out_the_engine_binary() {
  run_update

  assert_directory_not_exists "$SKILL/scripts/bin"
}

function test_sets_the_mise_engine_version_to_the_new_release() {
  run_update

  assert_same '"github:pbakaus/impeccable" = { version = "9.9.9", version_prefix = "engine-v" }' \
    "$(cat "$DOTS/mise/config.toml")"
}

run_update() {
  DOTS="$DOTS" IMPECCABLE="$INSTALLER" "$SCRIPT" > /dev/null 2>&1
}

# A stand-in for upstream's installer: it writes release 9.9.9 where upstream
# writes a global pi install, under $HOME.
fake_installer() {
  cat <<'EOF'
#!/bin/bash
new="$HOME/.pi/agent/skills/impeccable"
mkdir -p "$new/reference" "$new/scripts/bin"
printf -- '---\nname: impeccable\ndescription: Upstream description.\n---\nNew body.\n' > "$new/SKILL.md"
printf 'new\n' > "$new/reference/new.md"
printf '9.9.9\n' > "$new/scripts/VERSION"
printf 'binary\n' > "$new/scripts/bin/impeccable"
EOF
}
