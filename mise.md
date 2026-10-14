---
permalink: config/mise
type: reference
---

# mise

mise (https://mise.jdx.dev) is installed as the tool-version manager
(`~/.config/mise/config.toml`, 27 tools, all `latest`), with an Omarchy
layer at `/etc/mise/conf.d/omarchy.toml` (only a `cursor-agent` tool alias).
It is also wired up as an MCP server (`mise mcp`).

The build here (2026.10.9) does far more than manage tool versions. Several
of its features overlap with things this repo already handles another way
(atuin for env vars/aliases, hand-run steps in `containers.md`, etc.). This
page tracks a guided walk through those features, one at a time, to decide
for each one: adopt it, ignore it, or adopt it in place of something else.

## Session protocol

This walkthrough spans several sessions, with `/clear` in between. At the
start of each session:

1. Find the first item under **Walkthrough** that isn't `[x]`. That's the
   current topic. If it's `[~]`, read its notes and continue from there.
2. Run `mise <command> --help` for that topic (and `--help` on its
   subcommands as needed), then go through it with Emil: what it does, and
   how it relates to what's already in place on this machine.
3. Run only `read` subcommands (`status`, `ls`, `diff`, `plan`, ...)
   without asking. Confirm any `write` or `destructive` subcommand first.
   `mcp__mise__list_commands` gives the classification for each one.
4. Before ending, record the outcome under the topic's **Notes** (what was
   decided and why, what was changed) and update its marker:
   `[ ]` = not started, `[~]` = in progress, `[x]` = decided, `[-]` = skipped.

Don't read `mise env` or `mise://env` output into the conversation without
asking. It may contain secrets.

## MCP server

- Tools: `list_commands` (catalog with `read`/`write`/`destructive`
  labels; it can't run anything), `install_tool`, `run_task` (runs
  arbitrary task code).
- Resources: `mise://tools`, `mise://tasks`, `mise://env`, `mise://config`.
- Anything else (`ls`, `outdated`, `doctor`, `--help`, ...) still goes
  through Bash.

## Walkthrough

### [~] 1. `mise bootstrap` — declarative machine setup

Describes a whole machine in config and applies it.

- `status`, `plan` — read state / preview changes
- `packages` (`apply`, `status`, `use`, `upgrade`, `prune`, `import`,
  `export`, `brew tap/untap`, `where`) — system packages
- `services` (`apply`, `status`, `remove`) — services
- `linux systemd-units` (`apply`, `status`) — systemd user units
- `firewall` (`apply`, `status`) — host firewall
- `compose` (`apply`, `status`) — Compose projects
- `repos` (`apply`, `status`, `update`, `exec`) — git checkouts
- `files` (`apply`, `status`) — system files/directories
- `accounts` (`apply`, `status`) — Linux users/groups
- `user` (`apply`, `status`) — login shell
- `mise-shell-activate` (`apply`, `status`) — mise activation in shell rc
- `plugins` (`apply`, `status`) — package-manager plugins
- `secrets status` — whether declared secret inputs are available
- `remote` — bootstrap machines over SSH
- `unapply` — remove what bootstrap created
- (`macos ...` — not relevant here)

Questions to answer: does this overlap with Omarchy's own install? Could the
pacman/ufw/systemd steps in `containers.md` have been declared here instead?
Could the two compose stacks live under `[bootstrap.compose]`?

Notes:

- Model (2026-10-14): Ansible-style desired state. Each declared entry is
  converged (`present`/`absent`) and re-applying is a no-op; anything not
  declared is left alone. Hooks and the `bootstrap` task run on every
  apply, so they must be safe to repeat. `bootstrap ls` = `bootstrap
  status`; before this session it only showed `[tools]` (what `mise -g use`
  writes), since nothing else was declared.
- Parts are walked in bootstrap's own run order: accounts/plugins →
  files/packages → services/firewall/compose → repos/dotfiles → shell →
  systemd units/user → tools → task/final-hook.
