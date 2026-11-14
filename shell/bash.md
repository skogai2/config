---
permalink: config/shell/bash
type: reference
---

# bash

Not the login shell (that's fish, `/usr/bin/fish`); used by typing
`bash`. Set up 2026-11-14. `~/.bashrc`, `~/.bash_profile`,
`~/.bash_logout`, `~/.inputrc` (`conf.d/dotfiles-tracking.toml`) and
`~/.local/share/bash-completion/completions` (`config.toml`) are tracked
by mise dotfiles in place.

## ~/.bashrc, in load order

1. Omarchy's `env-bootstrap` (PATH, also for non-interactive shells),
   then `return` if not interactive.
2. `$OMARCHY_PATH/default/bash/rc`: Omarchy's aliases and functions.
   Its `init` runs `eval "$(mise activate bash)"`, so **mise is activated
   by Omarchy**, not by a line of ours.
3. `source <(usage g completion-init bash)`: Tab works on any script on
   PATH with a usage shebang, with nothing generated per script.
4. atuin: `gen-completion` and
   `atuin init --disable-up-arrow --disable-ctrl-r --bind-ai-resume bash`.
5. argc-completions (below).

`/etc/bash.bashrc` loads the `bash-completion` package (2.18).

## completion: what is used

| for | how |
|---|---|
| other people's tools (~1100) | argc-completions, checkout in `~/.local/src/argc-completions`, sourced from `~/.bashrc` |
| own scripts | usage shebang (`completion-init`), or argc |
| a CLI that prints a usage spec | `usage g completion bash <bin> --usage-cmd ... --install` |
| one-off files | `~/.local/share/bash-completion/completions/<cmd>`, loaded on first Tab; `mise` and `git-town` there now |

- `~/.bash_completion` is sourced in full at every start: keep it for
  global hooks only. It held a dead argcomplete line (a deleted
  `~/core/.venv`) and was removed 2026-11-14.
- mise only completes itself (`mise completion bash`); it installs no
  completions for other tools.
- `git town <Tab>` goes through git's completion (looks for `_git_town`),
  not the `git-town` file.

## tried and dropped (2026-11-14)

- **ble.sh** (AUR `blesh-git`): highlighting, autosuggestions, menu.
  Too noisy and ~0.2s lag per key, mostly `complete_auto_complete`
  running a completion (a `mise`/`usage` process) on every keystroke.
  If tried again, the off switches are `bleopt highlight_syntax=
  highlight_filename= highlight_variable= complete_auto_complete=
  complete_auto_history= complete_menu_filter= edit_bell=
  exec_errexit_mark= exec_elapsed_mark= prompt_eol_mark=
  keymap_vi_mode_show=` in `~/.blerc`.
- **carapace**: similar coverage to argc-completions, but its
  completions are Go and not editable by hand. Installed by mise
  (`carapace 1.8.2`, global config) but not sourced by any shell;
  `~/.config/carapace` excluded (`mise/coverage.md`).

## open

- `~/.inputrc`: vi mode is set; the completion options
  (`completion-ignore-case`, `show-all-if-ambiguous`) are commented out.
- `mise` and `usage` are also installed by pacman (`/usr/bin`); the
  standalone mise (`curl https://mise.run | sh`, to `~/.local/bin`) comes
  first, then `pacman -R` (handover).
