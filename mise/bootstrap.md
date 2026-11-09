---
permalink: config/mise/bootstrap
type: reference
---

# mise bootstrap: declarative machine state

Ansible-style desired state in `~/.config/mise/config.toml`
(`[bootstrap.*]`). Each declared entry is converged (`present`/`absent`)
and re-applying is a no-op; anything not declared is left alone. Hooks and
the `bootstrap` task run on every apply, so they must be safe to repeat.

## state (2026-10-31)

`mise bootstrap plan`: 13 unchanged, 0 to do. Declared:

| part | declared |
|---|---|
| accounts | group `skogai` (system); skogix in it (`groups = ["skogai", "wheel"]`, fish) |
| packages | `pacman:` podman, podman-docker, podman-compose, podlet, fish, zsh present; docker-compose, docker-buildx, ufw-docker absent |
| services | `cloudflared` (system, running + enabled); `mise-history` (built-in `history-watch`, user) |
| repos | `~/.config/skogai`, `~/.config/containers/systemd`; `~/.skogai` and `/skogai` commented out |
| shell | `mise_shell_activate = { fish = true }` |
| tools | `[tools]`, run by `mise install` |
| task | `[tasks.bootstrap]`: Omarchy's sshd/Tailscale flows, guarded |

Removed from the config on 2026-10-31 (skogix's call, after the
2026-10-29 rewrite left them as comments): the cloudflared unit/dir/token
files, the `/skogai` dirs and `coord.db`, the agent users claude, dot, amy
and goose, and `user.login_shell`. The machine still has all of them;
they're just not declared. Their notes below say how they were declared,
for when they come back.

## run order

accounts/plugins → files/packages → services/firewall/compose →
repos/dotfiles → shell → systemd units/user → tools → task/final hook.

## commands

- `status` (= `ls`), `plan`: read state / preview changes
- `packages` (`apply`, `status`, `use`, `upgrade`, `prune`, `import`,
  `export`, `brew tap/untap`, `where`)
- `services` (`apply`, `status`, `remove`)
- `linux systemd-units` (`apply`, `status`)
- `firewall`, `compose`, `repos` (`apply`, `status`, `update`, `exec`),
  `files`, `accounts`, `user`, `mise-shell-activate`, `plugins`: each has
  `apply`, `status`
- `secrets status`: see `secrets.md`
- `remote`: bootstrap machines over SSH
- `unapply`: remove what a config environment/module created

Read-only (`status`, `plan`, `--dry-run`) runs freely. `apply` and
anything else that writes is confirmed first.

## parts

### packages: adopt, divergences only (2026-10-14)

Omarchy owns the base package set (Omarchy 4 marks its stock packages
explicit and doesn't keep its install list on disk, so `pacman -Qqe` can't
tell the two apart). `[bootstrap.packages]` declares only packages skogix
actively chooses or rejects.

- Don't declare a package `absent` if an installed package `provides` it.
  `"pacman:docker" = { state = "absent" }` resolved to `podman-docker`,
  and the dry run would have removed it. The `podman-docker` ↔ `docker`
  conflict already keeps Docker out.
- On pacman/AUR, `"latest"` only means installed (no version pins);
  upgrades stay with `pacman -Syu`. `prune`/`import` are Homebrew-only.
  `aur:` is a built-in manager like `pacman:`.
- Open: go through `pacman -Qqe` for the other choices (atuin, herdr,
  bitwarden, tailscale, the AUR packages).

### services (2026-10-14)

System mode only starts/stops/enables/masks units a package or managed
file already provides. User mode (`scope = "user"`) writes a plain
`dev.mise.<name>.service` from `command`, plus the built-ins
`history-watch` and `tool-update`. Units with hardening or an
`EnvironmentFile` belong in `systemd-units`.

- `cloudflared`: declared. Its unit at
  `/etc/systemd/system/cloudflared.service` is hand-placed (no owning
  package); a copy sits in `~/.config/mise/files/cloudflared.service`.
- `mise-history`: declared (unit `dev.mise.mise-history`).
- `sshd`, `tailscaled`: left to Omarchy. Its menu flows also add the UFW
  rule, keys, sshd hardening, `tailscale up`, operator, bar plugin. The
  bootstrap task calls those flows instead.
- `docker.socket`: can't be declared; a missing unit is `unknown` and
  fails the apply.
- `collie` (herdr plugin), `voxtype` (Omarchy's `voxtype setup systemd`),
  `omarchy-tailscale-receive` (enabled 2026-10-14): owned elsewhere.
- Podman: socket enabled, service disabled (`../containers/podman.md` step 9).

### firewall: nothing declared (2026-10-14)

UFW, and every rule and default on it is Omarchy's (deny in, LocalSend
53317, `limit 22/tcp`). mise only removes rules it created (comment
`mise:<name>`); `exclusive = true` runs `ufw reset` and would wipe
Omarchy's rules. It needs root even for `status`. Adopt it for rules
skogix adds, e.g. quadlet ports (rootless Podman publishes through UFW's
input chain).

### compose: not adopted (2026-10-14)

