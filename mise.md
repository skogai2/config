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

1. If an item under **Walkthrough** is `[~]`, that's the current topic:
   read its notes and continue from there. Otherwise take the first item
   that isn't `[x]` (items can be taken out of order).
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

### [x] 1. `mise bootstrap` — declarative machine setup

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
    these scripts. Done, see task/hooks below.
  - `cloudflared`: hand-placed at `/etc/systemd/system/cloudflared.service`
    (no owning package; token in `/etc/cloudflared/token`). It can be
    declared once `files` manages the unit (`notify` → service). Done,
    see the files entry below.
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
- **firewall — decided: nothing declared** (2026-10-14). The backend is
  UFW (enabled; nftables/firewalld unused). Everything on it belongs to
  Omarchy: the defaults (deny in, allow out, drop forward) and LocalSend
  `53317/tcp+udp` come from `/usr/share/omarchy/install/config/firewall.sh`,
  and `limit 22/tcp` (comment `omarchy-sshd`) from
  `omarchy-setup-security-sshd`. Reference:
  `tmp/mise-docs/bootstrap/firewall.md`.
  - mise only removes rules it created (UFW comment `mise:<name>`), so it
    couldn't have done the `allow-docker-dns` cleanup in `containers.md`.
    `exclusive = true` on UFW runs `ufw reset`, which would wipe Omarchy's
    rules too, so don't use it.
  - It needs root even for `status`, so declaring it makes every
    `mise bootstrap status` ask for sudo.
  - Adopt it later for rules Emil adds directly. Likely candidates are
    ports for the quadlet stack: rootless Podman (pasta) publishes ports as
    ordinary host sockets, so unlike Docker they go through UFW's input
    chain and the deny-incoming default applies.
- **compose — decided: not adopted** (2026-10-14). mise's compose
  support needs Docker Compose v2. It passes `--project-directory` and
  reads `config --hash` to detect drift. podman-compose (what `docker
  compose`/`podman compose` resolve to here) supports neither. Tested with
  a throwaway config: status `unknown`, dry run refused. Reference:
  `tmp/mise-docs/bootstrap/compose.md`.
  - Nothing to declare anyway: the `~/tmp` stack is gone (termix/guacd now
    run as quadlets), the gptme stack isn't running, and no container on
    the machine has compose labels.
  - The only fix would be the Arch `docker-compose` package (v2) as
    podman's compose provider. That undoes its `absent` entry above, which
    isn't worth it.
  - Containers live in the quadlet repo (`~/.config/containers/systemd`),
    and it's managed by hand in that repo itself. Neither `compose` nor
    `systemd-units` should take it over.
- **files — decided: adopt, for hand-placed system files** (2026-10-14).
  `[bootstrap.files]`/`[bootstrap.directories]` converge content, owner,
  group and mode, and use sudo only for the changes that need it. A file
  with no `source`/`content` manages permissions only and is never
  created or removed. `notify` reloads a declared system service, and mise
  runs `daemon-reload` first, so unit files can live here. Home-dir files
  you edit belong in `[dotfiles]` (item 2). Reference:
  `tmp/mise-docs/bootstrap/files.md`.
  - cloudflared declared in `~/.config/mise/config.toml`: the unit
    (`source = "./files/cloudflared.service"`, a copy of the live file,
    root 0644, `notify = ["cloudflared"]`), `/etc/cloudflared` (root
    0755), the token as permissions-only (root 0600; content stays
    hand-placed until item 4), and `[bootstrap.services.cloudflared]`
    (running, enabled). Status and dry run: all unchanged, no sudo prompt.
  - `/skogai` (2026-10-14): the declared paths were already correct, but
    10,055 entries were in group `skogix` and 540 dirs lacked setgid
    (mostly `tools/mise`, the venv and `.git`). Fixed by hand as skogix,
    no sudo: `chgrp -R skogai /skogai` and
    `find /skogai -type d -exec chmod g+s {} +`. Then declared `/skogai` and
    `coordination/` (2775), `bin/` and `tools/` (2755; setgid adds no group
    write) and `coord.db` (permissions-only, 0664), all `skogix:skogai`.
    The `/skogai` README's permissions table now says `2755`. mise checks
    only the declared paths, so drift deeper in the tree needs the
    `chgrp`/`find` pair again. `admin/setup-coordination.sh` still creates
    `coord.db` and the group/users; revisit at `accounts`.
  - `~/.config/mise` is not a git repo, so `config.toml` and `files/` are
    not versioned yet. Revisit at item 2.
