<routes>

- @SKOGAI.md 
- @.skogai/handover.md - where the last session stopped and what's open (read at session start)

</routes>

## where things are saved

| what | where |
|---|---|
| knowledge about a tool: decisions, gotchas, state | the concern page for it (`<group>/<tool>.md`) |
| project plan and status | `PROJECT.md` |
| the short to-do list | `.skogai/TODO.md` |
| session handoff: where we stopped, what's open | `.skogai/handover.md` (overwrite it; git keeps the old ones) |
| how to work in this repo | this file |
| runtime output (journal, logs, scratch) | `.skogai/{journal.md,logs/,tmp/}`, gitignored |

A gotcha goes on the page of the tool it's about, not in a session
note. If it's about working in this repo, it goes below.

## working here

- Stack: Markdown pages plus bash checks in `bin/` and `tests/`.
- Tests: `bin/test smoke_test | focused_test <file> | full_test`.
  `full_test` is every `tests/*.test.sh` plus `bin/check-routes`; a route
  is a `- ` line inside a `<routes>` block, prose mentions aren't routes.
- Health: one executable `<group>/health` per concern, printing
  `ok|FAIL <check>[: detail]` lines; `bin/health` runs them all plus
  check-routes. A new concern joins by adding one file. Health scripts
  source `bin/health-lib.sh` (report/need/tilde/join/stock_check), tests
  source `tests/lib.sh` (run/expect/refute/stub/toolbox). Run `bin/health`
  at session start.
- Before writing a check that parses a tool's output, capture real output
  first, including edge cases of the format (single-digit fields, empty
  values), not just the one sample on screen.
- Git: Emil Skogsund <emil@skogsund.se>, pushing over HTTPS via `gh`
  (account Skogix); there's no SSH key for github.com. Commits carry no
  Co-Authored-By (skogix, 2026-10-30).
- One command per Bash call.

### tool-shell gotchas

- The Bash tool runs zsh: `${PIPESTATUS[0]}` and `command -v -a` don't
  work. Use a separate `; echo $?`.
- `sed -E "s|a\|b||"` is ambiguous with `|` as delimiter; use `#`. A sed
  edit that matches nothing exits 0: grep for the result in the same call.
- A timed-out script's children (e.g. `sleep`) keep a pipe open: capture
  output to a temp file, not `$(...)`, or the caller still waits.
- `jq paths(scalars)` skips nulls: scan raw files for key names instead.
