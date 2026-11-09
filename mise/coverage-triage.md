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

An item without a `skogix:` note means the proposal is accepted
(skogix, 2026-11-06). The proposals are based on file count, size and file names only. No
file contents have been read. Sizes are as of 2026-11-06.

## batch 1: never track (app profiles, caches, logins) → `owner`

- [x] `chromium`: 10.6k files, 4.2G browser profile
  - skogix: profile is `owner`, but keep a re-usable list of extensions/settings if possible (an export, not the profile)
  - later (skogix 2026-11-06): profile decided `owner`; the export is its own to-do
- [x] `chromium-headless`: 694 files, 25M
- [x] `BraveSoftware`: 14 files, browser profile
- [x] `google-chrome`: browser profile
- [x] `google-chrome-beta`: browser profile
- [x] `google-chrome-for-testing`: browser profile
- [x] `google-chrome-unstable`: browser profile
- [x] `microsoft-edge-dev`: browser profile
- [x] `zen`: 111 files, 63M browser profile
  - skogix: track the dotfiles part (`user.js`, `chrome/*.css`, `profiles.ini`?), profile data `owner`
- [x] `heroic`: 8.1k files, 1.8G Electron profile and cookies
- [x] `Codex`: 3.8k files, 527M app state
- [x] `Perplexity`: 806 files, 19M Electron profile
- [x] `t3code-v2`: 283 files, 7.2M Electron profile
- [x] `backpass`: 480 files, 7.6M
- [x] `Bitwarden CLI`: `data.json` (vault cache)
  - skogix: possibly track the login targets/settings (server URL etc.), never the vault
- [x] `Claude-3p`: empty

## batch 2: credentials → `exclude` (and check history)

These look like secrets by name. Before deciding, check that none of them
is already in the dotfile history (`mise dot` log, read-only).

- [x] `age`: `phone-backup.key`
- [x] `antigravity`: `credential-user-scope`
  - skogix: possibly settings; look at what else it writes once it's used
- [x] `hey-cli`: `credential-storage`, `credentials.lock`
- [x] `pulse`: `cookie`
- [x] `captains-deck-web`: `vapid.json` (a web-push private key)

## batch 3: real config → `track`

Done 2026-11-06, checkpoint 984. Excludes as listed, plus superwhisper
`cloud-usage.json` and `cloud-device-id` (noise, trimmed after 984);
mise's credential filter also omits `sunshine/portal_token`. Still open:
look at `cactus/poke-webhooks.json` (excluded until then).

Small and hand-edited by the look of it. Excludes are noted where a dir
also holds logs or backups.

- [x] `aichat`: `config.yaml`, `models-override.yaml` (91 files, 1.1M: check what the rest is)
  - 2026-11-06: `config.yaml` excluded, it holds an `api_key` (line 10); roles and agents tracked
- [x] `rtk`: `config.toml`, `filters.toml`, `pipeline.toml`
- [x] `voxtype`: `config.toml`
- [x] `uwsm`: 1 file
- [x] `environment.d`: `90-gcr-ssh-agent.conf`, `omarchy-firefox-wayland.conf` (Omarchy's?)
- [x] `fontconfig`: `fonts.conf`; exclude `*.omarchy-upgrade-*.bak`
- [x] `xdg-desktop-portal`: `hyprland-portals.conf`
- [x] `hyprland-mimeapps.list`
- [x] `chromium-flags.conf`
  - reversed 2026-11-06: line 8 is `--oauth2-client-secret`; untracked, decided `exclude` until encrypted
- [x] `nushell`: `config.nu`
  - skogix: track the basic dotfiles
- [x] `rust-analyzer`: `rust-analyzer.toml`
- [x] `vlc`: `vlcrc`, `vlc-qt-interface.conf`
- [x] `ecc2`: `config.toml`
- [x] `devin`: `config.json`, `mcp_config.json`, `AGENTS.md`
- [x] `cursor`: `cli-config.json`
- [x] `cactus`: `sky.toml`, `tui.json`, `poke-webhooks.json` (webhook URLs may be secret)
- [x] `Moonlight Game Streaming Project`: `Moonlight.conf`
  - reversed 2026-11-06: the file holds the client certificate and private key
    (line 21 `key`). Captured in checkpoint 984, blocked from publishing by mise;
    untracked and decided `owner`. Still to do: remove it from the local history
- [x] `KDE`: `qrca.conf`
- [x] `hype`: `hype.ini`
- [x] `jellyfin-mpv-shim`: `conf.json`, `mpv.conf`, `input.conf`; exclude `users.json*` (logins), `*.lock*`
- [x] `superwhisper`: settings; exclude `*.lock`
  - 2026-11-06: mise's publish check flags `shortcuts.lua:145` (`token=tostring(serial)`, a Lua
    variable): a false positive, published once with `--allow-plaintext-history`