- **accounts — decided: adopt for the skogai agents** (2026-10-14).
  `[bootstrap.groups]`/`[bootstrap.users]` run first in bootstrap, before
  files, so files can name the accounts as owners. Only the fields that
  are set get managed. `groups` adds memberships without removing others
  unless `exclusive_groups = true`. Applying needs sudo, but status
  doesn't. Reference: `tmp/mise-docs/bootstrap/accounts.md`.
  - Declared: group `skogai` (system), the agent users claude, dot, amy and
    goose (system, primary group `skogai`, `/home/<name>`, `nologin`), and
    skogix's membership in `skogai`. IDs aren't pinned. `bootstrap plan`:
    22 unchanged, nothing to do.
  - mise counts the primary group as membership, so the agents need no
    `groups` list.
  - `nologin` (as of now): agents are identities, not logins. Login,
    `ssh`, `su` and `sudo -i` are refused. `sudo -u <agent> <cmd>`,
    systemd `User=` and cron still run as them.
  - **End goal: real login shells for agents.** An agent works by logging
    in over SSH as itself (`ssh claude@skogix-workstation`, `localhost`, or
    a server address). Not designed yet. When it is, it touches `shell`
    here, per-agent `authorized_keys` (files), sshd config, and the
    `limit 22/tcp` UFW rule Omarchy owns (see services/firewall).
  - This replaces `/skogai/admin/create-agents.sh` and the account half of
    `setup-coordination.sh`. Creating `coord.db` is the one thing left
    only the script does. Whether to trim the scripts is still open.
- **repos — decided: adopt for config/infra checkouts** (2026-10-14).
  `[bootstrap.repos]` maps a path to a `url` (plus an optional `ref`).
  Missing checkouts are cloned. Without `ref`, existing ones are left
  where they are; `repos update` fast-forwards them. mise never deletes a
  checkout and never touches local work: a dirty checkout or one whose
  origin doesn't match fails apply/update (`--skip-dirty` skips instead,
  on `mise bootstrap` too). Repos run after files, so a fresh machine gets
  `/skogai` (2775, setgid) from files first and then clones into the empty
  dir. Reference: `tmp/mise-docs/bootstrap/repos.md`.
  - Declared, no `ref`: `~/.config/skogai`, `~/.config/containers/systemd`,
    `~/.skogai` (dot-skogai) and `/skogai` (dash-skogai). Status
    at the time: `~/.skogai` current, the other three dirty (uncommitted
    work), so a plain `mise bootstrap` on this machine needs
    `--skip-dirty` while work is in progress.
  - Not declared: the home workspaces (`~/skogai`, `~/skogix`, `~/claude`,
    `~/dot`, ...), the 29 clones in `~/.local/src`, and `~/old/*`.
  - Unverified: whether mise clones submodules (`/skogai/gptme-contrib`).
    Check on a fresh machine or with a throwaway clone.
- **shell (`user`, `mise-shell-activate`) — decided** (2026-10-14).
  Reference: `tmp/mise-docs/bootstrap/shell.md`.
  - `user`: adopted. `[bootstrap.user] login_shell = "/usr/bin/fish"` plus
    `"pacman:fish"` in packages, since fish is a choice and Omarchy's
    default is bash. Both already matched.
  - `mise-shell-activate`: nothing declared. mise is already active
    everywhere: Omarchy's uwsm env gives the session shims, Omarchy's
    `bash/init` activates interactive bash, and
    `~/.config/fish/conf.d/00_mise_activate.fish` (hand-placed Oct 7)
    activates fish. `fish = "auto"` would add a second block to
    `config.fish`, and its only gain (shims for non-interactive fish) is
    already covered by the session PATH. Who owns the fish config gets
    decided at item 2 (dotfiles).
  - Long-term goal: zsh set up alongside fish. `"pacman:zsh"` was added
    and applied (zsh 5.9.2 installed, 2026-10-14). Still to do:
    `~/.zshrc` is only a uv-installer stub. It needs `zsh = true` under
    `mise_shell_activate` (writes `~/.zprofile` shims and `~/.zshrc`
    activation) and `atuin init zsh`.
