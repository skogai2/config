---
permalink: config/mise/adopt
type: reference
---

# from `mise dot` to `mise bootstrap`: how a machine becomes this one

How the dotfile history (`dotfiles.md`) and declared machine state
(`bootstrap.md`) connect. Read from the mise source
(`~/.local/src/mise`, v2026.11.6-36) on 2026-11-11; the installed binary
is 2026.11.5, and nothing in this flow changed between the two. Citations
are `file:line` in that checkout.

## the short version

1. `mise bootstrap --adopt skogai2/.dotfiles` fetches the origin's history
   into mise's own store and writes every tracked file to its live path,
   `~/.config/mise/config.toml` included. Nothing is cloned to a worktree.
2. mise then **re-runs itself as a fresh process**, so the `[bootstrap.*]`,
   `[tools]` and `[dotfiles]` that just arrived apply in the same run.
3. That run goes through bootstrap's 9 steps. Its `dotfiles` step does
   nothing for `mode = "track"` entries; the history step already wrote
   them.
4. The watcher (`history-watch`) starts only because our config declares
   it as a service. From then on, edits are saved and published on their
   own.

## 1. adopt: fetch and apply the history

- `skogai2/.dotfiles` expands to `https://github.com/skogai2/.dotfiles.git`
  (`crates/mise-util/src/github_relay.rs:142-164`). `?ref=<branch>` picks
  a branch; it must exist on the remote.
- mise looks for the marker `.mise-history/format.toml` (`format = 1`) on
  the branch. Our origin has it, so it's a **setup repository**: it's
  fetched into `~/.local/state/mise/history/repo.git`, at
  `refs/remotes/origin/setup`, and never cloned
  (`crates/mise-system/src/history/sync/onboard.rs:5-6`). An unmarked repo
  would be `git clone`d straight into `~/.config/mise` instead.
- Files are written all or nothing. A live file that already exists and
  differs, with no common base, is a conflict (`NeedsAdoption`). Any
  conflict pauses the whole setup and **nothing is written or
  bootstrapped** (`sync/apply.rs:412-480`, `src/cli/bootstrap.rs:2827`).
  `--take-remote-all` takes the origin's version of each one and saves
  the old version first, so `mise dot undo` restores it. `--replace-history`
  is only for a machine that already has its own, unrelated history.
- After the files are written, `[history.origin]` (`url`, `branch`) goes
  into `config.local.toml` (`sync/origin.rs:372-401`). No mode is
  written; the default `history.sync = "sync"` applies, and our
  `config.toml` sets it explicitly anyway.
- **On this machine, re-running the adopt is refused**: the origin url
  here is stored without `.git`, and mise compares the urls as exact
  strings (`onboard.rs:225-236`). A fresh machine isn't affected.
- `config.local.toml` is never published: every `*.local.toml` is
  excluded as machine-local (`history/tracked.rs:30-48`). So on a new
  machine it's created by the adopt, not restored.

## 2. one run, not two

After onboarding, `run_child_bootstrap` re-executes mise with `--cd
~/.config/mise`, the config dir trusted and the adopt flags stripped
(`src/cli/bootstrap.rs:2947-3008`). The child loads config from scratch,
so the restored config applies in the same run. A second run is only
needed when the setup paused on conflicts.

## 3. bootstrap's steps, and what `dotfiles` does here

`mise bootstrap --help` lists the order; `--only` and `--skip` take these
part names:

1. `accounts`, `plugins`
2. `files` (`phase = "pre-packages"`), `packages`
3. other `files`, `services`, `firewall`, `compose`
4. `repos`, `dotfiles`
5. `mise-shell-activate`, `macos-defaults`, `macos-launchd-agents`
6. `linux-systemd-units`, `user`
7. `tools`
8. plugin `packages`, user `services` with `requires_tools = true`
9. `task`, `final-hook`

- **`dotfiles` never pulls, syncs or applies history.** For track entries
  it's a no-op apart from its hooks: "a tracked file is never written:
  history captures it as it is" (`crates/mise-system/src/files.rs:5838`).
  It only deploys symlink/copy/template entries (our atuin entry, see
  `dotfiles.md`).
- Every bootstrap run that writes takes a before and an after checkpoint
  of the tracked files (`OperationScope`, `src/cli/bootstrap.rs:2053`).
- `mise_shell_activate` writes the same static block into
  `fish/config.fish` on every machine. It's tracked, so the first write is
  checkpointed and published; since the text is identical everywhere it
  shouldn't conflict (read from the code, not tried).
- `repos` clones with no submodules unless the entry sets
  `submodules = true`. A dirty checkout or a mismatched origin fails the
  whole step before anything is cloned; `--skip-dirty` skips dirty ones,
  a mismatch has no override (`crates/mise-system/src/repos.rs:177-193`).

## 4. after: what the watcher saves and publishes

What gets saved: a path needs a track entry owning it, and must get past,
in order, the hard exclusions (mise's own state, cache and store dirs,
age identities), any `.git` component, the global `[history].exclude`
(last match wins, `!glob` re-includes), then the entry's own `exclude`
and `include` (`exclude` wins). See `history/tracked.rs:632-702`.

Two secret guards, both easy to get past:

| guard | when | what it matches |
|---|---|---|
| filename filter (`tracked.rs:30-43`) | before saving | file names only: `.netrc`, `*.age`, `*.key`, `*.pem`, `*.gpg`, `*.kdbx`, `id_*`, `*token*`, `*secret*`, `credentials*`, `oauth*`, and `hosts.yml`, `age.txt`, `github_tokens.toml` under the mise config dir. `*.example`/`.sample`/`.template` are exempt. An entry's `include` naming the file lifts it |
| content scan (`sync/secrets.rs`) | before publishing | GitHub/GitLab/OpenAI/AWS/Slack token shapes, `BEGIN … PRIVATE KEY`, and `name[_.-](key\|token\|secret\|password\|passwd) = <8+ chars>`. Runs on unpublished commits only, so a hit is already in local history |

Watcher timing (all `[settings.history]` keys):

| setting | default | what |
|---|---|---|
| `watch.debounce` | 2s | quiet time before a changed file is saved |
| `watch.max_interval` | 24h | cap on one file's backed-off save interval |
| `watch.reconcile` | 10m | full rescan |
| `sync_interval` | 5m | minimum gap between publishes |
| `fetch_interval` | 15m | how often it fetches |

- The "24h throttle on `mise/config.toml`" isn't special to that file.
  Any file that keeps changing right after each save doubles its own
  interval, up to `max_interval`, and resets after a quiet stretch
  (`history/watch/schedule.rs`). Fixes: find what rewrites the file, set
  `autosave = false` on that one entry and save by hand, or lower
  `max_interval`.
- In `sync` mode incoming changes are written automatically, all or
  nothing, after a protective checkpoint. A clash is a conflict and holds
  publishing until it's resolved (`mise dot conflicts`, `pull
  --take-remote`/`--keep-local`). Applying never runs `mise bootstrap`.

## machine variants

`variants = [{ os, profile, machine, default }]` on a track entry; the
most specific match wins, and a tie is invalid. A `machine` variant is
keyed by `[history] machine`, else a random name generated once into
`~/.local/state/mise/history/machine`, **not the hostname**. Set
`[history] machine` before the first machine variant (`hypr/monitors.lua`).

## upstream docs

In `~/.local/src/mise/docs/`: `bootstrap.md`, `bootstrap/setup.md`,
`bootstrap/from-repository.md`, `bootstrap/repos.md`, `dotfiles.md`,
`dotfiles/history.md`, `dotfiles/sync.md`, `dotfiles/reference.md`,
`dotfiles/encryption.md`. Where they're looser than the code:
`setup.md:234` says adopt starts the watcher (only if the config declares
it); `encryption.md:199` undersells the content scan; `sync.md:90` says
the origin's mode is written (`--adopt` writes none).

## open

- Not tried yet: the full run on a fresh container (PROJECT.md §1).
  Expect conflicts on files the base system already wrote (Omarchy's
  `hypr`, `fish`, ...): `--take-remote-all` is the likely answer, to be
  confirmed in that test.
- Does `skogai2/.dotfiles` still have `main` as its default branch, with
  the marker on it? Only the local store was checked.