- [x] `sunshine`: `apps.json`; exclude `sunshine.log*`, `sunshine_state.json` (pairing state)

## batch 4: look first (possible secrets or bigger questions)

- [x] `goose`: `config.yaml`, `.goosehints`; there's a `secrets.yaml.lock`
  - skogix: track the basic dotfiles (`config.yaml`, `.goosehints`), exclude `secrets.yaml*`
- [x] `cloudflare`: `state.json`; PROJECT.md says to check it for secrets first
- [x] `containers`: 308 files, the quadlets the tracked `systemd/user`
      links point into; tracked once, then dropped. Settle this one first
      (`../containers/SKOGAI.md`)
  - skogix: is its own git repo, should be in mise bootstrap/dotfiles
  - found: `containers/systemd` is already `[bootstrap.repos]` (`skogai/podman`); the only
    other entry is `nodocker`, an empty marker file. So: `owner` (repo) + decide `nodocker`
- [x] `skogai`: this repo, which has its own git → `owner`?
  - skogix: mise bootstrap/dotfiles
  - found: already `[bootstrap.repos]."~/.config/skogai"` (`skogai2/config`). So: `owner` (repo)

## batch 5: delete or merge

- [x] `nvim.backup.20261023-184226`: nothing merged, moved to the trash 2026-11-09 (see below)
  - skogix: double check, and keep `nvim` monitored as dotfiles/bootstrap
- [x] `argc`: empty, deleted 2026-11-06
- [x] `nautilus`: empty, deleted 2026-11-06 (`owner` if nautilus recreates it)
- [x] `pangolin`: `pangolin-update-check.json` only → `exclude` (2026-11-09)
  - skogix: skip for now
- [x] `treehouse`: `update-check.json` only → `exclude` (2026-11-09)
  - skogix: skip for now

## batch 6: unsorted, small

- [x] `aether`: `wallhaven.json`, `previous-omarchy-theme` (state?)
- [x] `astro`: `config.json`
- [x] `basic-memory`: `config.json`; exclude `basic-memory.log`
- [x] `Hermes`: 5 GPU/sandbox `*-fallback.json` files (generated?)
- [x] `nextjs-nodejs`: `config.json` (telemetry flag?)
- [x] `omafin`: `config.json`
- [x] `ruflo`: 1 file
- [x] `Code`: 1 file (VS Code)

## done 2026-11-06 (checkpoints 994-996)

- tracked as file entries (no directory, so nothing excluded was ever captured):
  `goose/config.yaml`, `goose/.goosehints`, `omafin/config.json`, `zen/profiles.ini`,
  `zen/<profile>/chrome/zen-themes.css`. Not tracked: goose `secrets.yaml*`,
  `chatgpt_codex/tokens.json`, `kimicode/device_id`; the zen profile itself (no `user.js` exists)
- `basic-memory`: `exclude`, not `track`: `config.json` has token/api-key fields
- `nvim.backup.20261023-184226` vs `nvim`: `lua/plugins/herdr-nvim.lua` only in the backup;
  `lazy-lock.json`, `lazyvim.json`, `config/remote_clipboard.lua`, `plugins/all-themes.lua`,
  `plugin/after/transparency.lua` differ; `plugins/lualine-transparent.lua` only in `nvim`.
  skogix to pick what to merge before the backup is deleted.
  2026-11-09: the backup is `nvim` just before checkpoint 388 (2026-10-23 18:42), which
  rewrote the clipboard and transparency on purpose; every differing file in `nvim` is the
  newer version. Only two one-liners were not carried over: `herdr-nvim.lua`
  (`return { "ChmaraX/herdr-nvim", opts = {} }`, in history from checkpoint 178) and the
  `lazyvim.plugins.extras.ai.claudecode` extra in `lazyvim.json`. Not merged (unused for
  two weeks); re-add either by hand if wanted. The dir is in the desktop trash
  (`~/.local/share/Trash/files/`), not deleted.
