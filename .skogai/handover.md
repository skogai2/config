# handover (2026-11-11)

## where we are

- `bin/health`: 17 checks across 7 groups, all ok as of 2026-11-09, run
  hourly by the `skogai-health` timer (`machine/SKOGAI.md`).
- Coverage: 65 tracked, 60 decided, 0 undecided (`mise/coverage.md`).
- 2026-11-11: the vv-harness was retired (plugin no longer installed;
  F001-F007 all done). Its knowledge moved to the concern pages and
  `AGENTS.md`; `.harness/init.sh` is now `bin/test`; its hooks in
  `.claude/` are gone. `journal.md` is untracked.

## next

- `bin/health` on 2026-11-11: 3 of 17 fail, all new since 11-09 and not
  from the cleanup: `herdr-binary` (`/usr/bin/herdr` ahead of mise's on
  PATH), `failed-units` (`app-bitwarden@autostart`, plus
  `skogai-health` itself failing on the others), `coverage` (`ponytail`
  undecided).
- PROJECT.md §2: config outside `~/.config`, then packages.

## open for skogix

- Which mise/atuin wins: pacman (`/usr/bin`) or the user installs
  (`machine/SKOGAI.md`, two copies).
- atuin MCP still pins `/usr/bin/atuin`; repoint it:
  `claude mcp remove atuin -s user`, then
  `claude mcp add -s user atuin -- ~/.local/share/mise/shims/atuin mcp`.
- History rewrites for the leaked files (`mise/dotfiles.md`, open).
