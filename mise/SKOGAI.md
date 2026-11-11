---
permalink: config/mise/skogai
type: router
---

# mise

mise (https://mise.jdx.dev) is the base of skogai config: tool versions,
machine state (`bootstrap`) and dotfile history. skogai builds on it and
replaces none of it.

<routes>

- bootstrap.md - declared machine state: what's declared, per-part decisions, gotchas
- dotfiles.md - `~/.config` tracked in place: rules, excludes, watcher, history of fixes
- dotfiles-upstream.md - read before changing a dotfile through the origin repo. Never commit secrets there.
- coverage.md - every `~/.config` entry tracked or decided; checked by ../bin/check-coverage
- coverage-triage.md - checklist of the undecided entries, in batches with proposals, to go through with skogix
- health - `doctor`, `bootstrap-plan`, `dot-capture`, `dot-sync`. All checks: ../bin/health
- secrets.md - how secret values reach mise (`[bootstrap.secrets]`, fnox); keys are in ../secrets/fnox.md

</routes>

## rules

- Read-only commands (`status`, `plan`, `diff`, `ls`, `--dry-run`,
  `--help`) run freely. Anything that writes is confirmed first;
  `mcp__skogai-mise__list_commands` classifies each command.
- Never read `mise env` or `mise://env` into a conversation without
  asking.
- Use mise's own commands on the dotfile history, never raw git or
  systemctl on its store.
- Every `mise dot` write goes through the lead, one at a time; other
  agents return a verdict plus the exact command (2026-10-30).
- `mise doctor` exits 1 when it has problems, and its output includes
  env and settings: parse only the `N problem(s) found:` block, never
  print the rest.

## config layers (2026-10-31)

| file | holds |
|---|---|
| `~/.config/mise/config.toml` | `[tools]` (48), `[env]`, `[settings]`, `[dotfiles]`, `[history]`, `[bootstrap.*]`, `[tasks.bootstrap]`, `wrappers.cargo` (runs `mbx`, from the `mr-boxington` tool) |
| `~/.config/mise/config.local.toml` | `[history.origin]`; untracked |
| `~/.config/mise/ollama.secret.env` | one secret, 0600; untracked |
| `~/.config/mise/files/` | sources for `[bootstrap.files]` (`cloudflared.service`) |
| `/etc/mise/conf.d/omarchy.toml` | Omarchy: `upgrade.auto_prune = false`, `cursor-agent` tool alias |
| `/etc/mise/conf.d/omarchy-tools.toml` | Omarchy: the agent CLIs (claude, codex, opencode, ...) plus gh, node, uv |
| `/etc/mise/conf.d/omarchy-agent-accounts.toml` | Omarchy: `wrappers` for claude/codex/grok through `omarchy-agent-account-exec` |

The global config and `files/` are versioned by the dotfile history; the
`/etc` layers belong to Omarchy.

`[env]` sets, by name: `DO_NOT_TRACK`, `LOADOUT`, `EDITOR`, `VISUAL`,
`PAGER`, `TMPDIR`, `FM_HOME`, `WORKTRUNK_VERBOSE`,
`CLAUDE_CODE_PLUGIN_STORE_DIR`, `CLAUDE_CODE_ENABLE_FUNCTION_HOOKS`,
`SKOGAI_CONFIG_DIR`, `SKOGAI_DOCS_DIR`, `SKOGAI_CLAUDE_CODE_DOCS`,
`SKOGAI_CLAUDE_CODE_DOCS_DIR`. atuin dotfiles vars also set env vars and
aliases (`../shell/atuin.md`); who owns what is walkthrough item 3.

## MCP server

`skogai-mise` runs `mise mcp`.
- Tools: `list_commands` (catalog with `read`/`write`/`destructive`
  labels, can't run anything), `install_tool`, `run_task` (runs arbitrary
  task code).
- Resources: `mise://tools`, `mise://tasks`, `mise://env`,
  `mise://config`.
- Everything else (`ls`, `outdated`, `doctor`, `--help`) goes through
  Bash.

## check (2026-10-31)

- mise 2026.10.17; 2026.10.23 available. After `mise self-update`, run
  `mise bootstrap plan` (the watcher unit drifts on upgrades).
- `mise bootstrap plan`: 13 unchanged, 0 to do. `repos status`: both
  declared repos `current`. 2026-11-11: 12 unchanged (cloudflared
  service commented out); 5 repos declared, `~/skogai` and `~/skogix`
  `missing`.
- `mise dot status`: 54 entries, 174 files, up to date, published.
  2026-11-05: 176 files (checkpoint 950), after excluding
  `spotifast/milkdrop/**`; `bootstrap plan` still 13 unchanged.
- `mise doctor`: one problem, `claude` (aqua:anthropics/claude-code)
  missing from Omarchy's tools layer.

## walkthrough

A guided walk through mise's features across sessions: adopt, ignore, or
adopt in place of something else. Markers: `[ ]` not started, `[~]` in
progress, `[x]` decided, `[-]` skipped. At the start of a session, take
the `[~]` item (else the first `[ ]`), run `mise <command> --help`, go
through it with skogix, and record the outcome in the item's page.

The notes cite `tmp/mise-docs/...`, a clone of mise's docs that lived in
this repo's gitignored `tmp/`. It's gone; re-clone to follow them.

- [x] 1. `bootstrap`: `bootstrap.md`
- [~] 2. `dotfiles`: `dotfiles.md`, `dotfiles-upstream.md`
- [ ] 3. aliases and env vars: `shell-alias` (`ls`, `get`, `set`,
  `unset`), `set`/`unset` (`[env]`), `env`, `vars` (`ls`, `prompt`,
  `unset`), `tool-alias`. Question: does mise replace atuin's vars and
  aliases, complement them (per-project `[env]` vs global), or stay out?
- [~] 4. secrets: `secrets.md`
- [ ] 5. extras: `tasks`/`run`/`watch`, `daemons` (pitchfork; a
  `pitchfork.service` user unit exists), `oci`, `deps` (`[deps] npm`
  is set), `skills`, `generate`, maintenance (`lock`, `outdated`,
  `upgrade`, `prune`, `doctor`).

## open

- fish activates mise twice (`bootstrap.md` shell).
- `dev.mise.gptme-server` is an undeclared orphan (`bootstrap.md`
  systemd-units).
- `~/.skogai` and `/skogai` come back into `[bootstrap.repos]` once
  they're set up again.
- History rewrite for leaked files (`dotfiles.md`, history of fixes).
