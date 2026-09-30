---
permalink: config/atuin
type: reference
---

# Atuin

Atuin (https://atuin.sh) is installed and is Emil's primary way of both
storing shell history and managing environment variables/aliases across
machines. This is a living record of that setup, updated directly as the
agreement changes — not derived from any single dotfiles file.

## What it does here

- **Shell history sync.** Every command run in an interactive shell is
  recorded and synced to Emil's atuin.sh account (username `skogix`), so
  history is shared across machines.
- **Env vars and aliases.** New environment variables and shell aliases are
  added via Atuin's dotfiles feature, not hand-written into `.bashrc`/`.zshrc`,
  so they sync to every machine automatically:
  - `atuin dotfiles var set NAME=value` — add/update an env var
  - `atuin dotfiles var delete NAME` — remove one
  - `atuin dotfiles var list` — see what's set
  - `atuin dotfiles alias set name=command` — add/update an alias
  - `atuin dotfiles alias delete name` / `list` / `clear` — same idea

  Only truly machine-local, one-off values (things that must never sync)
  belong directly in shell rc files instead.

## Per-machine setup

- Package: `atuin` (Arch `extra` repo).
- Shell integration: `eval "$(atuin init bash)"` in `~/.bashrc` (this
  machine's shell is bash).
- Login: `atuin login -u skogix`, encryption key at
  `~/.ssh/atuin.key.encrypted`.
- Sync also runs via the background daemon (`[daemon] enabled = true` in
  `~/.config/atuin/config.toml`), roughly every 5 minutes, in addition to
  syncing after each command.

## Caution: secrets

The dotfiles var list is a convenient place to accidentally park plaintext
secrets (API keys, passwords) since it looks like ordinary env var
management. On 2026-09-30 the whole var list was wiped after it was found
to contain things like `PASEO_PASSWORD` and several API tokens in the
clear. Prefer a proper secret manager for credentials; use Atuin dotfiles
vars for genuinely non-sensitive config (editor, browser, feature flags,
ports, etc).

## (future machines go here)

When setting up Atuin on a new machine, note anything that diverges from
this page (different shell → different init line, etc.) here rather than
assuming a clean slate.
