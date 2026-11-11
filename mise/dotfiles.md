---
permalink: config/mise/dotfiles
type: reference
---

# mise dotfiles: tracking `~/.config` in place

How `mise dotfiles` (`mise dot`) versions the config on this machine. To
change a dotfile through the origin repo instead of on the machine, see
`dotfiles-upstream.md`.

## state (2026-11-11)

- `[dotfiles]` in `~/.config/mise/config.toml`: 84 entries, 342 files,
  checkpoint 1406. All `mode = "track"` except one: `~/.config/atuin/config.toml = {}`
  is a symlink entry, linked to `~/.dotfiles/.config/atuin/config.toml`
  (an untracked path in that clone, so neither history has it). Open:
  intended?
- Origin `github.com/skogai2/.dotfiles` (private), branch `main`, mode
  `sync`, declared in `config.local.toml` (untracked). The watcher
  (`dev.mise.mise-history`, declared as
  `[bootstrap.services.mise-history] builtin = "history-watch"`) saves
  and publishes on its own.
- mise's history is the bare store `~/.local/state/mise/history/repo.git`
  (`refs/heads/main` = checkpoints, `refs/remotes/origin/setup` = last
  fetch). Read it with `mise dot history`, never raw git.
- `~/.dotfiles` is **not** that store (corrected 2026-11-11): it's a plain
  `git clone` of the origin (`home/.config/...`, `config/`), plus a
  `dotbot` submodule, an `.envrc` that runs `git pull`, and an untracked
  `.config/`. mise doesn't use it, except through the atuin symlink.
  Open: what it's for (upstream edits, `dotfiles-upstream.md`?).
- How a fresh machine goes from this history to a bootstrapped machine:
  `adopt.md`.
- Not tracked: `~/.config/skogai` and `~/.config/containers/systemd`
  (their own repos, see `bootstrap.md` repos).

## commands

- `status`, `paths`, `diff`: read state
- `add`, `track`, `untrack`, `edit`, `exclude`, `include`: choose what's
  tracked
- `apply`, `unapply`: deploy `[dotfiles]` entries (link/copy/render), not
  used here
- `save`, `watch`, `history` (`ls`, `show`, `diff`, `describe`):
  checkpoints. `save -d <text> --trigger agent` for a described save.
- `rollback`, `undo`, `recover`: restore
- `origin` (`set`), `sync`, `pull`, `conflicts`: sync across machines
- `capture`: snapshot files before/after a command (not tried yet, e.g.
  around `omarchy-update`)
- `notify`: test a desktop notification

## decided: track in place (2026-10-18)

mise history is the versioning for `~/.config`. Deploy modes
(symlink/copy/template) aren't used.

- mise saves a symlink as a link, so tracking needs real files at the live
  path. The 52 `~/.config/<app>` symlinks into the old `~/.dotfiles` git
  repo were replaced by their directories. Its 44 checkpoints before that
  were empty bootstrap runs.
- The old origin repo, whose `master` held keys and tokens, was deleted
  and recreated empty on 2026-10-18. mise refused to sync into an empty
  repo, so it was seeded once by hand:
  `GIT_DIR=~/.local/state/mise/history/repo.git git push <url> main:main`.
  After that `mise dot sync` and the watcher take over.
- Reinstall on a fresh machine: `mise bootstrap --adopt skogai2/.dotfiles`.
- Coverage: when unsure whether something is config, track it, then trim
  the noise within the hour (decided 2026-10-30). Config outside
  `~/.config` gets tracked in place too, with the same path rules.

## rules

- **Check `mise dot paths` before tracking anything new.** mise's
  credential filter goes by filename only and missed most of the real
  secrets here. Excluded by hand: `fnox` (include only `*.toml` and
  `identities/*.pub`; `age.txt` and `identities/*` are private keys),
  `gh/hosts.yml`, `anthropic/credentials`, `gptme/*.env` and
  `gptme/oauth`, herdr's collie `.env`. The filter skips `*secret*`, so
  `~/.config/mise/ollama.secret.env` (0600, `_.file`) stays out.
  It also misses keys inside ordinary config files (Moonlight.conf
  `key=`); the publish check catches those, but only after they're in
  local history. Before tracking a new app dir, grep its key names
  (`cut -d= -f1`) for key/cert/token.
- **`mise dot status` exits 0 while publishing fails.** The error is a
  `✗ last error:` line under Repository; `dot-sync` in `health` catches it.