Needs Docker Compose v2 (`--project-directory`, `config --hash`);
podman-compose supports neither. Containers live in the quadlet repo
(`~/.config/containers/systemd`), managed by hand in that repo.

### files (2026-10-14; removed 2026-10-31)

`[bootstrap.files]`/`[bootstrap.directories]` converge content, owner,
group and mode, with sudo only where needed. No `source`/`content` =
permissions only, never created or removed. `notify` reloads a declared
system service after `daemon-reload`, so unit files can live here.

How it was declared, for when it comes back:
- cloudflared: the unit (`source = "./files/cloudflared.service"`, root
  0644, `notify = ["cloudflared"]`), `/etc/cloudflared` (root 0755), the
  token as permissions-only (root 0600).
- `/skogai` and `coordination/` (2775), `bin/` and `tools/` (2755),
  `coord.db` (permissions-only, 0664), all `skogix:skogai`. mise checks
  only declared paths; deeper drift needs `chgrp -R skogai /skogai` and
  `find /skogai -type d -exec chmod g+s {} +` again.

### accounts (2026-10-14; agents removed 2026-10-31)

`[bootstrap.groups]`/`[bootstrap.users]` run first, so files can name
them as owners. Only set fields are managed; `groups` adds memberships
without removing others unless `exclusive_groups = true`. mise counts the
primary group as membership. Apply needs sudo, status doesn't.

- Declared: group `skogai`, user skogix.
- Removed: claude (`/usr/bin/bash` since the 2026-10-14 ssh tests), dot,
  amy, goose (`nologin`); all system users, primary group `skogai`,
  `/home/<name>`, IDs not pinned. They exist on the machine.
- `nologin` blocks login, `ssh`, `su`, `sudo -i`; `sudo -u <agent> <cmd>`,
  systemd `User=` and cron still work.
- **End goal: real login shells for agents** (`ssh
  claude@skogix-workstation`). Touches `shell`, per-agent
  `authorized_keys`, sshd config and Omarchy's `limit 22/tcp` rule. Not
  designed yet.

### repos (2026-10-14; two off 2026-10-31)

`[bootstrap.repos."<path>"]` = `url` (+ optional `ref`). Missing
checkouts are cloned; without `ref`, existing ones stay put; `repos
update` fast-forwards. mise never deletes a checkout or touches local
work: a dirty checkout or a mismatched origin fails apply
(`--skip-dirty` skips instead).

- Declared: `~/.config/skogai`, `~/.config/containers/systemd`.
- Commented out until they're set up again: `~/.skogai` (dot-skogai; not
  a git checkout any more) and `/skogai` (dash-skogai; its origin is
  `skogai2/skogix` now).
- Unverified: whether mise clones submodules.

### shell (2026-10-14)

- `mise_shell_activate`: `fish = true`, so `config.fish` has the managed
  `mise:activate` block. `~/.config/fish/conf.d/00_mise_activate.fish` is
  still there too, so fish activates mise twice. Open: delete the conf.d
  file.
- `user.login_shell`: removed 2026-10-31; skogix's shell stays declared
  on the user (`shell = "/usr/bin/fish"`).
- zsh: installed, not set up (`~/.zshrc` is a uv stub). Needs `zsh = true`
  here and `atuin init zsh`.

### systemd-units (2026-10-14)

`[bootstrap.linux.systemd.units.<name>]` writes
`~/.config/systemd/user/dev.mise.<name>.{service,timer}`, then enables and
restarts it. mise only touches `dev.mise.*`. No mise activation inside:
absolute paths, set `PATH`. Secrets go in `environment_file`.

- None declared. `dev.mise.gptme-server.service` is still on disk and
  active, an orphan from the 2026-10-14 migration: `dev.mise.*` is
  excluded from history, so a fresh machine doesn't get it. Open: declare
  it again or stop and delete it.

### tools

Step 16 is `mise install` for `[tools]`; see `SKOGAI.md` for the layers.

### task and hooks (2026-10-14)

`[tasks.bootstrap]` runs after everything else, with `[tools]` on PATH:
`systemctl is-enabled -q sshd.service || omarchy-setup-security-sshd`,
same for `tailscaled`, and (2026-11-09) the `skogai-health` timer linked
from `../machine/units/` when `systemctl --user is-enabled` says it isn't.
A no-op on this machine. It assumes Omarchy, so it
fails elsewhere (open: guard it). No hooks declared (`pre-/post-packages`,
`-repos`, `-dotfiles`, `-user`, `-tools`, `final`).

### remote, unapply, plugins: not now (2026-10-14)

- `remote` sends a project dir, not the global config, so using it means
  moving the bootstrap config into a repo first. It was used once to adopt
  `skogai2/claude-home` as claude's mise config (`../secrets/fnox.md`).
- `unapply <env>` only targets config environments/modules
  (`mise.<env>.toml`); everything here is global.
- `plugins` add package prefixes for other programs' state (VS Code, `gh`
  extensions, Helm); none here.

## open

- Full fresh-machine run in a container or VM (packages, accounts, repos,
  submodules, tools).
- Guard `[tasks.bootstrap]` for machines without Omarchy.
- `[history] git_email = "mise@{hostname}"`, so machine and agent commits
  can be told apart.
