---
permalink: config/tmux
type: reference
---

# tmux

Personal changes on top of Omarchy's shipped tmux config
(`~/.local/share/omarchy/config/tmux/tmux.conf`). Lives in
`~/.config/tmux/tmux.conf`. Anything not listed here is Omarchy's default.

Prefix is Omarchy's (`C-Space`).

## Changes from Omarchy defaults

| Keys                 | Omarchy default        | Personal                     |
|----------------------|------------------------|------------------------------|
| `prefix -` / `prefix \|` | —                  | Split stacked / side by side |
| `prefix h` / `prefix v`  | Split stacked / side by side | (freed; `h` is previous window) |
| `M-hjkl`             | —                      | Focus pane left/down/up/right |
| `C-M-arrows`         | Focus pane             | (unbound)                    |
| `M-HJKL`             | —                      | Resize pane left/down/up/right by 5 |
| `C-M-S-arrows`       | Resize pane            | (unbound)                    |
| `prefix h` / `prefix l` | —                   | Previous / next window       |

hjkl follows the same left/down/up/right convention as the window manager
(see @window-manager.md), so focus and resize use the same keys one layer
down, with Alt instead of Super.

## Keeping it

`omarchy-refresh-config tmux/tmux.conf` replaces the file with the stock
version. So did the 2026-10-25 04:00 reset of 22 Omarchy-shipped files (mise
checkpoint 569, cause not yet found); rolled back in checkpoint 583.
Check with:

```sh
diff ~/.local/share/omarchy/config/tmux/tmux.conf ~/.config/tmux/tmux.conf
```

The diff should show exactly the rows above. Anything less means a refresh
ran; restore from `mise dot history` (see @mise.md).
