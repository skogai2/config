#!/usr/bin/env bash
# Tests for bin/check-coverage: every ~/.config entry tracked or decided.
set -u

# shellcheck source=tests/lib.sh
source "$(dirname "$0")/lib.sh"

# fixture: a temp HOME whose .config holds tracked, decided and undecided
# entries, a stub mise answering `dot paths --json`, and a decisions file.
fixture() {
  local h=$work/cov
  rm -rf "$h"
  mkdir -p "$h/home/.config"/{fish,herdr,Bitwarden,go,zeta,Alpha,both} "$h/bin"
  touch "$h/home/.config"/{starship.toml,mimeapps.list.bak,x.conf.bak.123,.hidden}
  ln -s "$h/home/.config/zeta" "$h/home/.config/link-to-dir"
  ln -s "$h/nowhere" "$h/home/.config/dangling"
  cat >"$h/paths.json" <<EOF
{"entries": [
  {"path": "~/.config/fish", "mode": "track"},
  {"path": "~/.config/herdr/config.toml", "mode": "track"},
  {"path": "$h/home/.config/starship.toml", "mode": "track"},
  {"path": "~/.config/both/", "mode": "track"},
  {"path": "~/.config/zeta", "mode": "link"}
], "exclude": ["~/.config/**/*.bak"]}
EOF
  cat >"$h/coverage.md" <<'EOF'
# coverage

| name | decision | why |
|---|---|---|
| Bitwarden | owner | Electron app profile |
| go | exclude | build cache |
| both | exclude | conflicts with tracking |
| gone | owner | not on this machine |
| weird | maybe | not a decision |
EOF
  # shellcheck disable=SC2016 # the body is a script; it expands when the stub runs
  stub "$h/bin" mise '
[[ "$*" == "dot paths --json" ]] || exit 99
pwd >"$STUB/cwd"
cat "$STUB/paths.json"
exit "${STUB_RC:-0}"'
  cov=$h
}

coverage() {
  run env HOME="$cov/home" STUB="$cov" COVERAGE_FILE="$cov/coverage.md" \
    PATH="$cov/bin:$(toolbox)" "$@" "$repo/bin/check-coverage"
}

test_report() {
  fixture
  coverage
  expect "coverage: report and counts" 1 \
    "CONFLICT both: tracked and exclude" \
    "UNDECIDED Alpha" "UNDECIDED link-to-dir" "UNDECIDED zeta" \
    "3 tracked, 2 decided, 3 undecided, 1 conflicts"
  local order
  order=$(grep -E '^(CONFLICT|UNDECIDED|[0-9])' <<<"$out" | cut -d' ' -f1-2 | tr '\n' '|')
  if [[ $order == "CONFLICT both:|UNDECIDED Alpha|UNDECIDED link-to-dir|UNDECIDED zeta|3 tracked,|" ]]
  then pass "coverage: conflicts, then sorted undecided, then summary"
  else fail "coverage: order was $order"; fi
  refute "coverage: hidden, .bak and dangling skipped" "hidden"
  refute "coverage: .bak skipped" ".bak"
  refute "coverage: dangling link skipped" "dangling"
  if [[ $(cat "$cov/cwd") == "$cov/home" ]]; then pass "coverage: mise runs from \$HOME"
  else fail "coverage: mise ran from $(cat "$cov/cwd")"; fi
}

test_clean() {
  fixture
  rm -r "$cov/home/.config"/{zeta,Alpha,both,link-to-dir}
  coverage
  expect "coverage: all decided exits 0" 0 "3 tracked, 2 decided, 0 undecided, 0 conflicts"
}

test_errors() {
  fixture
  coverage STUB_RC=4
  expect "coverage: mise failure exits 2" 2 "check-coverage: mise dot paths --json exited 4"
  run env HOME="$cov/home" COVERAGE_FILE="$cov/coverage.md" PATH="$(toolbox)" \
    "$repo/bin/check-coverage"
  expect "coverage: mise missing exits 2" 2 "check-coverage: mise not found"
}

test_report
test_clean
test_errors

exit $failures
