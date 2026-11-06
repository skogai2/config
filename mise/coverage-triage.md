---
permalink: config/mise/coverage-triage
type: checklist
---

# coverage triage: the 60 undecided `~/.config` entries

The working list for PROJECT.md section 2, taken from `../bin/check-coverage`
on 2026-11-06 (42 tracked, 18 decided, 60 undecided). One batch at a
time:

1. skogix confirms, changes or skips each proposal in the batch.
2. Each decision becomes a row in `coverage.md` (`owner` / `exclude`),
   or a `mise dot` track rule for `track`. Every `mise dot` write is
   confirmed first.
3. The item gets checked off here, and `../bin/check-coverage` shows the
   undecided count going down.

This file is deleted once every box is checked: the decisions live in
`coverage.md` and the mise path rules, not here.

The proposals are based on file count, size and file names only. No
file contents have been read. Sizes are as of 2026-11-06.

## batch 1: never track (app profiles, caches, logins) → `owner`

- [ ] `chromium`: 10.6k files, 4.2G browser profile
- [ ] `chromium-headless`: 694 files, 25M
- [ ] `BraveSoftware`: 14 files, browser profile
- [ ] `google-chrome`: browser profile
- [ ] `google-chrome-beta`: browser profile
- [ ] `google-chrome-for-testing`: browser profile
- [ ] `google-chrome-unstable`: browser profile
- [ ] `microsoft-edge-dev`: browser profile
- [ ] `zen`: 111 files, 63M browser profile
- [ ] `heroic`: 8.1k files, 1.8G Electron profile and cookies
- [ ] `Codex`: 3.8k files, 527M app state
- [ ] `Perplexity`: 806 files, 19M Electron profile
- [ ] `t3code-v2`: 283 files, 7.2M Electron profile
- [ ] `backpass`: 480 files, 7.6M
- [ ] `Bitwarden CLI`: `data.json` (vault cache)
- [ ] `Claude-3p`: empty

## batch 2: credentials → `exclude` (and check history)

These look like secrets by name. Before deciding, check that none of them
is already in the dotfile history (`mise dot` log, read-only).

- [ ] `age`: `phone-backup.key`
- [ ] `antigravity`: `credential-user-scope`
- [ ] `hey-cli`: `credential-storage`, `credentials.lock`
- [ ] `pulse`: `cookie`
- [ ] `captains-deck-web`: `vapid.json` (a web-push private key)

## batch 3: real config → `track`

Small and hand-edited by the look of it. Excludes are noted where a dir
also holds logs or backups.

- [ ] `aichat`: `config.yaml`, `models-override.yaml` (91 files, 1.1M: check what the rest is)
- [ ] `rtk`: `config.toml`, `filters.toml`, `pipeline.toml`
- [ ] `voxtype`: `config.toml`
- [ ] `uwsm`: 1 file
- [ ] `environment.d`: `90-gcr-ssh-agent.conf`, `omarchy-firefox-wayland.conf` (Omarchy's?)
- [ ] `fontconfig`: `fonts.conf`; exclude `*.omarchy-upgrade-*.bak`
- [ ] `xdg-desktop-portal`: `hyprland-portals.conf`
- [ ] `hyprland-mimeapps.list`
- [ ] `chromium-flags.conf`
- [ ] `nushell`: `config.nu`
- [ ] `rust-analyzer`: `rust-analyzer.toml`
- [ ] `vlc`: `vlcrc`, `vlc-qt-interface.conf`
- [ ] `ecc2`: `config.toml`
- [ ] `devin`: `config.json`, `mcp_config.json`, `AGENTS.md`
- [ ] `cursor`: `cli-config.json`
- [ ] `cactus`: `sky.toml`, `tui.json`, `poke-webhooks.json` (webhook URLs may be secret)
- [ ] `Moonlight Game Streaming Project`: `Moonlight.conf`
- [ ] `KDE`: `qrca.conf`
- [ ] `hype`: `hype.ini`
- [ ] `jellyfin-mpv-shim`: `conf.json`, `mpv.conf`, `input.conf`; exclude `users.json*` (logins), `*.lock*`
- [ ] `superwhisper`: settings; exclude `*.lock`
- [ ] `sunshine`: `apps.json`; exclude `sunshine.log*`, `sunshine_state.json` (pairing state)

## batch 4: look first (possible secrets or bigger questions)

- [ ] `goose`: `config.yaml`, `.goosehints`; there's a `secrets.yaml.lock`
- [ ] `cloudflare`: `state.json`; PROJECT.md says to check it for secrets first
- [ ] `containers`: 308 files, the quadlets the tracked `systemd/user`
      links point into; tracked once, then dropped. Settle this one first
      (`../containers/SKOGAI.md`)
- [ ] `skogai`: this repo, which has its own git → `owner`?

## batch 5: delete or merge

- [ ] `nvim.backup.20261023-184226`: merge what's still wanted into `nvim`, then delete
- [ ] `argc`: empty, delete
- [ ] `nautilus`: empty, delete (or `owner` if nautilus recreates it)
- [ ] `pangolin`: `pangolin-update-check.json` only → `exclude`
- [ ] `treehouse`: `update-check.json` only → `exclude`

## batch 6: unsorted, small

- [ ] `aether`: `wallhaven.json`, `previous-omarchy-theme` (state?)
- [ ] `astro`: `config.json`
- [ ] `basic-memory`: `config.json`; exclude `basic-memory.log`
- [ ] `Hermes`: 5 GPU/sandbox `*-fallback.json` files (generated?)
- [ ] `nextjs-nodejs`: `config.json` (telemetry flag?)
- [ ] `omafin`: `config.json`
- [ ] `ruflo`: 1 file
- [ ] `Code`: 1 file (VS Code)
