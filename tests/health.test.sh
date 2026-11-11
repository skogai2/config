#!/usr/bin/env bash
# Tests for bin/health and the concern health scripts (containers, mise,
# machine). Everything runs against stub scripts and stub commands; nothing
# reads live machine state.
set -u

# shellcheck source=tests/lib.sh
source "$(dirname "$0")/lib.sh"

# shellcheck disable=SC2329 # invoked indirectly, as `run health <root>`
health() { SKOGAI_HEALTH_ROOT=$1 "$repo/bin/health"; }

test_runner() {
  local r
  r=$(newroot)
  concern "$r" b 'echo "ok x"'
  concern "$r" a 'echo "ok y: some detail"'
  concern "$r" zed 'echo "ok last"'
  concern "$r" bin 'echo "FAIL never: bin/ is skipped"; exit 1'
  mkdir -p "$r/c" "$r/d/sub"
  printf 'echo "ok not-executable"\n' >"$r/c/health"
  concern "$r/d" sub 'echo "ok too-deep"'
  run health "$r"
  expect "runner: discovers, prefixes and passes" 0 \
    "a ok y: some detail" "b ok x" "skogai ok routes" "zed ok last" "all 4 checks ok"
  [[ $(grep -vx 'all 4 checks ok' <<<"$out" | cut -d' ' -f1 | tr '\n' ' ') == "a b skogai zed " ]]
  verdict "runner: groups in alphabetical order" $?
  refute "runner: skips bin/" "never"
  refute "runner: skips non-executable" "not-executable"
  refute "runner: skips deeper health files" "too-deep"
}

test_routes() {
  local r
  r=$(newroot)
  printf '<routes>\n\n- gone.md - x\n- also-gone.md - y\n\n</routes>\n' >"$r/SKOGAI.md"
  run health "$r"
  expect "routes: missing routes fail against the given root" 1 \
    "skogai FAIL routes: 2 missing" "1 of 1 checks failed"
}

test_script_failures() {
  local r
  r=$(newroot)
  concern "$r" crash 'echo "junk line"; echo "noise" >&2; exit 3'
  concern "$r" liar 'echo "ok fine"; echo "FAIL broken: oh no"; exit 0'
  concern "$r" quiet 'exit 0'
  run health "$r"
  expect "script failures: exit, liar, zero checks" 1 \
    "crash FAIL health: exited 3" "liar ok fine" "liar FAIL broken: oh no" \
    "quiet FAIL health: no checks reported" "skogai ok routes" "3 of 5 checks failed"
  refute "script failures: unmatched lines ignored" "junk line"
  refute "script failures: stderr suppressed" "noise"
}

test_timeout() {
  local r
  r=$(newroot)
  concern "$r" slow 'echo "ok early"; sleep 5; echo "ok late"'
  SECONDS=0
  rc=0
  out=$(HEALTH_TIMEOUT=1 SKOGAI_HEALTH_ROOT=$r "$repo/bin/health" 2>&1) || rc=$?
  expect "timeout: partial output kept, timeout counted" 1 \
    "slow ok early" "slow FAIL health: timed out after 1s" "1 of 3 checks failed"
  refute "timeout: killed before finishing" "late"
  ((SECONDS < 4))
  verdict "timeout: does not wait for the script (${SECONDS}s)" $?
}

test_bad_root() {
  run health "$work/does-not-exist"
  expect "bad root: exits 2 with a message" 2 \
    "health: root $work/does-not-exist is not a directory"
}

test_containers() {
  local s=$work/qh
  stub "$s" ok 'echo "generator: ok, 14 units"; echo; echo "UNIT SOURCE"'
  stub "$s" bad 'echo "generator: rc=1, 3 units"; exit 2'
  run env QUADLET_HEALTH="$s/ok" "$repo/containers/health"
  expect "containers: ok with unit count" 0 "ok quadlet-health: 14 units"
  run env QUADLET_HEALTH="$s/bad" "$repo/containers/health"
  expect "containers: nonzero exit fails" 1 "FAIL quadlet-health: exit 2, see quadlet-health"
  run env QUADLET_HEALTH="$s/nope" "$repo/containers/health"
  expect "containers: missing script" 1 "FAIL quadlet-health: $s/nope not found"
}

