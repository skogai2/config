---
permalink: config/shell/zsh
type: reference
---

# zsh

zsh 5.9.2. Rebuilt from scratch 2026-11-14, step 1: one plain file, no
framework. Not the login shell (fish is); used by typing `zsh`.

## files

- `~/.zshenv`: only `export ZDOTDIR="$HOME/.config/zsh"`.
- `~/.config/zsh/.zshrc`: everything else. History in
  `$ZDOTDIR/.zsh_history`, compdump in `~/.cache/zsh/zcompdump`.
- Both tracked by mise dotfiles (`~/.config/mise/conf.d/dotfiles-tracking.toml`),
  `.zsh_history` excluded.

## ~/.config/zsh/.zshrc, in order

1. options, history, `bindkey -v` + `^X^E` edit-command-line: taken
   from the skogansible `roles/zsh` (deduplicated).
2. `compinit`, menu select, case-insensitive matching.
3. `mise activate zsh`, `usage g completion-init zsh`,
   `atuin init --disable-up-arrow --disable-ctrl-r zsh`.
4. argc-completions, same checkout as bash (`bash.md`): ~1000 commands.
   `mise` keeps its own `_mise` from `/usr/share/zsh/site-functions`.
5. `starship init zsh`: the same prompt as fish.

Startup ~90ms (`zsh -ic exit`, 2026-11-14).

## replaced (2026-11-14)

`~/.zshrc` used to `exec fish` for any interactive zsh not started from
fish (`NO_FISH=1` skipped it). Removed; a copy is in
`.skogai/tmp/zshrc.fish-handoff.bak` (untracked).

## old setups to take from

- `~/.local/src/skogansible-migration/roles/zsh/`: numbered `zsh.d/`
  dirs + `loader.zsh`, 45 `_completion` files (argc-completions covers
  most), `90-skogai` functions. The cleanest of the three.
- `~/.local/src/chezmoi/dot_zshrc*` (zinit, "crazy", skogix variants).
- `~/.local/src/dotfiles-migration1/dot-files-old/zsh*`: the old rcm
  repo (`SkogBackup/.dotfiles`), zsh + oh-my-zsh.

## next

- The agent tool shell is non-interactive zsh: it reads only
  `~/.zshenv`, so it still has no mise (handover). `mise activate zsh
  --shims` in `$ZDOTDIR/.zshenv` is the candidate.
- Split into a `zsh.d/` once the file grows (the skogansible loader).
