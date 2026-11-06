#!/usr/bin/env bash
# Tests for agents/health: herdr config, binary and agent integrations.
set -u

# shellcheck source=tests/lib.sh
source "$(dirname "$0")/lib.sh"

statuses='pi: current (v9) (/home/x/.pi/agent/extensions/herdr-agent-state.ts)
omp: not installed (/home/x/.omp/agent/extensions/herdr-omp-agent-state.ts)
claude: current (v11) (/skogai/claude/hooks/herdr-agent-state.sh)
letta (experimental): not installed (/home/x/.letta/hooks/herdr-agent-session.sh)'

# herdr_case <status-out> <status-rc> [env...]: agents/health with a stub herdr
# and a temp HOME whose herdr config differs from stock.
herdr_case() {
  local d
  d=$(mktemp -d "$work/herdr.XXXX")
  printf '%s\n' "$1" >"$d/status.out"
  echo "$2" >"$d/status.rc"
  shift 2
  mkdir -p "$d/home/.config/herdr" "$d/stock/herdr"
  echo personal >"$d/home/.config/herdr/config.toml"
  echo stock >"$d/stock/herdr/config.toml"
  # shellcheck disable=SC2016 # the body is a script; it expands when the stub runs
  stub "$d/home/.local/bin" herdr '
[[ "$*" == "integration status" ]] || exit 99
cat "$STUB/status.out"
exit "$(cat "$STUB/status.rc")"'
  hd=$d
  run env STUB="$d" HOME="$d/home" OMARCHY_CONFIG="$d/stock" \
    PATH="$d/home/.local/bin:$(toolbox)" "$@" "$repo/agents/health"
}

test_ok() {
  herdr_case "$statuses" 0
  expect "herdr: all ok" 0 "ok herdr-config" "ok herdr-binary: ~/.local/bin/herdr" \
    "ok herdr-integrations: 2 current"
}

test_binary() {
  herdr_case "$statuses" 0 HERDR_OMARCHY_BIN=/elsewhere/herdr
  expect "herdr: another binary is fine" 0 "ok herdr-binary: ~/.local/bin/herdr"
  run env STUB="$hd" HOME="$hd/home" OMARCHY_CONFIG="$hd/stock" \
    PATH="$hd/home/.local/bin:$(toolbox)" HERDR_OMARCHY_BIN="$hd/home/.local/bin/herdr" \
    "$repo/agents/health"
  expect "herdr: Omarchy binary first on PATH" 1 "FAIL herdr-binary: $hd/home/.local/bin/herdr \
is Omarchy's herdr; mise's must come first on PATH"
  run env HOME="$hd/home" OMARCHY_CONFIG="$hd/stock" PATH="$(toolbox)" "$repo/agents/health"
  expect "herdr: not on PATH" 1 "ok herdr-config" "FAIL herdr-binary: herdr not found" \
    "FAIL herdr-integrations: herdr not found"
}

test_integrations() {
  herdr_case "$(printf '%s\nHeader line\n\nopencode: needs repair (v13) (/x)\ncodex: outdated' \
    "$statuses")" 0
  expect "herdr: broken integrations listed, headers ignored" 1 \
    "FAIL herdr-integrations: opencode needs repair, codex outdated"
  herdr_case "$statuses" 3
  expect "herdr: status exit" 1 "FAIL herdr-integrations: herdr integration status exited 3"
  echo stock >"$hd/home/.config/herdr/config.toml"
  run env STUB="$hd" HOME="$hd/home" OMARCHY_CONFIG="$hd/stock" \
    PATH="$hd/home/.local/bin:$(toolbox)" "$repo/agents/health"
  expect "herdr: config reset detected" 1 \
    "FAIL herdr-config: matches Omarchy stock, personal changes lost (see agents/herdr.md)"
}

test_ok
test_binary
test_integrations

exit $failures
