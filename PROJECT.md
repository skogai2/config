# config 3.1

The first step of 3.0 (see SKOGAI.md, history).

- **mise is the base.** `mise dotfiles` tracks `~/.config` in place and
  `mise bootstrap` declares machine state. skogai builds on top of them
  and replaces neither.
- **Paths, not symlinks.** Files are tracked where they live, by path
  rules (`mode = "track"`), instead of being linked in from a repo the
  way stow did it.
- **SKOGAI.md beside the dotfiles.** A tracked `~/.config/<app>/` that
  has skogai knowledge gets its own `SKOGAI.md`, versioned and synced
  with the app's config by mise history. Include-only dirs (fnox) need
  it added to their include list, file-entry apps (herdr, obsidian,
  opencode) their own entry for it.
- **This repo is the main entry point, grouped by concern, then by
  tool.** For example `./secrets/{fnox,ssh,ssh-agent,mise}/`:
  `secrets/fnox/` holds most of the knowledge and tooling for fnox, and
  `secrets/mise/` the secret-specific part of mise (`mise secrets`).
- **`~/.config/skogai/SKOGAI.md` is the root router** for all skogai
  configuration.

Open: how `secrets/fnox/` here and `~/.config/fnox/SKOGAI.md` split the
work, which one holds the knowledge and which one only routes to it.

## done when

- A fresh machine becomes this one with `mise bootstrap --adopt
  skogai2/.dotfiles`, plus only the steps written down as manual.
- Every `~/.config/<app>/` is tracked, excluded or left to its owner,
  and that choice is written down.
- This repo is grouped by concern, and every route in it is true.

## plan

Status as of 2026-10-25. `[x]` done, `[~]` in progress, `[ ]` not started.

### 1. the base: dotfiles and bootstrap

- [x] `~/.config` tracked in place (54 entries, 169 files as of 2026-10-27), synced to
  `skogai2/.dotfiles`; holes from the first tests fixed (`mise.md` item 2)
- [x] bootstrap declares packages (divergences only), accounts, files,
  repos, login shell, user units (`mise.md` item 1)
- [x] fresh-machine adopt tested for dotfiles; upstream edits through an
  origin clone tested (`dotfiles.md`)
- [ ] full fresh-machine run in a container or VM: packages, accounts,
  repos (do submodules clone?), tools, services
- [ ] `[tasks.bootstrap]` assumes Omarchy; guard it so other machines
  can run bootstrap
- [ ] `dev.mise.gptme-server` runs but is no longer declared (no
  `[bootstrap.linux.systemd.units]`): declare it again or remove it
- [ ] fish activates mise twice (bootstrap's `config.fish` block +
  `conf.d/00_mise_activate.fish`): delete the conf.d file
- [ ] `mise-history` user service `installed, differs`:
  `mise bootstrap services apply`
- [ ] `[history] git_email = "mise@{hostname}"`, so machine and agent
  commits can be told apart
