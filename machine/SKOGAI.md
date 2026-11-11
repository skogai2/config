---
permalink: config/machine/skogai
type: router
---

# machine

Machine-wide state that no other concern owns. Declared machine state
(packages, users, services) is mise's: see ../mise/bootstrap.md.

<routes>

- health - `failed-units`: failed systemd user units. Run all checks with ../bin/health
- units/skogai-health.timer - runs ../bin/health hourly; `skogai-health-notify` sends a critical desktop notification when it fails

</routes>

## health timer

The same pattern as `quadlet-health`. Installed 2026-11-09, and declared:
`[tasks.bootstrap]` in `~/.config/mise/config.toml` links the three
units from this checkout and enables the timer when it isn't enabled yet
(../mise/bootstrap.md, task and hooks). By hand, the same thing:

```sh
systemctl --user link ~/.config/skogai/machine/units/skogai-health.service \
  ~/.config/skogai/machine/units/skogai-health-notify.service \
  ~/.config/skogai/machine/units/skogai-health.timer
systemctl --user enable --now skogai-health.timer
```

The service's PATH starts with `~/.local/bin`: `/usr/bin/mise` (pacman
`mise-bin`) is a different version from the shell's `~/.local/bin/mise`,
and checking the wrong one fails `doctor` and `bootstrap-plan`. The
units are linked by a `[tasks.bootstrap]` line rather than declared in
`[bootstrap.linux.systemd.units]`, because mise's units have no
`OnFailure=`. A unit-file test or `systemd-analyze verify` doesn't catch
a PATH problem; a live run under the real unit (`systemd-run`) does.

## two copies of mise and atuin

pacman installs `/usr/bin/mise` (mise-bin) and `/usr/bin/atuin` beside
the user installs (`~/.local/bin/mise`, mise's atuin). Anything with its
own PATH (systemd units, MCP configs) can pick the other one: put
`~/.local/bin` first or name the binary. mise's copy always wins
(skogix, 2026-11-11); the pacman packages can go once nothing names
`/usr/bin/mise` or `/usr/bin/atuin`. The same goes for herdr:
`/usr/bin/herdr` is Omarchy's, mise's comes first. An agent's Bash tool
shell is zsh, where mise isn't activated, so `/usr/bin` comes first
there and `agents/health` reports a false `herdr-binary` failure; the
timer and fish get it right.

Every failing check notifies once an hour, so fix (or knowingly accept)
failures quickly. `containers` failures notify twice: once from
`quadlet-health`'s own timer, once from this one.
