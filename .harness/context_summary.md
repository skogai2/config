# Context Summary

Persistent record of architectural decisions, discovered patterns, gotchas, and active context.
This file is referenced in CLAUDE.md and loaded every session.

## Active Context
- Done: F001 system health checkup, `bin/health` (2026-11-06)
- Next up: health checks for secrets/, shell/, desktop/, agents/; a timer + notify for
  bin/health (quadlet-health pattern); the `~/.config/<app>/` coverage check (not yet a feature)

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
- Commits carry no Co-Authored-By (decision 2026-10-30, `.skogai/handover.md`)

### Patterns
- every `mise dot` write goes through the lead, one at a time; agents return a verdict
  plus the exact command (handover 2026-10-30)

### Gotchas
- `mise doctor` exits 1 when it has problems, and its output includes env/settings: parse only the
  `N problem(s) found:` block, never print the rest (2026-11-06)
- a timed-out health script's children (e.g. `sleep`) keep a pipe open: capture concern output to
  a temp file, not `$(...)`, or `timeout` returns but the runner still waits (2026-11-06)
- the harness was used and removed in `~/skogai` (memory `probe-method-lessons`,
  2026-10-31): a spec gate proves a spec is testable, not that it's worth building.
  Ask "what changes in the world if this works" first

## Meta-Patterns
<!-- Coordination insights that apply across features — NOT domain-specific.
     Populated by the retrospective step at session end.
     These transfer to new projects: harness-init can import them as starting context. -->
- Spec-verification asks about exact output formats; capture real command output (verbatim
  samples) before writing a spec that parses a tool, and round 1 shrinks a lot (watching)

## Meta-Session 2026-11-06
- Scope: planned F001 coverage check; skogix redirected to a health checkup. Delivered F001 as
  specced, no scope expansions, 0 correction cycles.
- Discovered: the live machine fails `mise doctor` (claude-code 2.1.318 declared, not installed).
- Spec gate: 2 ASK rounds (15 + 6 questions), all answerable from real command output; lead
  answered inline rather than routing to skogix. Worth it: it caught bin/health discovering itself.
