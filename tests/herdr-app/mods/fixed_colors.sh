#!/bin/bash

# Prints each hex or rgb color literal in a mod file, on one line.
fixed_colors() {
  grep -oE '#[0-9a-fA-F]{3,8}\b|rgba?\(' "$1" | tr '\n' ' '
}
