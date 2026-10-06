# fish configuration
#
fish_hybrid_key_bindings

# disable greeting
set -g fish_greeting

# # bootstrap fisher (plugin manager) if not installed
if not functions -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher update
end
#
# environment
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx SKOGAI_CONFIG_DIR /home/skogix/skogai/config

# path
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.bun/bin

# direnv
if type -q direnv
    direnv hook fish | source
end

# fzf
if type -q fzf
    fzf --fish | source
end

if type -q herdr
    herdr completion fish | source
end

if type -q codex
    codex completion fish | source
end

fish_ssh_agent

function pbcopy
    fish_clipboard_copy
end

function pbpaste
    fish_clipboard_paste
end

function fishrc
    nvim /home/skogix/.config/fish/config.fish
end

abbr -a lg lazygit
abbr -a lsa ls -la .
abbr -a lzd lazydocker
abbr -a pc paperclipai
abbr -a vim nvim

# argc-completions
set -gx ARGC_COMPLETIONS_ROOT "/home/skogix/.local/src/argc-completions"
set -gx ARGC_COMPLETIONS_PATH "$ARGC_COMPLETIONS_ROOT/completions/linux:$ARGC_COMPLETIONS_ROOT/completions"
fish_add_path "$ARGC_COMPLETIONS_ROOT/bin"
# To add completions for only the specified command, modify next line e.g. set argc_scripts cargo git
set argc_scripts (ls -1 "$ARGC_COMPLETIONS_ROOT/completions/linux" "$ARGC_COMPLETIONS_ROOT/completions" | sed -n 's/\.sh$//p')
argc --argc-completions fish $argc_scripts | source

fish_add_path "/skogai/bin/"

# pnpm
set -gx PNPM_HOME '/home/skogix/.local/share/pnpm'
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end