# A stub mise answering doctor / bootstrap plan / dot status from files in $STUB.
mise_stub() {
  # shellcheck disable=SC2016 # the body is a script; it expands when the stub runs
  stub "$1" mise '
case "$1 ${2:-}" in
  "doctor "*) sub=doctor ;;
  "bootstrap plan") sub=plan ;;
  "dot status") sub=dot ;;
  "dot paths") sub=paths ;;
  "bootstrap status") sub=bstatus ;;
  "dot files")
    # tracked unless its name contains "excluded"
    f=${@: -1}; case $f in *excluded*) st=excluded ;; *) st=tracked ;; esac
    echo "[{\"path\": \"$f\", \"status\": \"$st\"}]"; exit 0 ;;
  *) exit 99 ;;
esac
[[ $sub == paths && ! -e $STUB/paths.out ]] && echo "{\"entries\": []}"
[[ $sub == bstatus && ! -e $STUB/bstatus.out ]] && echo "{\"dotfiles\": {\"files\": []}}"
pwd >"$STUB/$sub.cwd"
cat "$STUB/$sub.out" 2>/dev/null
exit "$(cat "$STUB/$sub.rc" 2>/dev/null || echo 0)"'
}

# mise_case <doctor-out> <doctor-rc> <plan-out> <plan-rc> <dot-out> <dot-rc>
mise_case() {
  local d=$work/mise-$RANDOM
  mise_stub "$d/bin"
  mkdir -p "$d/home"
  printf '%b' "$1" >"$d/doctor.out"; echo "$2" >"$d/doctor.rc"
  printf '%b' "$3" >"$d/plan.out"; echo "$4" >"$d/plan.rc"
  printf '%b' "$5" >"$d/dot.out"; echo "$6" >"$d/dot.rc"
  printf '| name | decision | why |\n|---|---|---|\n' >"$d/coverage.md"
  mise_run "$d"
}

# mise_run <stub-dir>: run mise/health against the stub and its decisions file.
mise_run() {
  run env STUB="$1" HOME="$1/home" COVERAGE_FILE="$1/coverage.md" \
    PATH="$1/bin:$(toolbox)" "$repo/mise/health"
  mise_dir=$1
}

plan_ok='Plan: 0 create, 0 update, 13 unchanged, 0 remove, 0 unknown\n'
dot_ok='Repository\n  x\n\nAutomatic capture \xe2\x9c\x93\n  running (edits are saved).\n'
warn='1 warning found:\n\n1. new mise version available\n\n'

test_mise() {
  mise_case "settings\n\n$warn" 0 "x\n$plan_ok" 0 "$dot_ok" 0
  expect "mise: all ok, warnings are not failures" 0 \
    "ok doctor" "ok bootstrap-plan: Plan: 0 create, 0 update, 13 unchanged, 0 remove, 0 unknown" \
    "ok dot-capture" "ok dot-sync" "ok dot-modes" "ok dot-links" "ok coverage: 0 tracked, 0 decided, 0 undecided, 0 conflicts"
  local cwds
  cwds=$(cat "$mise_dir/doctor.cwd" "$mise_dir/plan.cwd" "$mise_dir/dot.cwd" | sort -u)
  if [[ $cwds == "$mise_dir/home" ]]; then pass "mise: runs from \$HOME"; else
    fail "mise: runs from \$HOME"; fi

  mise_case "${warn}2 problems found:\n\n1. tool a is not installed\n2. tool b is broken\n" 1 \
    "Plan: 1 create, 0 update, 12 unchanged, 0 remove, 0 unknown\n" 0 \
    "Automatic capture \xe2\x9c\x93\n\n  stopped\n" 0
  expect "mise: problems, plan drift, capture stopped" 1 \
    "FAIL doctor: tool a is not installed; tool b is broken" \
    "FAIL bootstrap-plan: Plan: 1 create, 0 update, 12 unchanged, 0 remove, 0 unknown" \
    "FAIL dot-capture: automatic capture not running"

  mise_case "settings\n" 0 "$plan_ok" 0 \
    "Repository\n  Branch: main\n  \xe2\x9c\x97 last error: cannot publish: line 2 of a.conf looks like a secret. Rotate it (failing since 17:27)\n\nAutomatic capture \xe2\x9c\x93\n  running (edits are saved).\n" 0
  expect "mise: sync error under Repository" 1 \
    "ok dot-capture" \
    "FAIL dot-sync: last error: cannot publish: line 2 of a.conf looks like a secret"

  mise_case "nothing\n" 1 "no summary\n" 3 "$dot_ok" 4
  expect "mise: unexpected exits" 1 \
    "FAIL doctor: mise doctor exited 1" "FAIL bootstrap-plan: no Plan: line (exit 3)" \
    "FAIL dot-capture: mise dot status exited 4" "FAIL dot-sync: mise dot status exited 4"

  mise_case "settings\n" 0 "$plan_ok" 0 "$dot_ok" 0
  printf '%s\n' '{"dotfiles": {"files": [{"target": "~/.config/a", "mode": "track"},' \
    '{"target": "~/.config/b/c.toml", "mode": "symlink"}, {"target": "~/.x", "mode": "copy"}]}}' \
    >"$mise_dir/bstatus.out"
  mise_run "$mise_dir"
  expect "mise: a deploy entry fails dot-modes" 1 \
    "FAIL dot-modes: not tracked in place: ~/.config/b/c.toml (symlink), ~/.x (copy)"

  local h=$mise_dir/home
  mkdir -p "$h/.config/app"
  ln -s "$h/nowhere" "$h/.config/app/gone"
  ln -s "$h/nowhere" "$h/.config/app/excluded-lock"
  ln -s "$h/.config/app" "$h/.config/app/fine"
  printf '{"entries": [{"path": "~/.config/app", "mode": "track"}]}\n' >"$mise_dir/paths.out"
  rm "$mise_dir/bstatus.out"
  mise_run "$mise_dir"
  expect "mise: a tracked dangling link fails dot-links" 1 \
    "FAIL dot-links: tracked links to nothing: ~/.config/app/gone" "ok dot-modes"
  rm "$mise_dir/paths.out"

  echo "not json" >"$mise_dir/bstatus.out"; echo 2 >"$mise_dir/bstatus.rc"
  mise_run "$mise_dir"
  expect "mise: bootstrap status error" 1 \
    "FAIL dot-modes: no JSON from mise bootstrap status (exit 2)"

  run env HOME="$work" PATH="$(toolbox)" "$repo/mise/health"
  expect "mise: mise not on PATH" 1 \
    "FAIL doctor: mise not found" "FAIL bootstrap-plan: mise not found" \
    "FAIL dot-capture: mise not found" "FAIL dot-sync: mise not found" \
    "FAIL dot-modes: mise not found" "FAIL dot-links: mise not found" \
    "FAIL coverage: mise not found"
}

