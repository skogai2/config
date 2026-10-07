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
- Config: `~/.config/herdr/config.toml`. It mirrors the Omarchy tmux config
  (`prefix = ctrl+space`, `prefix+c` new tab, `alt+h/j/k/l` focus). Apply
  changes with `herdr server reload-config`.
- Shell: `dash-skogai/fish/config.fish` loads `herdr completion fish`.
- Window manager: Omarchy's "Herdr" floating terminal is the dropdown
  terminal on `Mod+grave` (see `window-manager.md`).

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