- **Removing plaintext from history without `history purge`** (mise <
  2026.11): stop `dev.mise.mise-history.service`, move `main` back to the
  last published commit (`refs/remotes/origin/setup`), `mise dot save`,
  then `reflog expire` + `gc --prune=now`. The publish check stops at the
  first hit, so scan every new file before syncing or it takes one reset
  per secret (three on 2026-11-06). Each reset needs skogix's approval,
  and `--allow-plaintext-history` is skogix's to run, never an agent's.
- **A dir with a big ignored subtree is tracked by its files, not the
  dir.** The watcher holds an inotify watch on every subdirectory of a
  tracked dir, excluded or not: an `include`/`exclude` list limits what is
  saved, not what is watched. herdr, obsidian and opencode are file
  entries for that reason (herdr's plugin checkouts alone were ~5000
  watches).
- **A nested-repo warning means exclude it, not track it.**
  `~/.config/omarchy/plugins/**` is excluded for that reason.
- **A config change doesn't drop old watches:**
  `systemctl --user restart dev.mise.mise-history` after one. Count:
  the `inotify` lines in `/proc/<watcher pid>/fdinfo/*`.
- **After a mise upgrade, run `mise bootstrap plan`.** The watcher unit
  goes `installed, differs`; `mise bootstrap services apply` rewrites it.
- **`mise/config.toml` is throttled** to one save per 24h because it
  changes often. After an edit that matters: `mise dot save -d <text>`.
  It's the general churn backoff, not a rule for that file
  (`history.watch.max_interval`, `adopt.md` §4). Candidate fixes:
  `autosave = false` on that entry plus explicit saves, or find what keeps
  rewriting it.
- Runtime noise lives in `[history].exclude`: `**/*.bak`, `**/*.bak.*`,
  `**/*.lock`, `**/*.log`, `**/Singleton*` (Electron), generated themes,
  per-machine trust files (`worktrunk/approvals.toml`,
  `gptme/project-trust.toml`), `fish/fish_variables`, bootstrap's
  `systemd/user/dev.mise.*` units, systemd `*.wants` links.

## history of fixes

- **2026-10-19:** `~/.cloudflared/token` saved in checkpoints 208-210,
  then removed. Token rotated; erasing it from history is skogix's call.
- **2026-10-25 review** (mise 2026.10.17):
  - Sync had failed since 14:35 because of the omarchy plugin checkouts
    (one line tripped the secret scan). They were excluded, and one
    `mise dot sync --allow-plaintext-history` cleared the false positive.
  - Removed: the dead `~/.cloudflared/token` entry, the duplicate
    `~/.config/mise/config.toml` entry, `config.skogai.toml` (a second
    origin), duplicate tools `rg` and `pipx:ruff`, excludes for paths
    that aren't tracked.
- **2026-10-25 fresh-machine test** (throwaway Arch container, local bare
  copy of the history as origin): `mise bootstrap --adopt <url> --only
  dotfiles --yes` wrote 350 files plus `~/.config/mise/config.toml` and
  `files/`, and wrote `[history.origin]` into `config.local.toml` on its
  own. The watcher only starts with the services part. Found along the
  way: `~/.config/obsidian` tracked the whole Electron profile (cookies
  included); it's include-only now, but the cookies stay in pushed
  history.
- **2026-10-26 watch trim** (after a crash with too many watches): herdr,
  obsidian and opencode became file entries; 5592 → 293 watches.
- **2026-10-27 noise trim:** untracked `ibus`, `fcitx`, `dconf`, `uv`,
  `tailscale`, `menus`; details in `PROJECT.md` §1.
- **2026-10-29:** `fnox/age.txt`, `gh/hosts.yml`, gptme's oauth and
  `server.env`, and herdr collie's `.env` were tracked in checkpoints
  808-811 and removed again in 825. Treat them as burned; only the history
  rewrite is open.

## open

- `fcitx5` (9 files) is still tracked while `fcitx` was dropped as noise.
- 6 `systemd/user` links, `fish/completions/gptme.fish` and an nvim
  `theme.lua` point outside tracked paths (`containers` is the main
  hole).
- `hypr/monitors.lua` is machine-specific and wants a `machine` variant
  once there's a second machine.
- History rewrite for the 10-19 and 10-29 leaks and the Obsidian cookies.
