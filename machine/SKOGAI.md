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
and checking the wrong one fails `doctor` and `bootstrap-plan`.

Every failing check notifies once an hour, so fix (or knowingly accept)
failures quickly. `containers` failures notify twice: once from
`quadlet-health`'s own timer, once from this one.