- **systemd-units — decided: adopt for own user units** (2026-10-14).
  `[bootstrap.linux.systemd.units.<name>]` is written to
  `~/.config/systemd/user/dev.mise.<name>.service` (or `.timer`), then
  enabled and restarted. mise only touches `dev.mise.*` files, so adopting
  an existing unit means a rename and migration. `state = "absent"`
  removes only mise's own units. Units get no mise activation: use
  absolute paths and set `PATH`. Secrets go in an `environment_file`, never
  in `environment`. Reference: `tmp/mise-docs/bootstrap/systemd.md`.
  - `gptme-server` migrated as the example: old unit disabled and deleted,
    `dev.mise.gptme-server` active and enabled, port 5700 answers 200. The
    env file `~/.config/gptme/server.env` stays outside the config.
  - Removed: `gptme-agent-claude`/`-dot` (.service + .timer). They were
    disabled, so the files were deleted by hand.
  - Left alone: `voxtype` (Omarchy's `omarchy-voxtype-install` runs
    `voxtype setup systemd`; the override in `~/.config/systemd/user` is
    older than the package's `/usr/lib/systemd/user/voxtype.service`) and
    `collie` (herdr plugin).
  - `history-watch` (from services): decide at item 2, since it belongs
    to dotfiles.
- **tools — nothing to change** (2026-10-14). Step 16 of the run is
  `mise install` for `[tools]`, which is already how the 27 tools are
  managed. `bootstrap --only tools --dry-run`: all installed.
- **task/hooks — decided: a guarded `bootstrap` task** (2026-10-14).
  Hooks run commands at named points (`pre-/post-packages`, `-repos`,
  `-dotfiles`, `-user`, `-tools`, `final`). `[tasks.bootstrap]` runs
  after everything else, with `[tools]` on PATH. Both run on every
  `mise bootstrap`, so they must be safe to repeat. Reference:
  `tmp/mise-docs/bootstrap.md` (Hooks, The bootstrap task).
  - `[tasks.bootstrap]` in the global config runs
    `omarchy-setup-security-sshd` and `omarchy-install-service-tailscale`
    only when `sshd`/`tailscaled` aren't enabled (`systemctl is-enabled
    -q ... || ...`). This settles the services question: Omarchy's full
    flows stay in charge, and a fresh machine gets them from one
    `mise bootstrap` (interactively). On this machine it's a no-op
    (checked with `mise run bootstrap`).
  - No hooks declared.
- **remote — decided: not now** (2026-10-14). Ansible-style push:
  `[bootstrap.remote.hosts.<name>]` is an inventory (host, user, tags,
  `mise_env`). `mise bootstrap remote` sends a project dir over SSH,
  stages mise there (temporarily unless `--install-mise`) and runs
  `mise bootstrap` on the host. Catch: it sends a project (`source`),
  not the global config, and everything here lives in
  `~/.config/mise/config.toml`. Using it means moving the bootstrap config
  into a repo first. Reference: `tmp/mise-docs/bootstrap/remote.md`.
- **unapply — decided: not now** (2026-10-14). `mise bootstrap unapply
  <env>` removes what a config environment/module (`mise.<env>.toml`)
  declared: files, directories, user services, systemd units, dotfiles.
  It plans from the current config, so keep the config until cleanup is
  done. It doesn't touch packages, repos or Compose (it prints guidance),
  or accounts, system services or the firewall. Everything here is in the
  global config with no env, so there's nothing it could target. It only
  becomes useful if the config gets split into modules. Reference:
  `tmp/mise-docs/bootstrap/modules.md`.
- **plugins — decided: nothing to declare** (2026-10-14). A package
  manager plugin (`[bootstrap.plugins]`, a git URL) adds a new prefix to
  `[bootstrap.packages]` for state that some other program owns: VS Code
  extensions, `gh` extensions, Helm or krew plugins. They install after
  `[tools]`, so the host command can come from mise, and never use sudo.
  No such host state here: no `gh` extensions, and no VS Code, Cursor,
  Helm or kubectl. Not needed for AUR either, since `aur:` is a built-in
  manager (yay/paru), the same as `pacman:`. Reference:
  `tmp/mise-docs/bootstrap/packages/plugins.md`.
- `secrets status` moved to item 4, where secrets are covered as a whole.
- **Summary (item 1 closed 2026-10-14).** `~/.config/mise/config.toml`
  now declares: packages (Podman switch, fish, zsh), accounts (skogai
  group + agents), files (cloudflared, `/skogai`), the cloudflared system
  service, repos (config/infra), the login shell, the gptme-server user
  unit, and a guarded `bootstrap` task. `mise bootstrap plan` converges
  to "nothing to change", except repos while they have uncommitted work.
- **Open threads from item 1:**
  - `~/.config/mise` (config + `files/`) isn't versioned, and it now holds
    real machine state. Settle it first at item 2. It also blocks
    `remote`, which needs a project dir.
  - Packages: go through `pacman -Qqe` for Emil's other additions (atuin,
    herdr, bitwarden, tailscale, the 7 AUR packages, ...).
  - zsh: installed but no mise/atuin setup (see shell).
  - Agents: real login shells over SSH (see accounts).
  - `/skogai/admin` scripts: trim down to `coord.db` creation (see
    accounts).
  - Repos: check whether mise clones submodules.
  - The cloudflared token's content and gptme's `server.env` stay
    outside mise until item 4.

### [~] 2. `mise dotfiles` — deploy, track, sync

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

- **Decided: track in place** (2026-10-18). mise history is the versioning
  for `~/.config`; deploy modes (symlink/copy/template) aren't used.
  Reference: `tmp/mise-docs/dotfiles.md`, `tmp/mise-docs/dotfiles/history.md`.
- Before: `~/.dotfiles` was a hand-run git repo (`master`) with 52
  `~/.config/<app>` symlinks into it. `[dotfiles]` declared only fish (as a
  symlink), and history tracked 0 files: its 44 checkpoints were empty
  bootstrap runs. Both the git repo and mise history pushed to
  `skogai2/.dotfiles` (`master` and `main`, unrelated histories).
- mise saves a symlink as a link, so tracking needs real files at the live
  path. All 52 links were replaced by their directories (`mv` back from
  `~/.dotfiles/.config`). `~/.dotfiles/.config/user-dirs.dirs` and
  `~/.config/nvim.backup.20261017-113454` (the old dotfiles nvim; something
  renamed the nvim link on 2026-10-17) are left for the dotfiles2 merge.
- `[dotfiles]` in `~/.config/mise/config.toml` now has 50 `mode = "track"`
  entries. Checkpoint 45 is the baseline (203 files). Not tracked:
  `~/.config/skogai` and `~/.config/containers/systemd` (own repos, see
  `[bootstrap.repos]`); herdr plugin checkouts are skipped as nested repos.
- mise's credential filter goes by filename only, and missed most of the
  real secrets here. Excluded by hand: `fnox` (include only `*.toml` and
  `identities/*.pub`; `age.txt` and `identities/*` are private keys),
  `gh/hosts.yml`, `anthropic/credentials`, `gptme/*.env` and `gptme/oauth`,
  herdr's collie `.env`. herdr is include-only (`config.toml`,
  `plugins.json`, `plugins/config/**`) to keep logs, sockets and session
  snapshots out. Check `mise dot paths` before tracking anything new.
- `SKOGAI_OLLAMA_API_KEY` moved out of `[env]` into
  `~/.config/mise/ollama.secret.env` (0600, `_.file`). The filter skips
  `*secret*`, so it stays out of history. Move to fnox at item 4.
- Origin disconnected (`mise dot origin --remove`). The old repo's `master`
  has the keys and tokens above in its git history. Plan: recreate the
  GitHub repo from scratch at the end, then `mise dot origin set <url>
  --sync sync`. Rotating the exposed keys is Emil's call.
- Open: `fish_variables` is tracked and noisy (fish rewrites it); revisit if
  `mise dot paths --noisy` flags it. `capture` (e.g. around
  `omarchy-update`) not tried yet.

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

### [~] 4. Secrets — `secrets`, `bootstrap secrets`, fnox

- `secrets ls` (experimental) — list secret names from the project's source
- `bootstrap secrets status` — check declared secret inputs are present (deferred here from item 1)
- `fnox` (installed as a mise tool) — jdx's secret manager, which mise
  integrates with

Questions to answer: `atuin.md` says to use "a proper secret manager" and
names none. Is fnox that manager? Where do the keys live, and how do they
reach mise `[env]`?

Notes:

- Picked ahead of item 2 (2026-10-14), straight after closing item 1.
  Nothing done yet: start with `mise secrets --help`,
  `mise bootstrap secrets --help`, `fnox --help` and
  `tmp/mise-docs/bootstrap/secrets.md`. Concrete cases from item 1: the
  cloudflared token (`/etc/cloudflared/token`, root 0600, hand-placed),
  gptme's `~/.config/gptme/server.env` (the `dev.mise.gptme-server`
  `environment_file`), and the API tokens cleared out of atuin vars on
  2026-09-30 (`atuin.md`).
- Two separate mechanisms (2026-10-14). References:
  `tmp/mise-docs/bootstrap/secrets.md`,
  `tmp/mise-docs/environments/secrets/fnox.md`, and the earlier tests in
  `tmp/mise-secrets-testing/` (who-and-mode example, gotchas). All
  tested with throwaway values, copies kept in the session scratchpad.
  - `[bootstrap.secrets]` names inputs (`name = "ENV_VAR"`) that
    `[bootstrap.files]` (`template = true`) and `[dotfiles]` templates read
    with `secret()`. It works from the global config and doesn't care
    where the values come from. Tested: `fnox exec -- mise bootstrap files
    apply` wrote a 0600 file. A rerun is `unchanged`, and after a rotated
    value (`fnox set`) the plan shows `update`. Without values, `plan`
    marks the file `unknown` ("required secret unavailable") and apply/
    dry-run stop before writing anything. `secrets status --missing` exits
    1. A `-v` apply log didn't contain the value.
  - `[secrets.fnox]` + task `secrets = [...]`: per-task grants. Only
    project `mise.toml` is read (global config is ignored), and tasks
    started by `mise bootstrap` can't receive secrets. The who-and-mode
    example still works on 2026.10.9: claude can't get `skogix-only`, the
    human can, `mise env` shows nothing.
  - Gotcha still present: a task with an identity that can't decrypt
    runs anyway, with empty values and exit 0. Fix: `if_missing =
    "error"` at the top of `fnox.toml`. With it the task fails (rc 1).
  - `fnox set` on an age provider stores ciphertext. Global fnox config
    `~/.config/fnox/config.toml` loads from any directory (currently
    `default_provider = "keychain"` plus one example secret).
  - Not tested: a root-owned target (cloudflared) through mise's sudo
    helper, and `--prompt-secrets` (needs a TTY).
  - Still to decide: provider (age recommended over keychain, since
    keychain needs an unlocked desktop session), where the real
    `fnox.toml` lives (versioned), and how interactive-shell secrets (the
    old atuin tokens) are handled: `fnox exec` per command or
    `fnox activate`.

### [ ] 5. Extras (lower priority)

- `tasks` / `run` / `watch` — task runner (currently no tasks defined)
- `daemons` (experimental) — project daemons via pitchfork
- `oci` (experimental) — build/push/run OCI images of a project's tools
- `deps` (experimental) — project dependencies
- `skills` (`ls`, `sync`) — link agent skills shipped by tools
- `generate` — CI workflows, git hooks, devcontainers, install scripts
- `lock`, `outdated`, `upgrade`, `prune`, `doctor` — maintenance

Notes:
