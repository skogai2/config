# Context Summary

Persistent record of architectural decisions, discovered patterns, gotchas, and active context.
This file is referenced in CLAUDE.md and loaded every session.

## Active Context
- Currently working on: project initialization (2026-11-02)
- Next up: F001 coverage check, the gate for the coverage features

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
- Commits carry no Co-Authored-By (decision 2026-10-30, `.skogai/handover.md`)

### Patterns
- every `mise dot` write goes through the lead, one at a time; agents return a verdict
  plus the exact command (handover 2026-10-30)

### Gotchas
- the harness was used and removed in `~/skogai` (memory `probe-method-lessons`,
  2026-10-31): a spec gate proves a spec is testable, not that it's worth building.
  Ask "what changes in the world if this works" first

## Meta-Patterns
<!-- Coordination insights that apply across features — NOT domain-specific.
     Populated by the retrospective step at session end.
     These transfer to new projects: harness-init can import them as starting context. -->
- (none yet — first retrospective will populate this)
