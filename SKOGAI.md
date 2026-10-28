---
permalink: config/skogai
type: router
---

<routes>

- @.skogai/TODO.md
- @README.md - what this repo is, for any agent
- @PROJECT.md
- dotfiles.md - read before changing a dotfile: live on a machine, or upstream in the origin. Never commit secrets there.

</routes>

## history

1. **stow** (~15 years ago): dotfiles in one repo, symlinked into place.
2. **ai-skogai**: the same config plus docs written for and with AI
   agents.
3. **skogai config 3.0** (started 2026-10-25): implement new tools and workflows to let agents manage machines, configurations and environments the same way skogai use "agentic ai" in other areas.

## tools

Each one owns its own area. skogai adds the routes and conventions on
top and doesn't reinvent any of them.

- Omarchy: the base system
- mise: tool versions, machine state (`bootstrap`), dotfile history
- atuin: shell history; env vars and aliases for now (see `mise.md` item 3)
- fnox + age: secrets (draft, see `secrets.md`)
- herdr: workspaces and panes for agents
- podman: containers, run as quadlets
- git: this repo and the other config repos

[@TODO:"split this into types of tools since many will differ both in choice of tools, usage and implementation"]

## environments

### skogix workstation

```toml
hostname: skogix-workstation
[@TODO:"add descriptions"]
```


### remote containers

[@TODO:"add more environments as we encounter them"]

