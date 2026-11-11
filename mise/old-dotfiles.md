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

PROJECT.md §2: merge what's still wanted, then remove.

## done (2026-11-11)

- `aichat/roles/amys-blog.md`: live was a dangling link into the removed
  `~/.dotfiles`; restored from here (checkpoint 1467).
- Five other dangling tracked links removed: `aichat/functions` (to a
  gone `~/.local/src/tools`), `aichat/messages.md`,
  `aichat/roles/old/prompts`, `autostart/vesktop.desktop` (vesktop isn't
  installed), `autostart/com.anthropic.claude-desktop.desktop` (Claude
  already autostarts from `claude.desktop`). `dot-links` in `health`
  catches the next one.

## inventory (2026-11-11, compared against the live machine; no decisions)

- Missing live (85): `zshrc`, `zshenv`, `config/zsh/completions/*` (26),
  `i3/` (13), `sway/` (11), `sway-extras/` (7), `rofi`, `redshift`,
  `clipcat`, `rclone`, `dolt`, `claude-brain`, `serena`, `repomix`,
  `ruler`, `skillshare`, `workmux`, `zed/keymap.json`, `tmux/tmux.txt`,
  `autostart/{paseo,steam}.desktop`, `local/bin/*` (4),
  `bash_completions/skogcli.sh`, `skogix-dotfiles/{editorconfig,dircolors,xprofile}`.
- Differs from live (21): `basic-memory`, `aichat/config.yaml`,
  `autostart/bitwarden.desktop`, `cloudflare`, `fish/config.fish`, `gita/*`,
  `goose`, `gptme`, `kitty.conf`, `mimeapps.list`, `mise/config.toml`,
  `rtk`, `tmux.conf`, `user-dirs.dirs`, `worktrunk/*`, `zed/settings.json`,
  `inputrc`, `profile`, `zshenv`.
- Same as live (6): `aichat/models-override.yaml`,
  `autostart/claude-desktop.desktop`, `kitty/current-theme.conf`,
  `lazygit/config.yml`, `user-dirs.locale`, `worktrunk/approvals.toml.lock`.
- May hold tokens, look before copying: `rclone`, `dolt`, `claude-brain`,
  `serena`, `basic-memory`, `cloudflare`.

What to keep or bring back is skogix's call; nothing here is decided.

## the old repo's own notes

Its `SKOGAI.md` reviewed each file (2026-08-07). Still true: mise is the
one version manager (nvm, pyenv gone), activate mode, not shims, in
interactive shells. Out of date: it describes zsh + oh-my-zsh as the
shell; fish is now.