- [ ] Obsidian cookies in pushed history: log Obsidian out everywhere,
  or rewrite history (skogix's call)
- [ ] `~/.cloudflared/token` in history (checkpoints 208-210,
  2026-10-19, removed but not erased): rotate the token if those were
  pushed, and the same history call as the cookies
- [ ] machine-specific files (`hypr/monitors.lua`, ...) as `machine`
  variants, once a second machine exists
- [~] noisy files: 2026-10-27 untracked `ibus`, `fcitx` (runtime
  socket files only) and `dconf` (binary db; a `dconf dump` export if
  settings matter), excluded herdr `*.panes` state and the theme files
  Omarchy generates (`zed/themes/omazed.json`,
  `spotifast/themes/omarchy.json`). Second pass (checkpoint 698, 185
  files): untracked `uv` (installer receipt), `tailscale` (tailnet host
  keys), `menus` (generated); excluded `fish/fish_variables`, worktrunk
  `approvals.toml` and gptme `project-trust.toml` (per-machine trust),
  all `spotifast/themes`, btop `current.theme`, bootstrap's `dev.mise.*`
  units and `no-mistakes-daemon-*`, openknowledge telemetry, the dangling
  `git/hooks` link. Left: the `mise/config.toml` 24h throttle (its edits
  are real; `--no-autosave`?); `fish_user_paths` and the main fish
  config split into conf.d files (later); leftovers `kitty/kitty.conf2`,
  `fish/bkg.config.fish`. Checkpoint 699 (169 files): systemd `*.wants`
  links excluded, herdr plugins, omarchy and bootstrap set them up.
  `fish/completions/*` stay tracked, many are added by hand.
- [ ] origin `README.md` + `.skogai/` (agent workspace, `dotfiles.md`)

### 2. coverage: every `~/.config/<app>/` decided

Not tracked yet, to sort into track / exclude / owner's:

- likely config: `aichat`, `argc`, `cactus`, `environment.d`,
  `fontconfig`, `goose`, `rtk`, `uwsm`, `voxtype`, `cloudflare` (check
  for secrets first), `hyprland-mimeapps.list`, `chromium-flags.conf`
- `containers`: the quadlets the tracked `systemd/user` links point
  into; tracked once on 2026-10-18, then dropped. Decide first.
- not sorted yet (2026-10-30): `aether`, `astro`, `backpass`,
  `basic-memory`, `captains-deck-web`, `Claude-3p`, `Codex`, `cursor`,
  `devin`, `ecc2`, `Hermes`, `heroic`, `hype`, `jellyfin-mpv-shim`,
  `Moonlight Game Streaming Project`, `nautilus`, `nextjs-nodejs`,
  `nushell`, `omafin`, `pangolin`, `ruflo`, `rust-analyzer`,
  `sunshine`, `treehouse`, `vlc`, `xdg-desktop-portal`
- app profiles, caches, logins (never track): browsers (incl. vivaldi,
  opera, edge, the chrome variants), Electron apps (`Bitwarden`,
  `Claude`, `Signal`, `Slack`, `discordcanary`, ...), `go`, `yay`,
  `procps`, `mpv` (empty)
- leftovers to delete or merge: `nvim.backup.*`, `*.bak`, and
  `.todo/dotfiles-old` (the old stow repo: merge what's still wanted,
  then remove). `~/.dotfiles` is not one: it's the mise history
  checkout of `skogai2/.dotfiles`.
- [ ] outside `~/.config`: does mise track anything in `~` at all?
  Candidates: `.bashrc` (+ 7 backups to clean), `.bash_profile`,
  `.profile`, `.zshenv`, `.inputrc`, `.XCompose`, `.gemrc`,
  `.ssh/config`, `.gnupg` config, `.git-templates`, `~/bin`,
  `~/.local/bin`, `~/.local/share/applications`, and the agent homes
  (`.claude`, `.codex`, `.gemini`, ...: mostly state, some config)
- [ ] packages: go through `pacman -Qqe` for the choices that aren't
  Omarchy's (atuin, herdr, bitwarden, tailscale, the AUR packages)

### 3. structure: this repo grouped by concern

- [ ] pick the concern groups and move the flat pages into them. A
  first cut: `machine/` (bootstrap, accounts, packages), `dotfiles/`,
  `secrets/`, `shell/` (atuin, fish, zsh), `containers/`, `desktop/`
  (window manager, mappings, tmux), `agents/` (herdr, agent accounts)
- [ ] split `mise.md` along the same lines; keep the walkthrough's
  decisions, drop the session protocol once the walkthrough is done
- [ ] `SKOGAI.md` beside the dotfiles: pick the first apps (herdr,
  fnox, atuin, fish), add it to include lists or as its own entry
  where needed
- [ ] settle the open question above (knowledge here or beside the app)
- [ ] `.skogai/SKOGAI.md` is empty: give it a route or remove it

### 4. the rest of the mise walkthrough

- [ ] item 3: aliases and env vars, mise vs atuin
- [ ] item 4: secrets (fnox + age, `secrets.md`): cloudflared token,
  gptme `server.env`, `ollama.secret.env`, the old atuin tokens
- [ ] item 5: extras (daemons, tasks, generate, maintenance)
- [ ] zsh beside fish (mise and atuin activation)
- [ ] agents with real login shells over SSH (`mise.md`, accounts)

# preparations for 3.1

- !`eza --tree --git-ignore ~/.config/skogai` - files in the current repo which should be moved and managed in the new system 
- !`eza --tree --git-ignore --level 2 --only-dirs ~/.config` - the current xdg config file tree 
