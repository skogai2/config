---
permalink: config/shell/zsh
type: reference
---

# zsh

zsh 5.9.2. Rebuilt 2026-11-23 as the basics: oh-my-zsh + mise + atuin
(skogix). Not the login shell (fish is); used by typing `zsh`.

## files

- `~/.zshenv`: only `export ZDOTDIR="$HOME/.config/zsh"`.
- `~/.config/zsh/.zshrc`: everything else. History in
  `$ZDOTDIR/.zsh_history`, omz cache and compdump in `~/.cache/oh-my-zsh/`.
- Both tracked by mise dotfiles (`~/.config/mise/conf.d/dotfiles-tracking.toml`),
  `.zsh_history` excluded.

## ~/.config/zsh/.zshrc, in order

1. oh-my-zsh from the AUR package `oh-my-zsh-git` (`/usr/share/oh-my-zsh`),
   declared as `aur:oh-my-zsh-git` in `[bootstrap].packages`. Stock
   `robbyrussell` theme, `plugins=(git)`. `DISABLE_AUTO_UPDATE`: yay
   updates it. `ZSH_CACHE_DIR` must be set, `/usr/share` isn't writable.
   omz brings the options, history settings, compinit and keybindings.
2. `mise activate zsh`, then `atuin init --disable-up-arrow
   --disable-ctrl-r zsh` (same flags as `~/.bashrc`: atuin records,
   omz's ctrl-r/up stay).

Startup ~185ms (`zsh -ic exit`, 2026-11-23).

## dropped 2026-11-23

The step-1 file (2026-11-14: hand-set options, `bindkey -v`, argc-completions,
`usage` completion, starship) is in the mise dotfiles history. Starship
skipped by skogix; argc/usage left out to keep it basic.

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
