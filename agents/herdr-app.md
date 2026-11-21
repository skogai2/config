# herdr-app

The Herdr desktop app (`herdr-app`, 0.1.16 on 2026-11-20). Not the herdr
TUI (`herdr.md`). Its whole interface is files in `~/.config/herdr-app/`;
`~/.config/herdr-app/AGENTS.md` (rewritten by the app on every start) is
the authority on layouts, keys and mods.

**Principle: record the recipe, not the result.** Third-party layouts and
mods are reinstalled from their source, using the prompt their gallery page
gives. Only what is ours gets tracked: keys, settings, our own mods, and the
local changes listed below.

## where things come from

- Gallery: https://herdr.dev/gallery/ (layouts) and
  https://herdr.dev/gallery/?type=mods (mods). Each entry is a public GitHub
  folder with a `RECIPE.md` (the brief to build it from scratch) and a
  copy-paste install prompt:
  `Read ~/.config/herdr-app/AGENTS.md, then add this mod|layout: <url>`.
- Give that prompt to an agent in `~/.config/herdr-app/`. AGENTS.md
  ("Layouts and mods other people made") says how: read everything first,
  copy without overwriting, merge the item's `keys.json`, then
  `herdr-app check`.
- No manifest records where an installed item came from.
  `installed.json` only holds hashes of Herdr's own shipped files, so the
  sources are listed here.

- agenttrail is read-only: GETs to `127.0.0.1:5330-5344` (`/panel`,
  `/board-lite`) only, runs `git rev-parse`, and on **Start Map here**
  `npx -y agenttrail@0.4.1 <repo> --no-open` in a tab (the one step that
  reaches npm). Needs that Map running to show anything. In `~/Work`,
  `mise run agenttrail:start` runs this repo's Map in the foreground (its
  first run saves it in `~/.agenttrail/`), `:up` starts every saved Map
  that isn't running (`agenttrail up`), `:status` lists them, `:stop`
  stops this repo's (`~/Work/mise.toml`). There's no `--help`: an
  unknown argument becomes the repo path and starts a board for it.
- The lazyvim layout has no agenttrail block upstream; it was added by
  hand on 2026-11-20 and not re-added after the 2026-11-21 reinstall.

Install in this order: herdr-nvim patches the layout that's on screen, so
lazyvim has to be installed and shown first.

### 1. layout `lazyvim`: why: the main daily layout
- Source: https://github.com/EmmanuelVernet/herdr-neovim
- Prompt: `Read ~/.config/herdr-app/AGENTS.md, then add this layout: https://github.com/EmmanuelVernet/herdr-neovim/tree/main`
- Brings: `layouts/lazyvim.json`, the `mods/lazyvim*` mods (dashboard, picker,
  cmdline, which-key, flash, notify, inbox, context, lazy) and
  `themes/lazyvim.json`. Its `keys.json` merges in as `layout:lazyvim`.
- Our change: `ctrl-space` in `layout:lazyvim` opens `skogix-prefix`.
  Upstream's which-key moves to `ctrl-shift-space`.
- Check: the layout root has `"toast": "lazyvim-notify"`. See gotchas.

### 2. mods `herdr-nvim` and `herdr-nvim-header`: why: a real nvim sidebar and file editing inside Herdr
- Source: https://github.com/ChmaraX/herdr-nvim (`herdr-app/`), release v1.3.1.
  Recipe: `herdr-app/RECIPE.md` in that repo.
- Prompt: `Read ~/.config/herdr-app/AGENTS.md, then add this mod: herdr.dev/mods/ChmaraX/herdr-nvim--herdr-app`
- Or the installer, with `lazyvim` on screen:
  `curl -fsSL https://raw.githubusercontent.com/ChmaraX/herdr-nvim/main/install.sh | sh -s -- --app`
- The installer downloads the latest *release* (runtime in
  `mods/herdr-nvim/bin/`; nvim itself comes from Homebrew or
  `~/.local/share/herdr-nvim/nvim`). It also patches the layout on screen:
  the `files` slot and a floating `herdr-nvim-sync` block. **A layout
  without that patch has no `cmd-e` nvim.** Rerun the installer after
  anything rewrites the layout.
- Keys (global): `cmd-e` `mod.open:herdr-nvim`, `cmd-o` `herdr-nvim.pick`,
  `cmd-shift-e` `herdr-nvim.reveal`.

### 3. layout `World-of-Codecraft` + mod `world-of-codecraft`: why: an agent overview drawn as a game map, for fun
- Source: https://github.com/kevinpardo/world-of-codecraft
- Prompt: `Read ~/.config/herdr-app/AGENTS.md, then add this layout: https://github.com/kevinpardo/world-of-codecraft`
- Brings a theme `World-of-Codecraft`. Merge `mods/world-of-codecraft/KEYS.json`
  (`layout:World-of-Codecraft`: `ctrl-shift-j` toggles `place`,
  `ctrl-shift-i` `world-of-codecraft.mode`).
