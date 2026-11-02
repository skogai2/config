---
permalink: config/mise/secrets
type: reference
---

# mise secrets: how secret values reach mise

The mise side of secrets. Keys, recipients and who can read what are in
`../secrets/fnox.md` (fnox + age). Status: tested with throwaway values, nothing
real moved yet.

## commands

- `mise secrets ls` (experimental): secret names from the project's source
- `mise bootstrap secrets status`: whether declared secret inputs are
  present
- `fnox` (a mise tool): jdx's secret manager, which mise integrates with

## two separate mechanisms (tested 2026-10-14)

- **`[bootstrap.secrets]`** names inputs (`name = "ENV_VAR"`) that
  `[bootstrap.files]` (`template = true`) and `[dotfiles]` templates read
  with `secret()`. Works from the global config and doesn't care where the
  values come from.
  - `fnox exec -- mise bootstrap files apply` wrote a 0600 file. A rerun
    is `unchanged`; after a rotated value (`fnox set`) the plan shows
    `update`.
  - Without values, `plan` marks the file `unknown` ("required secret
    unavailable") and apply/dry-run stop before writing anything.
    `secrets status --missing` exits 1. A `-v` apply log didn't contain
    the value.
- **`[secrets.fnox]` + task `secrets = [...]`**: per-task grants. Only a
  project `mise.toml` is read (the global config is ignored), and tasks
  started by `mise bootstrap` can't receive secrets. The who-and-mode
  example works on 2026.10.9: claude can't get `skogix-only`, the human
  can, `mise env` shows nothing.

## gotchas

- A task with an identity that can't decrypt runs anyway, with empty
  values and exit 0. Fix: `if_missing = "error"` at the top of
  `fnox.toml`; then the task fails (rc 1).
- `fnox set` on an age provider stores ciphertext. The global fnox config
  `~/.config/fnox/config.toml` loads from any directory (currently
  `default_provider = "keychain"` plus one example secret).
- Never read `mise env` or `mise://env` into a conversation without
  asking.

## waiting to move into fnox

- the cloudflared token (`/etc/cloudflared/token`, root 0600, hand-placed)
- gptme's `~/.config/gptme/server.env` (the `dev.mise.gptme-server`
  `environment_file`)
- `SKOGAI_OLLAMA_API_KEY` in `~/.config/mise/ollama.secret.env` (its
  `_.file` line in `[env]` is commented out)
- the API tokens cleared out of atuin vars on 2026-09-30 (`../shell/atuin.md`)

## open

- Not tested: a root-owned target (cloudflared) through mise's sudo
  helper, and `--prompt-secrets` (needs a TTY).
- Provider: age recommended over keychain, since keychain needs an
  unlocked desktop session.
- Interactive-shell secrets: `fnox exec` per command or `fnox activate`.
