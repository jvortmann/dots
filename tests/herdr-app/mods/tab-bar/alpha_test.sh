#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
ALPHA="$ROOT/herdr-app/mods/tab-bar/alpha.js"

function set_up() {
  [[ -f $ALPHA ]] || bashunit::fail "missing the file under test: $ALPHA"
}

function test_an_opaque_color_takes_the_share_as_its_alpha() {
  assert_same "#586e7540" "$(alpha_of "#586e75" 0.25)"
}

# The border of atom-one-dark is #ffffff18. A second alpha byte after it is no
# color, and the tab bar failed to draw.
function test_a_color_with_an_alpha_of_its_own_keeps_the_share_of_that_alpha() {
  assert_same "#ffffff06" "$(alpha_of "#ffffff18" 0.25)"
}

# The app reads #rgb, #rrggbb and #rrggbbaa, and no #rgba. So a theme color
# has no #rgba form.
function test_a_short_color_takes_the_long_form_with_the_share_as_its_alpha() {
  assert_same "#aabbcc40" "$(alpha_of "#abc" 0.25)"
}

# The mod loader rejects an import from another mod folder, so each mod keeps
# a copy.
function test_the_recent_picker_keeps_the_same_alpha_rule() {
  assert_same "" "$(diff "$ROOT/herdr-app/mods/recent-picker/alpha.js" "$ALPHA" 2>&1)"
}

# Prints the color $1 at the share $2 of its strength.
alpha_of() {
  ALPHA="$ALPHA" mise x node@latest -- node --input-type=module -e '
    const { alpha } = await import(process.env.ALPHA);
    console.log(alpha(process.argv[1], Number(process.argv[2])));
  ' "$1" "$2" 2>&1
}
