#!/usr/bin/env bash
# Tests for shell/health: atuin sync freshness.
set -u

# shellcheck source=tests/lib.sh
source "$(dirname "$0")/lib.sh"

# atuin_case <status-out> <status-rc>: run shell/health with a stub atuin
# answering `status`.
atuin_case() {
  local d
  d=$(mktemp -d "$work/atuin.XXXX")
  printf '%s\n' "$1" >"$d/status.out"; echo "$2" >"$d/status.rc"
  # shellcheck disable=SC2016 # the body is a script; it expands when the stub runs
  stub "$d/bin" atuin '
case "$*" in
  status) s=status ;;
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

test_sync() {
  atuin_case "$(printf 'Atuin v18\n\n[Local]\n%s\n' "$(synced 3)")" 0
  expect "atuin: recent sync ok" 0 "ok atuin-sync: 3h ago"
  atuin_case "$(synced 30)" 0
  expect "atuin: stale sync fails" 1 "FAIL atuin-sync: last sync 30h ago"
  atuin_case "$(synced 24)" 0
  expect "atuin: exactly at the limit fails" 1 "FAIL atuin-sync: last sync 24h ago"
  atuin_case "Last sync: never" 0
  expect "atuin: unparseable sync line" 1 "FAIL atuin-sync: no Last sync: line"
  atuin_case "$(synced 1)" 2
  expect "atuin: status exit wins" 1 "FAIL atuin-sync: atuin status exited 2"
}

test_missing() {
  run env PATH="$(toolbox)" "$repo/shell/health"
  expect "atuin: not on PATH" 1 "FAIL atuin-sync: atuin not found"
  refute "atuin: no atuin-vars check" "atuin-vars"
}

test_sync
test_missing

exit $failures
