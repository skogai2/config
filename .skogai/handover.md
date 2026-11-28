# handover (2026-11-28)

## where we are

- `bin/health`: 19 checks across 7 groups, run hourly by the
  `skogai-health` timer (`machine/SKOGAI.md`). 2026-11-11: one real
  failure left, `failed-units: app-bitwarden@autostart.service`.
  2026-11-20: `herdr-binary` passes from every shell now.
- Coverage: every `~/.config` entry decided (`mise/coverage.md`;
  `ponytail` excluded for now, 2026-11-11).
- 2026-11-11: the vv-harness was retired (plugin no longer installed;
  F001-F007 all done). Its knowledge moved to the concern pages and
  `AGENTS.md`; `.harness/init.sh` is now `bin/test`; its hooks in
  `.claude/` are gone. `journal.md` is untracked.

## next

- Forgejo (`~/.config/containers/systemd/forgejo/README.md`, 2026-11-28): running, public at `git.skogai.se`, tailnet :8445 web and :2222 ssh, nightly `forgejo dump`. `skogai/podman` leaked publicly ~12:20-17:05 (fixed; check that the cf OAuth login from `1f8da86` is revoked). Open, for skogix: agents out of the Owners team, the two git tokens out of plaintext `~/.config/mise/config.toml` (fnox, then rotate `claude`'s), pin `forgejo-mcp`.
- mise `podman = "latest"` installs only the remote client (6.2.1), which shadows pacman's `/usr/bin/podman` (6.1.4): `podman unshare` fails. Decide which owns `podman` (`mise/bootstrap.md`).
- herdr-app (`agents/herdr-app.md`): mods and layouts inventoried with
  sources 2026-11-20; lazyvim reinstalled by hand 2026-11-21 after
  checkpoint 2327 deleted it (cause not found), now guarded by
  `herdr-app-layout` in `agents/health`. Open: agenttrail panel not back
  in the lazyvim layout; the panel's "Start Map here" button unexplained
  (Map runs via `mise run agenttrail:*` in `~/Work`).
- Test environment (container / test user) for bootstrap and adopt
  runs before touching this machine (PROJECT.md §1, `mise/adopt.md`).
- `app-bitwarden@autostart.service`: running again; its failures were
  crashes (SIGILL at logout, an OOM kill 2026-11-11 06:03), not config.
- Done 2026-11-20: mise over pacman. Pacman's mise, herdr, podlet,
  termix-bin, fzf, lazygit, ripgrep, starship, zoxide removed and
  declared `absent`; what's kept and why in `mise/bootstrap.md`.
- 2026-11-20: the quadlet stack is workstation-only
  (`containers/podman.md`, hosts). Open: on the laptop, stop its units and
  move `~/.config/containers/systemd` aside; on the workstation, add the
  repo to `config.local.toml`, check its network subnets and enable the
  `pg-backup`/`quadlet-health` timers (gotchas there).
- termix (`hosts.yaml`, skogai/podman `066892a`): every host declared,
  claude's share on `skogix-hosts`. Open: after the workstation pulls,
  copy host 4's docker setting to 1633, then delete hand-made hosts 1-4
  (needs `termix login`).
- 2026-11-20: lockfiles decided (`mise/lock.md`): no global one, project
  ones committed. skogai/monorepo#111 (python 3.14) open for merge.
- zsh: activate mise, so the agent tool shell matches fish (PROJECT.md §4).
- PROJECT.md §2: config outside `~/.config`, then packages.

## open for skogix

- History rewrites for the leaked files (`mise/dotfiles.md`, open).
