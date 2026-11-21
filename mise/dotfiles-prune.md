---
permalink: config/mise/dotfiles-prune
type: checklist
---

# dotfiles prune: borderline entries to review

Taken from the 2026-11-20 mise dotfiles audit (§4). Review each entry to
decide whether it is real config worth saving or bloat/machine-state to
untrack (`owner` or `exclude` in `coverage.md`). Delete this file once
every box is checked.

## multi-file / mixed config

- [ ] `~/.config/aichat` (93 files, 1.1M): `models-override.yaml` (53K), generated `agents/{demo,loremaster}/rag.yaml` (238K), 87 role `.md` files (32 under `roles/old/`), `functions -> ~/skogai/tools`. Note conflict: `config.yaml` is excluded in `conf.d/dotfiles-tracking.toml` and explicitly tracked in `config.toml` (still has `api_key` keys).
- [ ] `~/.config/zed`: `~/.config/zed/settings.json` (441B, Nov 15: vim, ACP agents, code-review-graph) plus stale nested `~/.config/zed/zed/` from Oct 20 (`keymap.json` 44K, `settings.json` 29K, `themes/.keep` 0B). Keep only `settings.json` or drop Zed?
- [ ] `~/.config/systemd` (19 tracked): 9 are symlinks into already-bootstrapped repos (`containers/systemd`, `skogai`), plus 4 `90-t3code-protect.conf` drop-ins and `t3code`, `collie`, `antigravity-cli-daemon`, `captains-deck-web`, `pitchfork`, `voxtype` services. Prune repo symlinks and unused units?
- [ ] `~/.config/autostart` (8 files): 3 Omarchy stock (`limine-snapper-notify`, `org.fcitx.Fcitx5`, `print-applet`), `bitwarden`, `localsend_app`, duplicate `claude.desktop` + `claude-desktop.desktop`, and a Chromium PWA (`Skogfleet Lore & Roadmap`).

## app-specific configs (check if still used)

- [ ] `~/.config/voxtype`: `config.toml` looks stock, and `omarchy/defaults/dictation` is `superwhisper`. Drop (with `systemd/user/voxtype.service`)?
- [ ] `~/.config/cursor`: `cli-config.json` (837B, mostly default Cursor CLI opts).
- [ ] `~/.config/cactus`: `sky.toml` (only 1 active line: `bird_max = 2`) + `tui.json`.
- [ ] `~/.config/ecc2`: `config.toml` (82 lines: `db_path`, worktree/budget settings).
- [ ] `~/.config/gptme`: `config.toml` (33 lines: user bio + `GPTME_AUTOCOMMIT = true`).
- [ ] `~/.config/goose/config.yaml` and `~/.config/goose/.goosehints`: 110-line extensions config + Concord global hints.
- [ ] `~/.config/bash-screen/config.toml`: 6 lines, hardcoded `host = "skogix@skogix-workstation"`.
- [ ] `~/.config/gita`: `groups.csv` + `repos.csv` (42 hardcoded local repo paths, churning) + empty `repos.context`.
- [ ] `~/.config/omafin/config.json`: Jellyfin server URL + machine `deviceId`.
- [ ] `~/.config/openknowledge`: `registry.json` (2 local wiki paths: `~/.local/src/okn/Wiki`, `~/Work/wiki`).
- [ ] `~/.config/qmd`: `index.yml` (`docs` collection + 3 local HF GGUF model refs).
- [ ] `~/.config/sunshine`: `apps.json` + `sunshine.conf` (workstation LAN/Tailscale IPs).
- [ ] `~/.config/the-agentic-startup/statusline.sh` and `statusline.toml`: 16K Claude Code statusline script and config.

## small XDG / home files

- [ ] `~/.config/mimeapps.list`: default app associations (churns on edits).
- [ ] `~/.config/user-dirs.dirs`: maps all XDG dirs to `$HOME/`.
- [ ] `~/.config/user-dirs.locale`: `en_US`.
- [ ] `~/.config/gtk-3.0`: `bookmarks` with hardcoded `/home/skogix/*` paths.
- [ ] `~/.config/xdg-terminals.list`: `kitty.desktop`.
- [ ] `~/.config/uwsm`: `env.d/50-qs-bitwarden-ssh-agent` (managed by the `qs-bitwarden-cli` Quickshell plugin; currently active `SSH_AUTH_SOCK`).
- [ ] `~/.gemrc`: `gem: --no-document`.
- [ ] `~/.profile`: `.cargo/env` + `~/.local/bin` + `~/.lmstudio/bin`.
