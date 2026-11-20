# herdr-app

The Herdr desktop app (`herdr-app`, 0.1.16 on 2026-11-20). Not the herdr
TUI (`herdr.md`). Its whole interface is files in `~/.config/herdr-app/`;
`~/.config/herdr-app/AGENTS.md` (rewritten by the app on every start) is
the authority on layouts, keys and mods.

## what's installed

No manifest records where a mod or layout came from: third-party ones are
folders copied in, and `installed.json` holds only hashes of the files
Herdr itself shipped. So the sources are listed here.

| what | source | (re)install |
|---|---|---|
| layout `lazyvim` + mods `lazyvim*`, theme `lazyvim` | github.com/EmmanuelVernet/herdr-neovim | copy `layouts/`, `mods/`, `themes/` in; merge its `keys.json` (`layout:lazyvim`) |
| mods `herdr-nvim`, `herdr-nvim-header` | github.com/ChmaraX/herdr-nvim (`herdr-app/`), release v1.3.1 | with `lazyvim` on screen: `curl -fsSL https://raw.githubusercontent.com/ChmaraX/herdr-nvim/main/install.sh \| sh -s -- --app` |
| layout + mod `world-of-codecraft` | unknown | only copy is the dotfiles history |
| `skogix-prefix`, `*-edited` | own | tracked |

- herdr-nvim's installer downloads the latest *release* (runtime in
  `~/.local/share/herdr-nvim/app/<stamp>/`, not tracked) and patches the
  layout on screen: the `files` slot and a floating `herdr-nvim-sync`
  block. A layout without that patch has no `cmd-e` nvim. Rerun it after
  anything rewrites the layout.
- Keys: `cmd-e`, `cmd-o`, `cmd-shift-e` (herdr-nvim); `ctrl-space` in
  `layout:lazyvim` is `skogix-prefix` (upstream: which-key, moved to
  `ctrl-shift-space`).

## tracking (mise dotfiles)

Tracked: `keys.json`, `settings.json`, `layouts/`, `mods/`, `themes/`
(`~/.config/mise/config.toml`). Excluded in `[history] exclude`
(2026-11-20, skogix: "trim the noise"):

- app-written: `gpui-kit.d.ts`, `jsconfig.json`, `layouts/.state/`
- Herdr's shipped mods and layouts `main`, `terminals`, `win98` (the
  names in `installed.json`): Herdr replaces them on update. Edit a
  shipped one only through a clone (`mod.clone`), which is tracked.
- backups: `*.before-*`, `*.broken-*`, `*.old-*`, `*.reset-*`
- herdr-nvim's preview `.cache/`

## gotchas

- 2026-11-19 21:24, checkpoint 1988 (`mise apply`, 346 incoming changes
  from origin) replaced `layouts/lazyvim.json` with a version wrapped in an
  extra row holding `agents-edited`, `tabs-edited`, `win98-edited` and
  `worktree-edited` blocks, and without `"toast": "lazyvim-notify"`. Which
  machine wrote it isn't recorded. Fixed 2026-11-20 by restoring upstream's
  file (checkpoint 2125) and rerunning the herdr-nvim installer.
- `herdr-app do <cmd>` takes `--arg value`: `herdr-app do layout.switch
  --name lazyvim`, not `layout.switch lazyvim`.
