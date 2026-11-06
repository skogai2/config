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

The same pattern as `quadlet-health`. Install is a manual step skogix
confirms, because it writes to the user's systemd config:

```sh
systemctl --user link ~/.config/skogai/machine/units/skogai-health.service \
  ~/.config/skogai/machine/units/skogai-health-notify.service \
  ~/.config/skogai/machine/units/skogai-health.timer
systemctl --user enable --now skogai-health.timer
```

Every failing check notifies once an hour, so fix (or knowingly accept)
the current failures first. `containers` failures notify twice: once from
`quadlet-health`'s own timer, once from this one.
