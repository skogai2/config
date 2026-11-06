---
permalink: config/secrets/skogai
type: router
---

# secrets

Keys, who can decrypt what, and how secret values reach the tools that
need them. Never read secret values into a conversation.

<routes>

- fnox.md - fnox + age: keys, providers and profiles, where the config lives, test access (draft)
- ../mise/secrets.md - how secret values reach mise (`[bootstrap.secrets]`, fnox)
- health - `ssh-dir`, `age-keys`, `fnox-config`: key and config permissions. All checks: ../bin/health

</routes>
