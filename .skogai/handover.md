# handover (2026-11-11)

## where we are

- `bin/health`: 17 checks across 7 groups, run hourly by the
  `skogai-health` timer (`machine/SKOGAI.md`). 2026-11-11: one real
  failure left, `failed-units: app-bitwarden@autostart.service`. Run
  from an agent's zsh tool shell, `herdr-binary` also fails; that's the
  shell, not the machine (`machine/SKOGAI.md`, two copies).
- Coverage: every `~/.config` entry decided (`mise/coverage.md`;
  `ponytail` excluded for now, 2026-11-11).
- 2026-11-11: the vv-harness was retired (plugin no longer installed;
  F001-F007 all done). Its knowledge moved to the concern pages and
  `AGENTS.md`; `.harness/init.sh` is now `bin/test`; its hooks in
  `.claude/` are gone. `journal.md` is untracked.

## next

- `app-bitwarden@autostart.service` failing: look at why.
- mise wins over pacman for mise and atuin (skogix, 2026-11-11): find
  what still names `/usr/bin/mise` or `/usr/bin/atuin`, then remove the
  pacman packages (confirm first).
- zsh: activate mise, so the agent tool shell matches fish (PROJECT.md §4).
- PROJECT.md §2: config outside `~/.config`, then packages.

## open for skogix

- History rewrites for the leaked files (`mise/dotfiles.md`, open).
