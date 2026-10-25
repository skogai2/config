---
permalink: config/skogai
type: router
---

<routes>

- @atuin.md - shell history sync + primary way env vars/aliases are managed
- @mappings.md - keyboard mapping conventions, by tool (window manager, tmux, nvim, ...)
- @herdr.md - herdr: terminal workspace manager for coding agents; setup, agent hook, and pane conventions for skogai
- @containers.md - container runtime setup (Docker → Podman divergence from Omarchy stock)
- @secrets.md - age/fnox keys per user, who can decrypt what (draft)
- @mise.md - mise tool manager + MCP server; ongoing feature walkthrough (start each session at its first unchecked item)

</routes>

## history

1. **stow** (~15 years ago): dotfiles in one repo, symlinked into place.
2. **ai-skogai**: the same config plus docs written for and with AI
   agents.
3. **skogai config 3.0** (started 2026-10-25): an agent can act on the
   machine safely. Every action is tagged honestly, so `read` never
   reveals secrets and runs without asking. Goals are still being
   defined.

## tools

Each one owns its own area. skogai adds the routes and conventions on
top and doesn't reinvent any of them.

- Omarchy (Arch, Hyprland): the base system and its defaults
- mise: tool versions, machine state (`bootstrap`), dotfile history
- atuin: shell history; env vars and aliases for now (see `mise.md` item 3)
- fnox + age: secrets (draft, see `secrets.md`)
- herdr: workspaces and panes for agents
- podman: containers, run as quadlets
- git: this repo and the other config repos
