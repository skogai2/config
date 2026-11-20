# handover (2026-11-11)

## where we are

- `bin/health`: 19 checks across 7 groups, run hourly by the
  `skogai-health` timer (`machine/SKOGAI.md`). 2026-11-11: one real
  failure left, `failed-units: app-bitwarden@autostart.service`.
  2026-11-20: `skognet-cloudflare.service` and `quadlet-health` fail
  (below); `herdr-binary` passes from every shell now.
- Coverage: every `~/.config` entry decided (`mise/coverage.md`;
  `ponytail` excluded for now, 2026-11-11).
- 2026-11-11: the vv-harness was retired (plugin no longer installed;
  F001-F007 all done). Its knowledge moved to the concern pages and
  `AGENTS.md`; `.harness/init.sh` is now `bin/test`; its hooks in
  `.claude/` are gone. `journal.md` is untracked.

## next

- Test environment (container / test user) for bootstrap and adopt
  runs before touching this machine (PROJECT.md §1, `mise/adopt.md`).
- `app-bitwarden@autostart.service`: running again; its failures were
  crashes (SIGILL at logout, an OOM kill 2026-11-11 06:03), not config.
- Done 2026-11-20: mise over pacman. Pacman's mise, herdr, podlet,
  termix-bin, fzf, lazygit, ripgrep, starship, zoxide removed and
  declared `absent`; what's kept and why in `mise/bootstrap.md`.
- `skognet-cloudflare.service` failed (exit 126, start-limit-hit, since
  2026-11-20 10:01, before the removals); `quadlet-health` fails with it.
  Not looked at yet.
- 2026-11-20: lockfiles decided (`mise/lock.md`): no global one, project
  ones committed. skogai/monorepo#111 (python 3.14) open for merge.
- zsh: activate mise, so the agent tool shell matches fish (PROJECT.md §4).
- PROJECT.md §2: config outside `~/.config`, then packages.

## open for skogix

- History rewrites for the leaked files (`mise/dotfiles.md`, open).