- **packages — decided: adopt, divergences only.** Omarchy owns the base
  package set (Omarchy 4 marks its stock packages explicit and doesn't keep
  its install list on disk, so `pacman -Qqe` can't separate the two).
  `[bootstrap.packages]` in `~/.config/mise/config.toml` declares only
  packages Emil actively chooses or rejects. Started with the
  `containers.md` switch: `podman`, `podman-docker`, `podman-compose`,
  `podlet` present; `docker-compose`, `docker-buildx`, `ufw-docker` absent.
  `apply --dry-run` and `bootstrap status --missing` both report nothing
  to change.
  - Gotcha: don't declare a package `absent` if an installed package
    `provides` it. `"pacman:docker" = { state = "absent" }` resolved to
    `podman-docker`, and the dry run would have removed it. Dropped; the
    `podman-docker` ↔ `docker` conflict already keeps Docker out.
  - On pacman/AUR, `"latest"` only means installed (no version pins);
    upgrades stay with `pacman -Syu`. `prune`/`import` are Homebrew-only.
  - Still open: going through `pacman -Qqe` to add Emil's other
    additions (atuin, herdr, bitwarden, tailscale, the 7 AUR packages, ...).
- **services — decided: nothing declared yet** (2026-10-14). System mode
  only starts/stops/enables/masks units a package or managed file already
  provides. User mode (`scope = "user"`) writes a plain
  `dev.mise.<name>.service` from `command`, plus the built-ins
  `history-watch` and `tool-update`. Units with hardening or an
  `EnvironmentFile` belong in `systemd-units`. Reference: the cloned docs at
  `tmp/mise-docs/bootstrap/services.md`.
  - `docker.socket`: can't be declared. The unit left with the package,
    and mise reports a missing unit as `unknown` and fails the apply. The
    `absent` packages already cover it.
  - `sshd`, `tailscaled`: left to Omarchy. Both were enabled through
    Omarchy menu flows (`omarchy-setup-security-sshd`,
    `omarchy-install-service-tailscale`). Those flows also add a UFW
    `limit 22/tcp` rule, authorized keys, sshd password-auth hardening,
    `tailscale up`, operator, the bar plugin and the webapp. Declaring only
    the unit would cover a fragment, and some steps are interactive. To
    reconsider at the bootstrap `task`/final-hook part: a task that calls
    these scripts.
  - `cloudflared`: hand-placed at `/etc/systemd/system/cloudflared.service`
    (no owning package; token in `/etc/cloudflared/token`). It can be
    declared once `files` manages the unit (`notify` → service).
  - `gptme-server`, `voxtype`: hand-written user units with extras →
    `systemd-units`. `collie`: owned by its herdr plugin, so left alone.
    `history-watch`: decide at item 2.
  - Found along the way: the user unit `podman.service` (Podman API) was
    enabled directly and failing at every login. Now socket-only (service disabled, socket enabled); see
    `containers.md` step 9.
    Also, `omarchy-tailscale-receive.service` (Taildrop) was disabled even
    though the tailscale flow enables it. Emil chose to enable it, and it
    is enabled and running as of 2026-10-14. That's an Omarchy-owned piece,
    so mise doesn't declare it either.
- Next: `firewall`, `compose` (the rest of `containers.md`; the quadlet
  stack in `~/.config/containers/systemd` is out of scope here, see
  `containers.md` "Later"), then `files`
  (cloudflared).

### [ ] 2. `mise dotfiles` — deploy, track, sync

Dotfile deployment plus versioned history. `config.toml` already has an
empty `[dotfiles]` section.

- `status`, `paths`, `diff` — read state
- `add`, `track`, `untrack`, `edit`, `exclude`, `include` — choose what's
  tracked
- `apply`, `unapply` — deploy `[dotfiles]` entries (link/copy/render)
- `save`, `watch`, `history` (`ls`, `show`, `diff`, `describe`) — checkpoints
- `rollback`, `undo`, `recover` — restore
- `origin` (`set`), `sync`, `pull`, `conflicts` — sync across machines
- `capture` — snapshot files before/after a command
- `notify` — test a desktop notification

Questions to answer: how does this compare with the git-tracked
`~/.config/skogai` and `dash-skogai` setup? Would `capture` be useful for
recording what an installer changed?

Notes:

### [ ] 3. Aliases and env vars — `shell-alias`, `set`/`unset`, `vars`

- `shell-alias` (`ls`, `get`, `set`, `unset`) — shell aliases in global config
- `set` / `unset` — env vars in `mise.toml` (`[env]`)
- `env` — print the resolved environment (may contain secrets, see above)
- `vars` (`ls`, `prompt`, `unset`) — config vars, including prompted ones
- `tool-alias` (`ls`, `get`, `set`, `unset`) — tool/version aliases

Questions to answer: atuin dotfiles (`atuin.md`) is the current owner of
env vars and aliases, synced across machines. Does mise replace that,
complement it (per-project `[env]` vs global), or stay out of it?

Notes:

### [ ] 4. Secrets — `secrets`, `bootstrap secrets`, fnox

- `secrets ls` (experimental) — list secret names from the project's source
- `bootstrap secrets status` — check declared secret inputs are present
- `fnox` (installed as a mise tool) — jdx's secret manager, which mise
  integrates with

Questions to answer: `atuin.md` says to use "a proper secret manager" and
names none. Is fnox that manager? Where do the keys live, and how do they
reach mise `[env]`?

Notes:

### [ ] 5. Extras (lower priority)

- `tasks` / `run` / `watch` — task runner (currently no tasks defined)
- `daemons` (experimental) — project daemons via pitchfork
- `oci` (experimental) — build/push/run OCI images of a project's tools
- `deps` (experimental) — project dependencies
- `skills` (`ls`, `sync`) — link agent skills shipped by tools
- `generate` — CI workflows, git hooks, devcontainers, install scripts
- `lock`, `outdated`, `upgrade`, `prune`, `doctor` — maintenance

Notes:
