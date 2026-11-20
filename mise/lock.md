---
permalink: config/mise/lock
type: reference
---

# mise lock

Lockfiles (`mise.lock`): resolved version, URL, checksum and provenance
per tool and platform. Checked on mise 2026.11.7, 2026-11-20.

## decision (skogix, 2026-11-20)

- **No global lockfile** (`~/.config/mise/mise.lock`). `locked = false`,
  so nothing needs one, and Omarchy's tools follow `latest` with 4h
  auto-updates, which a lockfile would fight.
- **Project lockfiles yes**, committed with `mise.toml`: `~/Work`
  (skogai/monorepo) has one. Commit `.mise/locks/` with it: aube
  dependency locks for `npm:` tools live there and `mise.lock` points at
  them by path.
- `gh` follows `latest` in the monorepo too (PR skogai/monorepo#110), so
  it matches Omarchy's entry and the global config.

## why `mise lock --global` can't work here

`--global` writes two lockfiles: `~/.config/mise/mise.lock` and
`/etc/mise/mise.lock`. It writes all or nothing, so any failure leaves
neither. Three things fail, in the order you meet them:

1. **Platforms.** With no lockfile and no `lockfile_platforms`, a new
   lockfile targets 7 platforms (linux x64/arm64 ± musl, macos x64/arm64,
   windows-x64). Omarchy's `cursor-agent` (an `http:` alias in
   `/etc/mise/conf.d/omarchy.toml`) has no windows build: 403 on
   `downloads.cursor.com/.../windows/x64/...`. `lockfile_platforms =
   ["linux-x64"]` gets past it.
2. **npm trust policy.** aube's `trustPolicy=no-downgrade` rejects
   `npm:freebuff` (Omarchy's): provenance attestations stopped at 0.0.98,
   though CI is still the trusted publisher. `trust_policy_excludes =
   ["freebuff@<version>"]` in the user config only covers the user
   lockfile; the `/etc` pass uses Omarchy's own entry. Each new release
   (auto_update 4h) would need a new exclude.
3. **`/etc/mise` is root-owned.** Any tool Omarchy also declares (`gh`,
   `node`, `uv`, `npm:@moonshot-ai/kimi-code`, `npm:freebuff`), or one
   whose dependency it declares (npm and pipx tools pull in `node`/`uv`),
   sends mise to `/etc/mise/mise.lock`: `Permission denied (os error 13)`.

Naming tools (`mise lock --global jq`) restricts which lockfiles are
written: a tool only in the user config writes only the user lockfile.

## gotchas

- `lockfile_platforms` set globally also narrows project lockfiles: a
  configured value means "these plus the current platform" for every
  `mise lock` (from `mise lock --help`; whether `lockfile_auto_prune`
  then drops the other platforms is untested). Set it per project if
  needed, not globally.
- `mise lock` keeps the locked versions; `mise lock --bump [tool]`
  re-resolves `latest` and prefix requests. `mise lock tool@x.y.z`
  changes a pin and rewrites `mise.toml` to match.
- `--dry-run` doesn't resolve npm dependency graphs or write, so it
  passes where the real run fails on trust policy or permissions.
- pipx/pypi tools that need a source build (pyyaml has no wheel for
  Python 3.15: `pipx:gptme`, `ansible`, `ansible-core`, `awsebcli`) get a
  version-only entry with a WARN; not an error.
- `mise install` locks too (`lockfile_mode = "generate"`), and retries
  version-only entries every run: in `~/Work`, `mise i` prints uv's
  `pyyaml==6.0.3 ... --no-build` error for `code-review-graph` and still
  exits 0. Goes away when PyYAML ships cp315 wheels, or with `python =
  "3.14"` in the project.
