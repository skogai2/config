# herdr

herdr (https://herdr.dev) is a terminal workspace manager for coding agents:
workspaces, tabs and panes, with agent state (`idle`, `working`, `blocked`,
`done`) recognised per pane. It is how skogai's agents get visible panes
and can drive each other. This page records the setup and the conventions
agreed for skogai; the binary's own `herdr --skill` is the authority on
command syntax.

## Per-machine setup

- Binary: `/usr/bin/herdr` (0.9.3 at time of writing). Server runs under
  the user; the socket is `~/.config/herdr/herdr.sock`.
- Config: `~/.config/herdr/config.toml`, Omarchy's shipped config plus the
  personal changes under "Keybindings" below. Apply changes with
  `herdr server reload-config`.
- Shell: `dash-skogai/fish/config.fish` loads `herdr completion fish`.
- Window manager: Omarchy's "Herdr" floating terminal is the dropdown
  terminal on `Mod+grave` (see `window-manager.md`).

## Keybindings

Changes on top of Omarchy's shipped config
(`~/.local/share/omarchy/config/herdr/config.toml`). Anything not listed is
Omarchy's default. Omarchy's herdr config mirrors its tmux config
(session -> workspace, window -> tab, pane -> pane), and the personal keys
mirror @tmux.md the same way. Prefix is `ctrl+space`.

| Keys                       | Omarchy default            | Personal                         |
|----------------------------|----------------------------|----------------------------------|
| `prefix+-` / `prefix+\|`   | —                          | Split stacked / side by side     |
| `prefix+h` / `prefix+v`    | Split stacked / side by side | (freed; `h` is previous tab)   |
| `alt+hjkl`                 | —                          | Focus pane                       |
| `ctrl+alt+arrows`          | Focus pane                 | (unbound)                        |
| `alt+shift+hjkl`           | —                          | Resize pane                      |
| `ctrl+alt+shift+arrows`    | Resize pane                | (unbound)                        |
| `prefix+h` / `prefix+l`    | —                          | Previous / next tab (added beside `prefix+p/n`) |
| `prefix+alt+r`             | —                          | Rename pane                      |
| `prefix+shift+o`           | Rename pane                | (unbound)                        |
| `prefix+shift+c`           | New workspace              | worktrunk picker (below); `new_workspace` is commented out |

Plugin keys:

| Keys              | Action                                   |
|-------------------|------------------------------------------|
| `prefix+e`        | herdr-nvim: nvim sidebar                 |
| `prefix+o`        | herdr-nvim: open file from agent output  |
| `prefix+ctrl+s`   | resurrect: save                          |
| `prefix+ctrl+r`   | resurrect: restore                       |
| `prefix+S`        | resurrect: save this space as…           |
| `prefix+O`        | resurrect: open saved space…             |
| `prefix+shift+c`  | worktrunk: switch / create worktree from default branch |
| `prefix+shift+m`  | worktrunk: merge into target branch      |

Commented out in the config, kept for later: lazygit (`prefix+g`,
`prefix+shift+g`), more worktrunk pickers, and the Captain's Deck plugin
manifest.

Other personal settings: `onboarding = false`, `[theme] auto_switch = true`,
`[ui] status_indicators = "symbols"` and `agent_panel_sort = "spaces"`,
`[ui.toast] delivery = "herdr"`, `[ui.sound] enabled = true`,
`[update] channel = "preview"`. The see-through tab bar (`panel_bg =
"reset"`, `surface_dim = "black"`) is Omarchy's own, from migration
`1791722809.sh`.

### Keeping it

`omarchy-refresh-config herdr/config.toml` (also run by
`omarchy-refresh-herdr`) replaces the file with the stock version and leaves
`config.toml.bak.<epoch>`. That happened 2026-10-24 09:06 (mise checkpoint
546) and went unnoticed until 2026-10-25; restored in checkpoint 616.
Check with:

```sh
diff ~/.local/share/omarchy/config/herdr/config.toml ~/.config/herdr/config.toml
```

The diff should show exactly the changes above.

## Agent integration

Claude Code reports pane state through a hook, installed by herdr:

- Hook: `~/.claude/hooks/herdr-agent-state.sh`, a symlink directory to
  `/skogai/scripts/claude/hooks/`. The file is herdr-managed and is
  overwritten by `herdr integration install claude`.
- Settings: `~/.claude/settings.json` runs it with `session` on hooks.
- Check: `herdr integration status`. Upgrade the Claude hook with
  `herdr integration install claude` (v8 → v10 on 2026-10-07).

Other agents on this machine, as of the same check: pi and opencode are
outdated (`herdr integration install pi` / `opencode`); codex and hermes are
current; the rest are not installed.

## Conventions for skogai

- Agents act on herdr only from inside a herdr pane. The check is
  `test "${HERDR_ENV:-}" = 1`. Outside herdr, do not control the focused
  session.
- Target panes by the IDs returned from JSON (`.result.pane.pane_id`), by
  `--current`, or by a unique live agent name. Never by sidebar order or
  a focused pane that may belong to the user.
- New work goes into a sibling pane in the caller's tab, in the caller's
  cwd, with `--no-focus`. Workspaces, tabs and worktrees are only created
  when asked for.
- Do not close workspaces, tabs, panes or sessions that the agent did not
  create. Never run `herdr server stop` from inside an active session.
- Prompt an agent with `herdr agent prompt <name> "<text>" --wait`. If it
  returns `blocked`, read it with `herdr agent read` and ask the user before
  answering an approval dialog. Do not resubmit a prompt after a timeout
  without checking; it may have been delivered.
- Experiments that need their own server use `--session <name>`, not the
  main session.

## Open

- Whether skogai coordination (`gptme-coordination`) should write
  herdr pane names, so a task's agent can be found by name.
- Whether the `herdr` skill (`herdr --skill`) should be installed as a
  Claude skill for skogai agents, instead of being read on demand.
