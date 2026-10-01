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
| `Mod+d`                        | App launcher (Apps menu)                    |
| `Mod+hjkl`                     | Focus left/down/up/right window or group    |
| `Mod+Shift+hjkl`               | Move window or group left/down/up/right     |
| `Mod+t`                        | Window-group toggle (stacking) — i3's split v/h and layout-cycle keys are folded into this one toggle; `Mod+v`/`Mod+b` are retired |
| `Mod+f`                        | Fullscreen toggle                           |
| `Mod+Shift+Space`              | Floating toggle                             |
| `Mod+1..0`                     | Switch to workspace 1-10                    |
| `Mod+Shift+1..0`               | Move window to workspace 1-10               |
| `Mod+Ctrl+Left/Right`          | Previous/next workspace                     |
| `Mod+Ctrl+h/l`                 | Previous/next workspace (h/l mirror)        |
| `Mod+Shift+Ctrl+Left/Right`    | Move window or group to prev/next workspace, follow |
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
- `Mod+L` (was: toggle workspace layout) → moved to `Mod+Alt+L`, where it
  still lives (dwindle ↔ scrolling workspace-layout toggle).
- `Mod+v` for split — never ported; Omarchy uses it for universal paste.
  `Mod+b` briefly carried a dwindle togglesplit binding, but as of
  2026-10-01 that's retired too (see the `Mod+t` entry below) — both keys
  are now free of i3-split meaning. `Mod+v` stays Omarchy's paste; `Mod+b`
  is unbound.
- `Mod+Shift+s` (scratchpad move) — dropped; Omarchy uses it for a Google
  Maps webapp shortcut. Scratchpad-move stays on Omarchy's default
  `Mod+Alt+s` instead.
- `Mod+Print` (screenshot→clipboard), `Mod+p` (password manager) — not
  ported; each collided with an existing Omarchy binding, and Omarchy's own
  equivalent was kept instead (`Mod+Print` = color picker, `Mod+p` =
  "pseudo window").
- `Mod+t` (2026-10-01, final): floating-toggle moved off `Mod+t` onto
  `Mod+Shift+Space` (displacing Omarchy's "Toggle top bar" — currently
  unbound, no key assigned; say the word if you want it back somewhere).
  `Mod+t` now toggles **window grouping** — Hyprland's actual equivalent of
  i3's "stacked" container mode: merges the focused window with a neighbor
  into one tile, shows one at a time, cycle with `Super+Alt+Tab`. (First
  attempt bound this to plain fullscreen instead — wrong, since fullscreen
  drops tiling context entirely rather than stacking within it; corrected
  same day.) `Super+G` keeps doing the identical action too — same action,
  two keys, left as a duplicate rather than removed. This also absorbs i3's
  split v/h concept, which is why `Mod+b`'s togglesplit binding got retired
  in the same pass — the grouping toggle replaces it.
- `Mod+Shift+hjkl` (2026-10-01, corrected): was bound to `hl.dsp.window.swap`
  with a "window or group" label that wasn't true — confirmed straight from
  Hyprland's source
  (`src/config/lua/bindings/LuaBindingsDispatchers.cpp`, `hlWindowSwap`)
  that `window.swap` only ever takes `direction`/`target`/`next`/`prev`;
  there's no group parameter on it at all, so no label change could have
  made it group-aware. `window.move`'s `direction` branch is the one that
  takes `group_aware` (confirmed in the same file, `hlWindowMove`), wired to
  the classic `movewindoworgroup` dispatcher: moves into a group if one
  exists in that direction, out of the active group if not, otherwise a
  plain move. Switched to `hl.dsp.window.move({ direction = ..., group_aware
  = true })` for real this time. `group:auto_group` (automatically group new
  windows) is a related Hyprland setting but was already the stock default
  (`true`) on this machine — nothing to change there.
- `Mod+hjkl` (focus, 2026-10-01): enabled `binds:movefocus_cycles_groupfirst`
  (in `looknfeel.lua`, not `bindings.lua` — it's a config value, not a key
  binding) so that focusing into a group steps through its windows one at a
  time before moving focus past it, instead of treating the group as a
  single tile (Hyprland's default). Confirmed via source
  (`src/config/shared/actions/ConfigActions.cpp::moveFocus`) that this is
  the only focus/group interaction Hyprland exposes — there's no
  `group_aware`-style parameter on the focus dispatcher itself. Verified live
  with `hyprctl getoption binds:movefocus_cycles_groupfirst` → `true, set:
  true`.
- `Mod+d` (2026-10-01): bound to Omarchy's "Apps menu" (fuzzy app launcher),
  matching i3's drun-style launcher muscle memory. `Mod+Alt+Space` ("Apps
  menu") still works too — same action, two keys.
- `Mod+Shift+q` (close window) — dropped (2026-10-01); redundant with
  Omarchy's native `Mod+w`, which already closes the focused window.
- Dropdown terminal (`Mod+grave`) maps to Omarchy's built-in "Herdr" floating
  terminal rather than a hand-rolled scratchpad window.
- `Mod+r` resize mode — not ported (no modal-resize primitive in this
  Hyprland Lua wrapper); Omarchy's discrete resize binds
  (`Mod+[Alt/Ctrl]+Minus/Equal`) are used instead.
- `Mod+m` (fzf app menu) — decided not to port (2026-09-30). Omarchy's own
  launchers (`Mod+Space` "Omarchy menu", `Mod+Alt+Space` "Apps menu") already
  cover fuzzy app launching.
- `Mod+Shift+n` (empty-workspace script) — decided not to port (2026-09-30).
  That key is Omarchy's "Editor" binding; kept as-is rather than relocating
  it for a script this machine doesn't have.
- `Mod+Ctrl+h/l` — added as an h/l mirror of `Mod+Ctrl+Left/Right`
  (previous/next workspace), matching this config's left=h / right=l
  convention (focus, swap, above). Took over `Mod+Ctrl+h` (was: hardware
  menu) and `Mod+Ctrl+l` (was: lock screen); lock stays reachable via
  Omarchy's system menu (`Mod+Escape`).

### (future machines/WMs go here)

When setting up a new machine, diff its default WM bindings against the
agreed scheme above the same way the Hyprland section did, and record the
result here rather than assuming a clean slate.
