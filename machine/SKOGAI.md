---
permalink: config/machine/skogai
type: router
---

# machine

Machine-wide state that no other concern owns. Declared machine state
(packages, users, services) is mise's: see ../mise/bootstrap.md.

<routes>

- health - `failed-units`: failed systemd user units. Run all checks with ../bin/health

</routes>