# coverage: bin/check-coverage as a mise check, against a stub HOME/.config.
test_coverage() {
  local d
  mise_case "settings\n" 0 "$plan_ok" 0 "$dot_ok" 0
  d=$mise_dir
  mkdir -p "$d/home/.config"/{tracked,both,"Some App",zeta}
  printf '{"entries": [{"path": "~/.config/tracked", "mode": "track"},\n' >"$d/paths.out"
  printf ' {"path": "~/.config/both", "mode": "track"}]}\n' >>"$d/paths.out"
  printf '| both | owner | x |\n' >>"$d/coverage.md"
  mise_run "$d"
  expect "coverage: undecided and conflicts fail, named" 1 \
    "FAIL coverage: 2 undecided, 1 conflicts: both: tracked and owner, Some App, zeta" "ok dot-sync"

  printf '| Some App | owner | x |\n| zeta | exclude | y |\n' >>"$d/coverage.md"
  printf '{"entries": [{"path": "~/.config/tracked", "mode": "track"},\n' >"$d/paths.out"
  printf ' {"path": "~/.config/both", "mode": "track"}]}\n' >>"$d/paths.out"
  sed -i '/^| both /d' "$d/coverage.md"
  mise_run "$d"
  expect "coverage: all decided is ok" 0 \
    "ok coverage: 2 tracked, 2 decided, 0 undecided, 0 conflicts"

  echo 3 >"$d/paths.rc"
  mise_run "$d"
  expect "coverage: check-coverage error" 1 "FAIL coverage: check-coverage exited 2"
}

test_machine() {
  local d=$work/sysd
  stub "$d/none" systemctl 'exit 0'
  stub "$d/two" systemctl '
echo "foo.service loaded failed failed Foo thing"
echo "bar.timer   loaded failed failed Bar"'
  stub "$d/err" systemctl 'echo "Failed to connect to bus"; exit 1'
  run env PATH="$d/none:$(toolbox)" "$repo/machine/health"
  expect "machine: no failed units" 0 "ok failed-units"
  run env PATH="$d/two:$(toolbox)" "$repo/machine/health"
  expect "machine: failed units listed" 1 "FAIL failed-units: foo.service, bar.timer"
  run env PATH="$d/err:$(toolbox)" "$repo/machine/health"
  expect "machine: systemctl error" 1 "FAIL failed-units: systemctl exited 1"
  run env PATH="$(toolbox)" "$repo/machine/health"
  expect "machine: systemctl not on PATH" 1 "FAIL failed-units: systemctl not found"
}

test_runner
test_routes
test_script_failures
test_timeout
test_bad_root
test_containers
test_mise
test_coverage
test_machine

exit $failures
