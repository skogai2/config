---
permalink: config/mise/old-dotfiles
type: reference
---

# the old rcm repo: what's still worth having

The rcm-era dotfiles (`rcup -d ~/.dotfiles`), kept at
`~/.local/src/old-skogai/dotfiles` (origin `SkogBackup/.dotfiles`; it was
this repo's `.todo/dotfiles-old` submodule until 2026-11-11). 118 files
compared against the live machine on 2026-11-11: 85 missing live, 21
differ, 6 the same, 3 live paths were dangling links into it.

PROJECT.md §2: merge what's still wanted, then remove. This page is that
list.

## done (2026-11-11)

- `aichat/roles/amys-blog.md`: live was a dangling link into the removed
  `~/.dotfiles`; restored from here (checkpoint 1467).
- Five other dangling tracked links removed: `aichat/functions` (to a
  gone `~/.local/src/tools`), `aichat/messages.md`,
  `aichat/roles/old/prompts`, `autostart/vesktop.desktop` (vesktop isn't
  installed), `autostart/com.anthropic.claude-desktop.desktop` (Claude
  already autostarts from `claude.desktop`). `dot-links` in `health`
  catches the next one.

## worth bringing back (skogix's call)

| what | old path | why | how |
|---|---|---|---|
| zsh setup | `zshrc`, `zshenv`, `config/zsh/completions/*` (26) | there is no `~/.zshrc` today; agents' tool shell is zsh and has no mise on PATH (`herdr-binary` fails there) | not the old oh-my-zsh file: `[bootstrap.mise_shell_activate] zsh = true, zshenv = true` (shims in `~/.zshenv` for non-interactive agent shells, activation in `~/.zshrc`), plus `atuin init zsh`, `direnv hook zsh`, `wt config shell init zsh` from the old `zshrc`. Track `~/.zshenv`/`~/.zshrc` in place |
| `.editorconfig` | `skogix-dotfiles/editorconfig` | missing live; spaces, indent 2, tabs for Go/Makefile, md keeps trailing space | copy to `~/.editorconfig`, track |
| `.inputrc` | `skogix-dotfiles/inputrc` | live has 15 lines, old 35 (case-insensitive completion, show-all-if-ambiguous, history search on Up/Down) | merge into live, track |

## not coming back

- X11/sway era: `i3/` (13), `sway/` (11), `sway-extras/` (7), `rofi`,
  `redshift`, `clipcat`, `xprofile`, i3blocks scripts. Omarchy runs
  Hyprland; the keybindings were already ported (`hypr/bindings.lua`).
- rcm itself: `rcrc`, `local/bin/skogrc-*` (and `~/bin/skogrc-install-full`,
  the generated installer, which only points into the removed `~/.dotfiles`).
- `local/bin/skogai-edit`, `skogai-pager`: one-line nvim wrappers.
- Already live and newer: `mise`, `fish`, `tmux`, `kitty`, `zed`,
  `worktrunk`, `gita`, `aichat`, `gptme`, `goose`, `rtk`, `mimeapps.list`,
  `user-dirs.dirs`, `autostart/bitwarden.desktop`.
- Never copy without a look: `rclone/rclone.conf`, `dolt/`,
  `claude-brain/`, `serena/`, `basic-memory/`, `cloudflare/` may hold
  tokens.

## the old repo's own notes

Its `SKOGAI.md` reviewed each file (2026-08-07). Still true: mise is the
one version manager (nvm, pyenv gone), activate mode, not shims, in
interactive shells. Out of date: it describes zsh + oh-my-zsh as the
shell; fish is now.
