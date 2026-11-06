---
permalink: config/mise/coverage
type: reference
---

# coverage: every `~/.config` entry decided

`../bin/check-coverage` lists every directory and file directly in
`~/.config` (skipping dot names and `*.bak` / `*.bak.*`) and sorts each
into one of three outcomes:

- **tracked**: a `mode = "track"` entry in `mise dot paths` covers it
  (a file entry like `~/.config/herdr/config.toml` covers `herdr`).
- **decided**: a row in the table below says `exclude` (never tracked,
  on purpose) or `owner` (the app owns it: profiles, caches, logins).
- **undecided**: neither. These are the to-do list, PROJECT.md section 2.

A name that is both tracked and decided is a `CONFLICT`: fix one side.
It's a standalone check, not part of `bin/health`, until section 2 is
worked through. Only skogix's decisions go in the table.

## decisions

| name | decision | why |
|---|---|---|
| vivaldi | owner | browser profile (PROJECT.md section 2, never track) |
| opera | owner | browser profile (PROJECT.md section 2) |
| microsoft-edge | owner | browser profile ("edge" in PROJECT.md section 2) |
| Bitwarden | owner | Electron app (PROJECT.md section 2) |
| Claude | owner | Electron app (PROJECT.md section 2) |
| Signal | owner | Electron app (PROJECT.md section 2) |
| Slack | owner | Electron app (PROJECT.md section 2) |
| discordcanary | owner | Electron app (PROJECT.md section 2) |
| go | owner | cache (PROJECT.md section 2) |
| yay | owner | cache (PROJECT.md section 2) |
| procps | owner | PROJECT.md section 2, never track |
| mpv | owner | empty (PROJECT.md section 2) |
| uv | exclude | installer receipt only (untracked 2026-10-27, PROJECT.md section 1) |
| tailscale | exclude | generated ssh_known_hosts for tailnet hosts (untracked 2026-10-27) |
| menus | exclude | generated .menu files (untracked 2026-10-27) |
| ibus | exclude | runtime bus address files only (untracked 2026-10-27) |
| fcitx | exclude | runtime dbus address file only (untracked 2026-10-27) |
| dconf | exclude | binary settings db written by apps; a `dconf dump` export if settings ever matter |
| chromium | owner | browser profile, 4.2G (coverage-triage batch 1, 2026-11-06); a re-usable extension/settings export is a later to-do |
| chromium-headless | owner | headless browser profile (triage batch 1) |
| BraveSoftware | owner | browser profile (triage batch 1) |
| google-chrome | owner | browser profile (triage batch 1) |
| google-chrome-beta | owner | browser profile (triage batch 1) |
| google-chrome-for-testing | owner | browser profile (triage batch 1) |
| google-chrome-unstable | owner | browser profile (triage batch 1) |
| microsoft-edge-dev | owner | browser profile (triage batch 1) |
| heroic | owner | Electron profile and cookies, 1.8G (triage batch 1) |
| Codex | owner | app state, 527M (triage batch 1) |
| Perplexity | owner | Electron profile (triage batch 1) |
| t3code-v2 | owner | Electron profile (triage batch 1) |
| backpass | owner | app state (triage batch 1) |
| Claude-3p | owner | empty, app-created (triage batch 1) |
| age | exclude | `phone-backup.key`, a private key; never in history (triage batch 2) |
| hey-cli | exclude | credential storage; never in history (triage batch 2) |
| pulse | exclude | PulseAudio auth cookie; in history checkpoints 45-655 (2026-10-18..26), removed (triage batch 2) |
| captains-deck-web | exclude | `vapid.json`, a web-push private key; never in history (triage batch 2) |
| containers | owner | `systemd/` is its own repo, declared in `[bootstrap.repos]` (skogai/podman); `nodocker` is an empty marker (triage batch 4) |
| skogai | owner | this repo, declared in `[bootstrap.repos]` (skogai2/config) (triage batch 4) |
| Moonlight Game Streaming Project | owner | pairing state: `Moonlight.conf` holds the client certificate and private key (tracked by mistake in checkpoint 984, never published; untracked 2026-11-06) |
| chromium-flags.conf | exclude | holds `--oauth2-client-secret`; track with `encrypt = true` once fnox/age is set up (untracked 2026-11-06) |
| cloudflare | owner | `config/default.json` holds `oauth_token` and `refresh_token`; `state.json` is a device id (triage batch 4, 2026-11-06) |
| aether | owner | `wallhaven.json` holds an `apiKey`; `previous-omarchy-theme` is Omarchy state (triage batch 6) |
| Bitwarden CLI | owner | `data.json` is the vault cache; there's no separate settings file to track (triage batch 1) |
| antigravity | exclude | only `credential-user-scope` so far; look again once it writes settings (triage batch 2) |
| basic-memory | exclude | `config.json` has `milvus_token`, `*_api_key` and `cloud_api_key` fields; track with `encrypt = true` once fnox/age is set up (triage batch 6) |
| astro | owner | telemetry id only (triage batch 6) |
| nextjs-nodejs | owner | telemetry id and salt only (triage batch 6) |
| Hermes | owner | installation id, generated GPU/sandbox fallbacks, Crashpad (triage batch 6) |
| ruflo | owner | `policy-trust/` ledger state only (triage batch 6) |
| Code | owner | VS Code Electron profile; `User/settings.json` can get its own file entry if VS Code is used (triage batch 6) |
