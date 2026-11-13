---
permalink: config/desktop/nvim
type: reference
---

# nvim

LazyVim, as Omarchy ships it, plus local additions. Layout, conventions
and commands are in the repo's own `CLAUDE.md`; this page is how it fits
the machine.

## where it lives (2026-11-13)

- `~/.config/nvim` is its own git repo, `skogai/nvim-omarchy` (private),
  declared in `[bootstrap.repos]`. It is **not** tracked by `mise
  dotfiles` any more: a nested repo is excluded, not tracked
  (`mise/dotfiles.md`). History before 2026-11-13 is in the dotfiles
  history (`mise dot log` on `~/.config/nvim`).
- `lua/plugins/theme.lua` is Omarchy's symlink into
  `~/.local/state/omarchy/current/theme/neovim.lua`, gitignored in the
  repo. A fresh clone has none until `omarchy-theme-set` runs.
- `lazy-lock.json` is versioned: commit it after `:Lazy update`.

## gotchas

- Omarchy-shipped files (`all-themes.lua`, `omarchy-theme-hotreload.lua`,
  `lualine-transparent.lua`, `plugin/after/transparency.lua`, ...) can be
  overwritten by an Omarchy migration: check `git -C ~/.config/nvim
  status` after an Omarchy update.
- Not carried over from the old backup (`mise/coverage-triage.md`):
  `herdr-nvim.lua` and the `ai.claudecode` extra. Re-add by hand if
  wanted.
