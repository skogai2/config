#!/usr/bin/env bash
# Tests for desktop/health: tmux and hypr configs not reset to Omarchy stock.
set -u

# shellcheck source=tests/lib.sh
source "$(dirname "$0")/lib.sh"

# place <root> <rel> <content>: write <root>/<rel>.
place() {
  mkdir -p "$(dirname "$1/$2")"
  printf '%s\n' "$3" >"$1/$2"
}

test_desktop() {
  local h stock
  h=$(mktemp -d "$work/home.XXXX")
  stock=$h/stock
  place "$stock" tmux/tmux.conf "stock tmux"
  place "$stock" hypr/bindings.lua "stock hypr"
  place "$h/.config" tmux/tmux.conf "personal tmux"
  place "$h/.config" hypr/bindings.lua "personal hypr"
  run env HOME="$h" OMARCHY_CONFIG="$stock" "$repo/desktop/health"
  expect "desktop: personal configs ok" 0 "ok tmux-config" "ok hypr-bindings"

  place "$h/.config" tmux/tmux.conf "stock tmux"
  rm "$stock/hypr/bindings.lua"
  run env HOME="$h" OMARCHY_CONFIG="$stock" "$repo/desktop/health"
  expect "desktop: reset detected, missing stock tolerated" 1 \
    "FAIL tmux-config: matches Omarchy stock, personal changes lost (see desktop/tmux.md)" \
    "ok hypr-bindings: no Omarchy stock to compare"

  rm "$h/.config/hypr/bindings.lua"
  run env HOME="$h" OMARCHY_CONFIG="$stock" "$repo/desktop/health"
  expect "desktop: missing personal file" 1 "FAIL hypr-bindings: ~/.config/hypr/bindings.lua not found"
}

test_desktop

exit $failures
