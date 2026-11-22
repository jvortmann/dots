#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
EDGE="$ROOT/herdr-app/mods/recent-picker/edge.js"

function set_up() {
  [[ -f $EDGE ]] || bashunit::fail "missing the file under test: $EDGE"
}

function test_an_opaque_border_gives_an_edge_at_a_quarter_strength() {
  assert_same "#586e7540" "$(edge_of "#586e75")"
}

function test_a_border_with_alpha_gives_an_edge_at_a_quarter_of_that_alpha() {
  assert_same "#ffffff06" "$(edge_of "#ffffff18")"
}

edge_of() {
  EDGE="$EDGE" mise x node@latest -- node --input-type=module -e '
    const { quarter } = await import(process.env.EDGE);
    console.log(quarter(process.argv[1]));
  ' "$1"
}
