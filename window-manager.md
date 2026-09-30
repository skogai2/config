---
permalink: config/window-manager
type: reference
---

# Window manager

This is a living record of the window-manager conventions Emil and Claude
have agreed on, updated directly as that agreement changes. It is not
derived from, or synced against, any single dotfiles config — if a machine's
actual config drifts from this file, that's a prompt to reconcile the two in
conversation, not to treat the dotfiles as authoritative.

## Base layout

- Layout: `se` (Swedish), variant `us_dvorak`, option `caps:swapescape`
- Applies across machines — every binding below assumes physical `hjkl`
  sits wherever Dvorak puts those letters, not where US QWERTY would.

## Agreed scheme (i3-style)

Mod key is Super (Mod4).

| Keys                          | Action                                     |
|--------------------------------|---------------------------------------------|
| `Mod+Return`                   | Terminal                                    |
| `Mod+Shift+Return`             | Browser                                     |
| `Mod+d`                        | App launcher (drun-style)                   |
| `Mod+Shift+q`                  | Close focused window                        |
| `Mod+hjkl`                     | Focus left/down/up/right                    |
| `Mod+Shift+hjkl`               | Move/swap window left/down/up/right         |
| `Mod+v` / `Mod+b`              | Split vertical / horizontal                 |
| `Mod+t`                        | Cycle container layout                      |
| `Mod+f`                        | Fullscreen toggle                           |
| `Mod+Shift+Space`              | Floating toggle                             |
| `Mod+1..0`                     | Switch to workspace 1-10                    |
| `Mod+Shift+1..0`               | Move window to workspace 1-10               |
| `Mod+Ctrl+Left/Right`          | Previous/next workspace                     |
| `Mod+Ctrl+h/l`                 | Previous/next workspace (h/l mirror)        |
| `Mod+Shift+Ctrl+Left/Right`    | Move window to prev/next workspace, follow  |
| `Mod+s`                        | Toggle/show scratchpad                      |
| `Mod+Shift+s`                  | Move window to scratchpad                   |
| `Mod+grave`                    | Dropdown terminal                           |
| `Mod+r`                        | Resize mode (hjkl to shrink/grow)           |
| `Print`                        | Screenshot                                  |
| `Mod+Print`                    | Screenshot region → clipboard               |

## Per-machine implementations

### Hyprland (Omarchy)

Lives in `~/.config/hypr/bindings.lua` (personal overrides on top of
Omarchy's defaults — see that file's own comments for the full reasoning).
Ported as agreed above, except where an existing Omarchy default already
held the key — those got relocated rather than dropped:

- `Mod+K` (was: keybindings help) → moved to `F1`
- `Mod+L` (was: toggle workspace layout) → moved to `Mod+Alt+L`
- `Mod+v` for split — dropped; Omarchy uses it for universal paste. Only
  `Mod+b` (split) survived.
- `Mod+Shift+s` (scratchpad move) — dropped; Omarchy uses it for a Google
  Maps webapp shortcut. Scratchpad-move stays on Omarchy's default
  `Mod+Alt+s` instead.
- `Mod+t` (layout cycle), `Mod+Shift+Space` (floating toggle), `Mod+Print`
  (screenshot→clipboard), `Mod+p` (password manager) — not ported; each
  collided with an existing Omarchy binding, and Omarchy's own equivalent
  was kept instead (`Mod+t` = floating toggle, `Mod+Print` = color picker).
- Dropdown terminal (`Mod+grave`) maps to Omarchy's built-in "Herdr" floating
  terminal rather than a hand-rolled scratchpad window.
- `Mod+r` resize mode — not ported (no modal-resize primitive in this
  Hyprland Lua wrapper); Omarchy's discrete resize binds
  (`Mod+[Alt/Ctrl]+Minus/Equal`) are used instead.
- `Mod+m` (fzf app menu) and `Mod+Shift+n` (empty-workspace script) — not
  ported; they called scripts that don't exist on this machine.
- `Mod+Ctrl+h/l` — added as an h/l mirror of `Mod+Ctrl+Left/Right`
  (previous/next workspace), matching this config's left=h / right=l
  convention (focus, swap, above). Took over `Mod+Ctrl+h` (was: hardware
  menu) and `Mod+Ctrl+l` (was: lock screen); lock stays reachable via
  Omarchy's system menu (`Mod+Escape`).

### (future machines/WMs go here)

When setting up a new machine, diff its default WM bindings against the
agreed scheme above the same way the Hyprland section did, and record the
result here rather than assuming a clean slate.
