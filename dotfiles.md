# dotfiles

How dotfiles change. mise's history of the tracked files (`[dotfiles]`
in `~/.config/mise/config.toml`) is shared through the origin
`github.com/skogai2/.dotfiles`, branch `main`. Background and test
results: `mise.md`, item 2.

## two ways to change a dotfile

- **live, on this machine:** edit the file in `~`. The watcher saves a
  checkpoint and syncs it. For anything you want right now.
- **upstream, in the origin:** clone the origin, commit, push. Every
  machine pulls it. For prepared changes, changes meant for several
  machines, and everything that is not a dotfile at all.

## the origin repo

```tree
.
├── home/           # tracked files, as paths under ~ (live on every machine)
├── config/         # ~/.config/mise: config.toml, files/ (live)
├── .mise-history/  # mise's own; never edit
├── .skogai/        # agent environment: helpers, notes, drafts (never live)
└── README.md       # route for whoever checks the repo out (never live)
```

Only `home/` and `config/` reach a machine. Everything else stays in
git: machines carry it along in their own commits but never write it to
disk (tested 2026-10-25). That makes the origin a workspace for agents:
helpers, drafts and notes about the dotfiles can sit next to them without
changing any machine.

A file under `home/` whose path isn't declared in `[dotfiles]` is also
not written, but don't park things there: declaring the path later makes
it live. Drafts belong in `.skogai/`.

## upstream workflow

1. `git clone https://github.com/skogai2/.dotfiles` (or `git pull` in an
   existing clone) right before starting. Keep it short-lived: the
   machines push often.
2. Change:
   - edit a live file: `home/<path under ~>`
   - add a new live file under an already tracked dir: just add it
   - make a new path live: add a `[dotfiles]` entry in
     `config/config.toml` in the same commit. Check its excludes for
     secrets and caches first.
   - agent environment, helpers, drafts: `.skogai/`
3. One concern per commit. The message becomes the checkpoint
   description on every machine, so write it for `mise dot history ls`.
4. `git pull --rebase`, then `git push`. Never force-push: mise refuses
   rewritten history.
5. On a machine: the watcher pulls on its own. To see it now:
   `mise dot sync && mise dot pull`. If `config/config.toml` changed, a
   newly declared path arrives on the following sync, and
   `mise bootstrap --dry-run` shows what the new declarations would do.

Promoting a draft from `.skogai/` to live is a move into `home/` plus,
for a new path, its `[dotfiles]` entry. That one commit is the moment it
starts affecting machines.

## when it goes wrong

- **conflict** (the same file changed on a machine and upstream): it's
  whole-file, with no line merge, and sharing pauses for every file.
  `mise dot conflicts` shows both sides, then
  `mise dot pull --take-remote <path>` or `--keep-local <path>`.
- **a bad change landed:** `mise dot undo` on the machine reverses the
  pull. Upstream, fix it with a new commit, not a reset.
- **never** commit secrets, in `home/` or `.skogai/`. History is shared
  and kept; mise's credential filter and secret check run in mise's own
  commands, and a plain `git push` skips both.
