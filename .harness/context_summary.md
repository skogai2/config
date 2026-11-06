# Context Summary

Persistent record of architectural decisions, discovered patterns, gotchas, and active context.
This file is referenced in CLAUDE.md and loaded every session.

## Active Context
- Done 2026-11-06: F001-F007. `bin/health` covers all 7 groups (16 checks); timer units in
  `machine/units/` (not installed); `bin/check-coverage` + `mise/coverage.md`
- Next up: skogix's calls on the 4 live health failures and installing the timer; then
  work the 66 undecided `~/.config` entries into mise/coverage.md (PROJECT.md section 2)

## Cross-Cutting Concerns
- Stack: Markdown docs, plus bash checks in `bin/` and `tests/`
- Architecture: this repo is the root router for skogai config. Pages are
  grouped by concern (`secrets/`, `shell/`, `containers/`, `desktop/`,
  `agents/`, `mise/`), each group has a `SKOGAI.md` router. The dotfiles
  themselves live in `~/.config` and are versioned by mise history, not here.
- Key constraints:
  - mise's own commands on the dotfile history, never raw git on its store
  - read-only commands run freely; anything writing to the machine is confirmed
  - never read secret values into a conversation
  - one command per Bash call

## Domain: config knowledge

### Decisions
- Knowledge lives in this repo; `~/.config/<app>/SKOGAI.md` only routes back (2026-11-01)
- `mise/` stays one group until it's split into modules (2026-11-01)
- `full_test` = `tests/*.test.sh` + `bin/check-routes`: a route is a "- " line inside a
  `<routes>` block; prose mentions of files are not routes (2026-11-02)
- Push over HTTPS via `gh` (account Skogix); there's no SSH key for github.com (2026-11-02)
- Health checks: one executable `<group>/health` per concern, printing `ok|FAIL <check>[: detail]`
  lines; `bin/health` runs them all plus check-routes. A new concern joins by adding one file.
  On demand only for now; timer later (skogix, 2026-11-06)
- Concern health scripts source `bin/health-lib.sh` (report/need/tilde/join/stock_check);
  test files source `tests/lib.sh` (run/expect/refute/stub/toolbox) (2026-11-06)
- `bin/check-coverage` stays out of bin/health until section 2 is worked through; only
  skogix's decisions go in mise/coverage.md (2026-11-06)
- Commits carry no Co-Authored-By (decision 2026-10-30, `.skogai/handover.md`)

### Patterns
- every `mise dot` write goes through the lead, one at a time; agents return a verdict
  plus the exact command (handover 2026-10-30)

### Gotchas
- Omarchy refreshes replace personal configs silently (tmux.conf on 2026-11-02 07:39, leaving
  `tmux.conf.bak.<epoch>`); `stock_check` catches a byte-identical copy (2026-11-06)
- the tool shell is zsh: `${PIPESTATUS[0]}` and `command -v -a` don't work in Bash calls (2026-11-06)
- `sed -E "s|a\|b||"`: with `|` as delimiter, `\|` is ambiguous; use `#` (2026-11-06)
- `mise doctor` exits 1 when it has problems, and its output includes env/settings: parse only the
  `N problem(s) found:` block, never print the rest (2026-11-06)
- a timed-out health script's children (e.g. `sleep`) keep a pipe open: capture concern output to
  a temp file, not `$(...)`, or `timeout` returns but the runner still waits (2026-11-06)
- the harness was used and removed in `~/skogai` (memory `probe-method-lessons`,
  2026-10-31): a spec gate proves a spec is testable, not that it's worth building.
  Ask "what changes in the world if this works" first

- `mise dot status` exits 0 while publishing fails; the error is a `✗ last error:` line under
  Repository. `dot-sync` in mise/health catches it (2026-11-06)
- mise's name-based credential filter misses keys inside ordinary config files (Moonlight.conf
  `key=`); its publish check catches them, but only after they're in local history. Before
  tracking a new app dir, grep key names (`cut -d= -f1`) for key/cert/token (2026-11-06)

- Removing plaintext from mise history without `history purge` (mise < 2026.11): stop
  `dev.mise.mise-history.service`, move `main` back to the last published commit
  (`refs/remotes/origin/setup`), `mise dot save`, then `reflog expire` + `gc --prune=now`.
  The publish check stops at the first hit: scan every new file before syncing, or it takes
  one reset per secret (three on 2026-11-06). Each reset needs skogix's approval, and
  `--allow-plaintext-history` is skogix's to run, never an agent's (2026-11-06)

## Meta-Patterns
<!-- Coordination insights that apply across features — NOT domain-specific.
     Populated by the retrospective step at session end.
     These transfer to new projects: harness-init can import them as starting context. -->
- Spec-verification asks about exact output formats; capture real command output (verbatim
  samples) before writing a spec that parses a tool, and round 1 shrinks a lot (watching, 2 sessions)
- Batch spec verification for sibling features in one agent call: one round instead of six (watching)

## Meta-Session 2026-11-06
- Scope: planned F001 coverage check; skogix redirected to a health checkup. Delivered F001 as
  specced, no scope expansions, 0 correction cycles.
- Discovered: the live machine fails `mise doctor` (claude-code 2.1.318 declared, not installed).
- Spec gate: 2 ASK rounds (15 + 6 questions), all answerable from real command output; lead
  answered inline rather than routing to skogix. Worth it: it caught bin/health discovering itself.

## Meta-Session 2026-11-06 (2)
- Scope: skogix asked to "add the rest"; lead derived F002-F007 from the concern pages and
  PROJECT.md, specced from live samples, built single-session. No scope expansions.
- Spec gate: one batched ASK round for six features (26 questions, mostly output details and a
  missing QA-binding line); answered inline. Lesson: put `QA binding:` in every spec up front.
- Discovered: 4 live failures (tmux reset, opencode integration, fnox.toml owner, a secret-named
  atuin var), each one a check meant to catch it.
- Model calibration: 0 correction cycles; one self-inflicted miss (a sed edit that silently didn't
  match the toolbox line) cost a red cycle. Verify a sed edit with grep in the same call.
