---
permalink: config/mise/coverage
type: reference
---

# coverage: every `~/.config` entry decided

`../bin/check-coverage` lists every directory and file directly in
`~/.config` (skipping dot names and `*.bak` / `*.bak.*`) and sorts each
into one of three outcomes:

- **tracked**: a `mode = "track"` entry in `mise dot paths` covers it
  (a file entry like `~/.config/herdr/config.toml` covers `herdr`).
- **decided**: a row in the table below says `exclude` (never tracked,
  on purpose) or `owner` (the app owns it: profiles, caches, logins).
- **undecided**: neither. These are the to-do list, PROJECT.md section 2.

A name that is both tracked and decided is a `CONFLICT`: fix one side.
It's a standalone check, not part of `bin/health`, until section 2 is
worked through. Only skogix's decisions go in the table.

## decisions

| name | decision | why |
|---|---|---|
| vivaldi | owner | browser profile (PROJECT.md section 2, never track) |
| opera | owner | browser profile (PROJECT.md section 2) |
| microsoft-edge | owner | browser profile ("edge" in PROJECT.md section 2) |
| Bitwarden | owner | Electron app (PROJECT.md section 2) |
| Claude | owner | Electron app (PROJECT.md section 2) |
| Signal | owner | Electron app (PROJECT.md section 2) |
| Slack | owner | Electron app (PROJECT.md section 2) |
| discordcanary | owner | Electron app (PROJECT.md section 2) |
| go | owner | cache (PROJECT.md section 2) |
| yay | owner | cache (PROJECT.md section 2) |
| procps | owner | PROJECT.md section 2, never track |
| mpv | owner | empty (PROJECT.md section 2) |
| uv | exclude | installer receipt only (untracked 2026-10-27, PROJECT.md section 1) |
| tailscale | exclude | generated ssh_known_hosts for tailnet hosts (untracked 2026-10-27) |
| menus | exclude | generated .menu files (untracked 2026-10-27) |
| ibus | exclude | runtime bus address files only (untracked 2026-10-27) |
| fcitx | exclude | runtime dbus address file only (untracked 2026-10-27) |
| dconf | exclude | binary settings db written by apps; a `dconf dump` export if settings ever matter |
