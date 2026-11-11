---
permalink: config/shell/atuin
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
- **Env vars and aliases: no longer.** As of atuin 18.24 (seen 2026-11-06)
  the dotfiles feature is "legacy": `atuin dotfiles var list` / `alias list`
  still show the old synced data, but there is no `set` or `delete`, and
  `atuin init` no longer exports any of it. The old vars are inert data in
  atuin's store (including one secret-named var, left as is: unused).
  Six names on that list are set nowhere else any more: `FNOX_PROFILE`,
  `PODMAN_COMPOSE_WARNING_LOGS`, `SKOGAI_OLLAMA_API`, `TEST`,
  `XDG_SKOGAI_CONFIG_DIR`, `XDG_SKOGAI_DIR`. Env vars and aliases need a
  new home (PROJECT.md walkthrough item 3: mise vs atuin).

## Per-machine setup

- Package: `atuin` (Arch `extra` repo).
- Shell integration: the login shell is fish, which runs
  `atuin init fish | source` from `~/.config/fish/conf.d/00_atuin_init.fish`.
  bash keeps `eval "$(atuin init bash --disable-up-arrow --disable-ctrl-r)"`
  in `~/.bashrc`. zsh is installed but not set up yet; it will need its own
  `atuin init zsh`.
- Login: `atuin login -u skogix`, encryption key at
  `~/.ssh/atuin.key.encrypted`.
- Sync also runs via the background daemon (`[daemon] enabled = true` in
  `~/.config/atuin/config.toml`), roughly every 5 minutes, in addition to
  syncing after each command.
- Output capture stays off. It needs `[pty_proxy] enabled = true`
  (`atuin config enable output-capture`), which on 2026-10-20 locked up
  every terminal, so it was reverted. The MCP's `atuin_output` and
  `atuin_output_search` therefore return nothing here.

## Gotchas

- `atuin status` doesn't zero-pad the hour (`Last sync: 2026-11-09
  0:15:46...`); `shell/health` parses both (fixed 2026-11-09).
- Two atuins: pacman's `/usr/bin/atuin` (18.24.1) and mise's (18.24.2,
  which runs the daemon and the shell). The user-scope MCP entry pins
  `/usr/bin/atuin`, so the thread tools fail against the newer daemon.
  The MCP setup changed on 2026-11-11; recheck which atuin it runs.

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
