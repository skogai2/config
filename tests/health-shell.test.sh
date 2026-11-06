#!/usr/bin/env bash
# Tests for shell/health: atuin sync freshness and secret-looking var names.
set -u

# shellcheck source=tests/lib.sh
source "$(dirname "$0")/lib.sh"

# atuin_case <status-out> <status-rc> <vars-out> <vars-rc>: run shell/health
# with a stub atuin answering `status` and `dotfiles var list`.
atuin_case() {
  local d
  d=$(mktemp -d "$work/atuin.XXXX")
  printf '%s\n' "$1" >"$d/status.out"; echo "$2" >"$d/status.rc"
  printf '%s\n' "$3" >"$d/vars.out"; echo "$4" >"$d/vars.rc"
  # shellcheck disable=SC2016 # the body is a script; it expands when the stub runs
  stub "$d/bin" atuin '
case "$*" in
  status) s=status ;;
  "dotfiles var list") s=vars ;;
  *) exit 99 ;;
esac
cat "$STUB/$s.out"
exit "$(cat "$STUB/$s.rc")"'
  run env STUB="$d" PATH="$d/bin:$(toolbox)" "$repo/shell/health"
}

# synced <hours-ago>: a `Last sync:` line in atuin's format, in local time.
synced() {
  date -d "-$1 hours" '+Last sync: %Y-%m-%d %H:%M:%S.347674749 %:z:00'
}

vars='export EDITOR=nvim
export TERMIX_TAILSCALE_API_KEY=hunter2-value
export KEYMAP=dvorak
export MONKEY=banana
export db_password=pw-value
export PAGER=less'

test_sync() {
  atuin_case "$(printf 'Atuin v18\n\n[Local]\n%s\n' "$(synced 3)")" 0 "export EDITOR=nvim" 0
  expect "atuin: recent sync ok" 0 "ok atuin-sync: 3h ago" "ok atuin-vars: 1 vars"
  atuin_case "$(synced 30)" 0 "export EDITOR=nvim" 0
  expect "atuin: stale sync fails" 1 "FAIL atuin-sync: last sync 30h ago"
  atuin_case "$(synced 24)" 0 "export EDITOR=nvim" 0
  expect "atuin: exactly at the limit fails" 1 "FAIL atuin-sync: last sync 24h ago"
  atuin_case "Last sync: never" 0 "" 0
  expect "atuin: unparseable sync line" 1 "FAIL atuin-sync: no Last sync: line" \
    "ok atuin-vars: 0 vars"
  atuin_case "$(synced 1)" 2 "" 0
  expect "atuin: status exit wins" 1 "FAIL atuin-sync: atuin status exited 2"
}

test_vars() {
  atuin_case "$(synced 1)" 0 "$vars" 0
  expect "atuin: secret-looking names flagged by part" 1 \
    "FAIL atuin-vars: secret-looking names: TERMIX_TAILSCALE_API_KEY, db_password"
  refute "atuin: values never printed" "hunter2"
  refute "atuin: values never printed (2)" "pw-value"
  refute "atuin: KEYMAP is not a KEY part" "KEYMAP"
  atuin_case "$(synced 1)" 0 "$vars" 1
  expect "atuin: var list exit" 1 "FAIL atuin-vars: atuin dotfiles var list exited 1"
}

test_missing() {
  run env PATH="$(toolbox)" "$repo/shell/health"
  expect "atuin: not on PATH" 1 "FAIL atuin-sync: atuin not found" \
    "FAIL atuin-vars: atuin not found"
}

test_sync
test_vars
test_missing

exit $failures
