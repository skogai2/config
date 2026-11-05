#!/usr/bin/env bash
# Tests for bin/check-routes against throwaway fixture repos.
set -u

checker="$(cd "$(dirname "$0")/.." && pwd)/bin/check-routes"
failures=0

fixture() {
  local dir
  dir=$(mktemp -d)
  mkdir -p "$dir/group"
  printf 'page\n' > "$dir/group/page.md"
  printf '%s\n' "$1" > "$dir/SKOGAI.md"
  printf '%s\n' "$2" > "$dir/group/SKOGAI.md"
  echo "$dir"
}

expect() {
  local name=$1 want=$2 dir=$3 got=0
  "$checker" "$dir" >/dev/null || got=$?
  if [[ $got -eq $want ]]; then
    echo "ok   $name"
  else
    echo "FAIL $name: exit $got, want $want"
    failures=1
  fi
  rm -rf "$dir"
}

routes() { printf '<routes>\n\n%s\n\n</routes>' "$1"; }

expect "resolving routes pass" 0 "$(fixture \
  "$(routes '- group/SKOGAI.md - a group')" \
  "$(routes '- @page.md - a page')")"

expect "missing route fails" 1 "$(fixture \
  "$(routes '- group/SKOGAI.md - a group')" \
  "$(routes '- gone.md - not there')")"

expect "route resolves from its router's dir, not the root" 1 "$(fixture \
  "$(routes '- page.md - only exists under group/')" \
  "$(routes '- page.md - fine here')")"

expect "TODO placeholders are skipped" 0 "$(fixture \
  "$(routes '- [@TODO:nvim] - later')" \
  "$(routes '- ../SKOGAI.md - up')")"

expect "lines outside <routes> are ignored" 0 "$(fixture \
  "$(printf -- '- missing.md - prose list\n%s' "$(routes '- group/SKOGAI.md - ok')")" \
  "$(routes '- page.md - ok')")"

exit $failures
