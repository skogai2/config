# config 3.1

The first step of 3.0 (see SKOGAI.md, history).

- **mise is the base.** `mise dotfiles` tracks `~/.config` in place and
  `mise bootstrap` declares machine state. skogai builds on top of them
  and replaces neither.
- **Paths, not symlinks.** Files are tracked where they live, by path
  rules (`mode = "track"`), instead of being linked in from a repo the
  way stow did it.
- **SKOGAI.md beside the dotfiles.** A tracked `~/.config/<app>/` that
  has skogai knowledge gets its own `SKOGAI.md`, versioned and synced
  with the app's config by mise history. Include-only dirs (fnox, herdr)
  need it added to their include list.
- **This repo is the main entry point, grouped by concern, then by
  tool.** For example `./secrets/{fnox,ssh,ssh-agent,mise}/`:
  `secrets/fnox/` holds most of the knowledge and tooling for fnox, and
  `secrets/mise/` the secret-specific part of mise (`mise secrets`).
- **`~/.config/skogai/SKOGAI.md` is the root router** for all skogai
  configuration.

Open: how `secrets/fnox/` here and `~/.config/fnox/SKOGAI.md` split the
work, which one holds the knowledge and which one only routes to it.

# preparations for 3.1

- !`eza --tree --git-ignore ~/.config/skogai` - files in the current repo which should be moved and managed in the new system 
- !`eza --tree --git-ignore --level 2 --only-dirs ~/.config` - the current xdg config file tree 
