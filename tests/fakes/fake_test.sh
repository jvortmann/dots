#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/fakes.sh"

function test_runs_its_code_when_sh_is_dash() {
  local dir
  dir=$(bashunit::temp_dir "fake")
  fake_program "$dir" greet 'echo "hello $1"'

  assert_same "hello you" "$(dash "$dir/greet" you 2>&1 < /dev/null)"
}

function test_closes_a_descriptor_above_9_of_the_test_when_sh_is_dash() {
  local dir held
  dir=$(bashunit::temp_dir "fake")
  fake_program "$dir" probe 'if [ -e "/dev/fd/$1" ]; then echo open; else echo closed; fi'
  exec {held}> /dev/null

  assert_same "closed" "$(dash "$dir/probe" "$held" 2>&1 < /dev/null)"
  exec {held}>&-
}
