# Secrets: keys and who can read what

A living record of how secrets are encrypted and which user can decrypt
them, updated directly as the agreement changes. **Status: draft
(2026-10-14).** Nothing below has been created on the machine yet. The
mise side (how secrets reach `mise bootstrap` and tasks) is in `mise.md`,
item 4.

## Model

- Secrets are stored with fnox, encrypted with age. `fnox.toml` holds only
  ciphertext, so it is safe to commit and to share between users.
- A secret is encrypted to a list of **recipients** (public keys). Any one
  matching **identity** (private key) decrypts it.
- Separation between users comes from Linux file permissions on the
  identity files, not from fnox profiles. A profile only chooses which
  secrets get asked for.
- Trust goes one way: skogix (the admin, with sudo) can reach everything;
  agents can reach only their own keys.

## Keys

| File | Owner, mode | Created by | Leaves the machine | Purpose |
|---|---|---|---|---|
| `~skogix/.ssh/skogix-age.txt` | skogix, 0600 | skogix, once | Yes, carried like `id_rsa` | Personal and admin key: reads everything, enrols new keys |
| `~skogix/.ssh/local-per-machine-age.txt` | skogix, 0600 | bootstrap task, if missing | Never | skogix on this machine; revoke one machine on its own |
| `~claude/.ssh/local-per-machine-age.txt` | claude, 0600 | bootstrap task (as claude), if missing | Never | claude on this machine |

`~skogix/.ssh` and `~claude/.ssh` are 0700 and owned by their user. The
other agents (dot, amy, goose) follow the claude row when they need keys.

## Providers and profiles

Two fnox ideas that are easy to mix up (and were, in the Oct 11 tests):

- A **provider** decides how a secret is encrypted. For age that is the
  recipient list, so it decides **who can decrypt**. Providers are named
  after their readers.
- A **profile** decides **which secrets are asked for**. Profiles stack
  (`-P claude,skogix` is the union). A profile grants nothing: asking for
  a secret your key can't open fails with "No matching keys found".

| Provider | Recipients | Readable by |
|---|---|---|
| `skogix-only` | skogix personal + skogix machine keys | skogix |
| `claude-and-skogix` | claude machine keys + skogix personal | claude, skogix |

| Profile | Holds secrets from | Used by |
|---|---|---|
| `skogix` | `skogix-only` | skogix (as `claude,skogix`) |
| `claude` | `claude-and-skogix` | claude; skogix too, through the stack |

skogix personal is on every recipient list. So there's no separate
"shared" provider: a secret both need goes in the `claude` profile, and
skogix reads it with `FNOX_PROFILE=claude,skogix`. It also means the
personal key can always `fnox reencrypt` after a recipient is added.

## Where the config lives

Agents can read `fnox.toml` but must not be able to change it. Writing
a secret uses only the public keys in it, and age ciphertext is not
signed, so a writer could add their own recipient (the next `fnox set`
or `reencrypt` encrypts to it) or swap in a value of their choosing.
Your private key protects who can *read*, not who *wrote*.

Decided (2026-10-14): `/etc/skogai/fnox.toml`, root-owned, `0644`, dir
`0755`, deployed by `[bootstrap.files]` from a source in
`~/.config/mise/files/` (inside skogix's `0700` home), the same way the
cloudflared unit is handled. Changing it = edit the source, run
`mise bootstrap`. fnox has no env var for the config path, so use
`fnox -c /etc/skogai/fnox.toml` (or a wrapper/alias).

Why not under `/skogai`: a path is only as safe as every directory on
it. `/skogai` is `2775` without the sticky bit, so any `skogai` member
can rename `/skogai/<anything>` away and put their own in its place, even
if the subdirectory itself is `2755`. (By Linux rename rules; to be
confirmed in the `sudo -u claude` tests.) Every directory on
`/etc/skogai` is writable only by root.

Later, maybe: the source lives in dash-skogai and changes go through a PR
with agent/sanity review before `master`. The deploy must then copy from
reviewed `master` (`git show master:<path>`), never the `/skogai` working
tree, which agents can write.

## Rules

- Private key files are never committed, synced, or put in a group-shared
  dir (`/skogai` is group `skogai`, readable by every agent).
- If `~/.ssh` becomes a git repo, its `.gitignore` is an allowlist (`*`,
  then `!.gitignore`, `!*.pub`, `!config`, `!known_hosts`) so a new key
  file is ignored by default.
- Removing a recipient does not revoke access: the old ciphertext stays in
  git history. After a key leaks, rotate the secrets themselves.
- `fnox.toml` starts with `if_missing = "error"`, so a failed decryption
  fails the task instead of running it with empty values.
- Agents get none of: sudo/`wheel`, skogix's sockets (ssh-agent, fnox
  daemon, podman), skogix's environment (`sudo -u` resets it; keep it so).

## Open

- Which file fnox reads per user: a combined identity file built from the
  key files, or a `key_file` per provider. `~` in `key_file` expands per
  user, which may make one shared `fnox.toml` work for both.
- Whether claude needs a carried key too (for cloud sessions, which today
  get `FNOX_AGE_KEY` injected).
- Testing as claude, against throwaway secrets (include: claude can rename
  a dir it doesn't own inside `/skogai`). Later also
  `herdr --remote claude@localhost` / `herdr machine add`.

## Test access: ssh claude@localhost (2026-10-14)

Working: `ssh -i ~/.ssh/claude-test claude@localhost`. The key is
skogix's, `~/.ssh/claude-test`, test-only. claude's
`~/.ssh/authorized_keys` (0600, dir 0700) restricts it with
`from="127.0.0.1,::1"`. Password login stays off (Omarchy's
`10-omarchy-hardening.conf`). claude's shell is `/usr/bin/bash`, declared
in `~/.config/mise/config.toml` (was `nologin`). Set up with
`/tmp/runwithsudo.sh`. Undo: shell back to `nologin`,
`mise bootstrap accounts apply`, remove claude's `authorized_keys`.

claude's own global mise config is the repo `skogai2/claude-home`
(public; submodule `claude-home/` here), with `config.toml` at the root.
It was adopted as claude's `~/.config/mise` from skogix's side:

```sh
mise bootstrap remote --host claude@localhost -i ~/.ssh/claude-test \
  --adopt skogai2/claude-home
```

mise bundles the repo locally and uploads it, so claude needs no GitHub
access. claude can rerun `mise bootstrap` itself; `--update` pulls new
commits. The pre-adopt config is at `~claude/.config/mise.bak-2026-10-14`.
herdr reaches claude as the machine `claude-at-localhost` (needs
`ssh-add ~/.ssh/claude-test`, lost on reboot). Never commit private keys
to claude-home: they are created on the machine by claude's bootstrap.