- Our changes:
  - `place.js:40` recruits codex as `["codex", "--no-daemon"]` (see
    AGENTS.md, Programs).
  - Its layout carries herdr-nvim's patch (rerun the installer with it on
    screen).

### 4. mod `agenttrail`: why: a live map of what agents touch in a repo (added 2026-11-20)
- Source: https://github.com/sodiumsun/agenttrail (`herdr/agenttrail/`)
- Prompt: `Read ~/.config/herdr-app/AGENTS.md, then add this mod: https://github.com/sodiumsun/agenttrail/tree/main/herdr/agenttrail`
- Open it: it docks right in its own layout, else
  `herdr-app do pane.split --direction right --mod agenttrail`.
- What it reaches:
  - It only GETs `127.0.0.1:5330-5344` (`/panel`, `/board-lite`) and runs
    `git rev-parse`.
  - **Start Map here** runs `npx -y agenttrail@0.4.1 <repo> --no-open` in a
    tab. That's the one step that reaches npm.
  - It shows nothing until a Map is running. In `~/Work`,
    `mise run agenttrail:up | :status | :stop | :start` runs the
    mise-installed Map instead (`~/Work/mise.toml`).
  - There's no `--help`: an unknown argument becomes the repo path and
    starts a board for it.

### ours
- `keys.json`: Herdr's defaults plus vim-style pane keys (`alt-hjkl` go,
  `alt-shift-hjkl` swap), `alt-[`/`alt-]` tabs, the herdr-nvim keys, the
  `ctrl-space` prefix, and the layout sections above. Pre-prefix version:
  `keys.json.before-prefix-20261115-150623`. Herdr no longer upgrades an
  edited keys file, so new default shortcuts must be added by hand.
- `mods/skogix-prefix/`: the herdr TUI's `ctrl-space` prefix rebuilt as an
  app mod. The mapping lives in `bindings.js` and the key table in its
  `README.md`. It only calls built-in commands.
- `settings.json`: `appearance: dark`, no ligatures, everything else at
  defaults.

### Herdr's own (never track or edit)
- Layouts `main`, `terminals`, `win98` and every mod named in
  `installed.json`. Herdr replaces them on start.
- To change one, clone it (`layout.clone` / `mod.clone`). The clone is
  ours: track it and list it under "ours".
- `<name>-edited` folders are Herdr's response to an edited shipped file.
  Diff one against the shipped mod before keeping it. Six that were
  identical (leftovers from the 2026-11-19 mise apply, below) were deleted
  on 2026-11-21.

## rebuild from nothing

1. Install herdr-app and herdr-core, and start the app once so it writes
   `AGENTS.md` and the shipped files.
2. `mise apply` restores ours (keys, settings, `skogix-prefix`, `SKOGAI.md`).
3. Run the prompts above in order (1 → 4). Switch to `lazyvim`
   (`herdr-app do layout.switch --name lazyvim`) before step 2.
4. Reapply the "our changes" items. Then `herdr-app check` each mod and
   `herdr-app status` for errors.

## tracking (mise dotfiles)

Since 2026-11-21 (skogix: "follow my own advice"), only ours is tracked
in `~/.config/mise/config.toml`: `keys.json`, `settings.json`, `SKOGAI.md`
(a route back to this page) and `mods/skogix-prefix/`. Third-party layouts,
mods and themes are reinstalled from the prompts above. Their local changes
(the codex line) are recorded here as steps, not as files. A new clone or
own mod gets its own track entry and a line under "ours".

`[history] exclude` keeps app-written `gpui-kit.d.ts` and `jsconfig.json`
under mods, plus backups (`*.before-*`, `*.broken-*`, `*.old-*`,
`*.reset-*`).

The `*-edited` leftovers were deleted on the same day. Previously
(2026-11-20) all of `layouts/`, `mods/` and `themes/` were tracked, with
Herdr's shipped files excluded.

## gotchas

- 2026-11-19 21:24, checkpoint 1988 (`mise apply`, 346 incoming changes
  from origin): replaced `layouts/lazyvim.json` with a version wrapped in an
  extra row holding `agents-edited`, `tabs-edited`, `win98-edited` and
  `worktree-edited` blocks, and without `"toast": "lazyvim-notify"`. Which
  machine wrote it isn't recorded. Fixed 2026-11-20 by restoring upstream's
  file (checkpoint 2125) and rerunning the herdr-nvim installer.
- 2026-11-21 08:00, checkpoint 2327 (machine `git`): `layouts/lazyvim.json`
  deleted and every `layout:*` section plus herdr-nvim's and
  `skogix-prefix`'s global keys dropped from `keys.json`, in the same minute
  Herdr's shipped mods were rewritten. Cause not found. Reinstalled by hand
  the same day: upstream layout, keys restored from before 2327
  (`keys.json.before-restore-20261121` kept), herdr-nvim installer rerun.
  `agents/health` now checks this (`herdr-app-layout`).
- `herdr-app do <cmd>` takes `--arg value`: `herdr-app do layout.switch
  --name lazyvim`, not `layout.switch lazyvim`.
