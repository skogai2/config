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

# current file tree
.
├── AGENTS.md
├── atuin.md
├── containers.md
├── herdr.md
├── mappings.md
├── mise.md
├── PROJECT.md
├── scripts
├── secrets.md
├── SKOGAI.md
└── window-manager.md

# current xdg config


/home/skogix/.config
├── aether
│   ├── blueprints
│   ├── custom
│   ├── theme
│   └── themes
├── aichat
│   └── roles
├── alacritty
├── anthropic
│   ├── configs
│   └── credentials
├── argc
│   └── commands
├── astro
├── atuin
├── autostart
├── backpass
│   └── user
├── basic-memory
├── Bitwarden
│   ├── blob_storage
│   ├── Cache
│   ├── 'Code Cache'
│   ├── Crashpad
│   ├── Dictionaries
│   ├── 'Local Storage'
│   ├── Partitions
│   └── 'Shared Dictionary'
├── 'Bitwarden CLI'
├── BraveSoftware
│   ├── Brave-Browser
│   ├── Brave-Browser-Beta
│   ├── Brave-Browser-Nightly
│   ├── Brave-Origin
│   ├── Brave-Origin-Beta
│   └── Brave-Origin-Nightly
├── btop
│   └── themes
├── cactus
├── captains-deck-web
├── chromium
│   ├── ActorSafetyLists
│   ├── AmountExtractionHeuristicRegexes
│   ├── CaptchaProviders
│   ├── CertificateRevocation
│   ├── component_crx_cache
│   ├── 'Crash Reports'
│   ├── 'Crowd Deny'
│   ├── Default
│   ├── Dictionaries
│   ├── extensions_crx_cache
│   ├── FileTypePolicies
│   ├── FirstPartySetsPreloaded
│   ├── GPUPersistentCache
│   ├── 'Guest Profile'
│   ├── hyphen-data
│   ├── 'Local Traces'
│   ├── MEIPreload
│   ├── NativeMessagingHosts
│   ├── OnDeviceHeadSuggestModel
│   ├── OptGuideOnDeviceModel
│   ├── OptimizationGuideModelsManifest
│   ├── OptimizationHints
│   ├── OriginTrials
│   ├── PKIMetadata
│   ├── PrivacySandboxAttestationsPreloaded
│   ├── 'Safe Browsing'
│   ├── SafetyTips
│   ├── segmentation_platform
│   ├── SSLErrorAssistant
│   ├── 'Subresource Filter'
│   ├── 'System Profile'
│   ├── TrustTokenKeyCommitments
│   ├── WasmTtsEngine
│   ├── 'Webstore Downloads'
│   ├── WidevineCdm
│   └── ZxcvbnData
├── chromium-headless
│   └── scoped_dirryBJN2
├── Claude
│   ├── blob_storage
│   ├── Cache
│   ├── claude-code
│   ├── claude-code-sessions
│   ├── 'Code Cache'
│   ├── cowork-spawn-settings
│   ├── Crashpad
│   ├── DawnGraphiteCache
│   ├── DawnWebGPUCache
│   ├── Dictionaries
│   ├── git-shadow
│   ├── GPUCache
│   ├── GPUPersistentCache
│   ├── IndexedDB
│   ├── local-agent-mode-sessions
│   ├── 'Local Storage'
│   ├── logs
│   ├── Partitions
│   ├── sentry
│   ├── 'Session Storage'
│   ├── 'Shared Dictionary'
│   ├── terminal-shell-integration
│   └── WebStorage
├── Claude-3p
├── cloudflare
│   ├── cache
│   └── config
├── Codex
│   ├── ActorSafetyLists
│   ├── AmountExtractionHeuristicRegexes
│   ├── artifact-sessions
│   ├── BrowserMetrics
│   ├── CaptchaProviders
│   ├── CertificateRevocation
│   ├── component_crx_cache
│   ├── 'Crash Reports'
│   ├── 'Crowd Deny'
│   ├── Default
│   ├── DeferredBrowserMetrics
│   ├── Dictionaries
│   ├── executor-plugins
│   ├── extensions_crx_cache
│   ├── FileTypePolicies
│   ├── FirstPartySetsPreloaded
│   ├── GPUPersistentCache
│   ├── hyphen-data
│   ├── MEIPreload
│   ├── NativeMessagingHosts
│   ├── OnDeviceHeadSuggestModel
│   ├── OptimizationGuideModelsManifest
│   ├── OptimizationHints
│   ├── OriginTrials
│   ├── PKIMetadata
│   ├── PrivacySandboxAttestationsPreloaded
│   ├── 'Safe Browsing'
│   ├── SafetyTips
│   ├── segmentation_platform
│   ├── sentry
│   ├── SSLErrorAssistant
│   ├── storage-cache
│   ├── 'Subresource Filter'
│   ├── TrustTokenKeyCommitments
│   ├── WasmTtsEngine
│   ├── WidevineCdm
│   └── ZxcvbnData
├── containers
│   └── systemd
├── dconf
├── discordcanary
│   ├── 1.0.2033
│   ├── app-1.0.2033
│   ├── blob_storage
│   ├── Cache
│   ├── 'Code Cache'
│   ├── Crashpad
│   ├── DawnGraphiteCache
│   ├── DawnWebGPUCache
│   ├── Dictionaries
│   ├── discord_asset_cache
│   ├── download
│   ├── GPUCache
│   ├── 'Local Storage'
│   ├── logs
│   ├── module_data
│   ├── sentry
│   ├── 'Service Worker'
│   ├── 'Session Storage'
│   ├── 'Shared Dictionary'
│   └── WebStorage
├── ecc2
├── environment.d
├── fcitx
│   └── dbus
├── fcitx5
│   └── conf
├── fish
│   ├── completions
│   ├── conf.d
│   ├── functions
│   └── themes
├── fnox
├── fontconfig
├── foot
├── gh
├── ghostty
├── git
├── gita
├── go
│   └── telemetry
├── google-chrome
│   └── NativeMessagingHosts
├── google-chrome-beta
│   └── NativeMessagingHosts
├── google-chrome-for-testing
│   └── NativeMessagingHosts
├── google-chrome-unstable
│   └── NativeMessagingHosts
├── goose
│   └── skills
├── gptme
│   └── oauth
├── gtk-3.0
├── herdr
│   ├── plugins
│   ├── session-snapshots
│   └── sessions
├── Hermes
│   └── Crashpad
├── heroic
│   ├── blob_storage
│   ├── Cache
│   ├── 'Code Cache'
│   ├── Crashpad
│   ├── DawnGraphiteCache
│   ├── DawnWebGPUCache
│   ├── Dictionaries
│   ├── GamesConfig
│   ├── gog_store
│   ├── gogdlConfig
│   ├── GPUCache
│   ├── icons
│   ├── images-cache
│   ├── legendaryConfig
│   ├── 'Local Storage'
│   ├── nile_store
│   ├── Partitions
│   ├── 'Session Storage'
│   ├── 'Shared Dictionary'
│   ├── sideload_apps
│   ├── store
│   ├── store_cache
│   ├── tools
│   └── zoom_store
├── hunk
├── hype
├── hypr
├── hyprland-preview-share-picker
├── ibus
│   └── bus
├── imv
├── kitty
├── lazydocker
├── lazygit
├── menus
│   └── applications-merged
├── microsoft-edge
│   └── NativeMessagingHosts
├── microsoft-edge-dev
│   └── NativeMessagingHosts
├── mise
│   └── files
├── 'Moonlight Game Streaming Project'
├── mpv
├── nautilus
├── nextjs-nodejs
├── nvim
│   ├── lua
│   └── plugin
├── nvim.backup.20261023-184226
│   ├── lua
│   └── plugin
├── obsidian
│   ├── blob_storage
│   ├── Cache
│   ├── 'Code Cache'
│   ├── Crashpad
│   ├── DawnGraphiteCache
│   ├── DawnWebGPUCache
│   ├── Dictionaries
│   ├── GPUCache
│   ├── IndexedDB
│   ├── 'Local Storage'
│   ├── 'Session Storage'
│   ├── 'Shared Dictionary'
│   └── WebStorage
├── omarchy
│   ├── branding
│   ├── defaults
│   ├── extensions
│   ├── hooks
│   ├── plugins
│   ├── themed
│   └── themes
├── opencode
│   ├── herdr-opencode
│   ├── node_modules
│   └── plugins
├── openknowledge
├── opera
│   └── NativeMessagingHosts
├── pangolin
│   └── logs
├── procps
├── pulse
├── rtk
│   └── plugins
├── Signal
├── skogai
│   ├── scripts
│   └── tmp
├── Slack
│   ├── blob_storage
│   ├── Cache
│   ├── 'Code Cache'
│   ├── Crashpad
│   ├── DawnGraphiteCache
│   ├── DawnWebGPUCache
│   ├── Dictionaries
│   ├── GPUCache
│   ├── GPUPersistentCache
│   ├── IndexedDB
│   ├── 'Local Storage'
│   ├── logs
│   ├── sentry
│   ├── 'Service Worker'
│   ├── 'Session Storage'
│   ├── 'Shared Dictionary'
│   ├── storage
│   └── WebStorage
├── spotifast
│   └── themes
├── sunshine
│   └── credentials
├── systemd
│   └── user
├── tailscale
├── termix
├── tmux
├── treehouse
├── uv
├── uwsm
│   └── env.d
├── vivaldi
│   └── NativeMessagingHosts
├── voxtype
├── wireplumber
│   └── wireplumber.conf.d
├── worktrunk
├── xdg-desktop-portal
├── xournalpp
├── yay
└── zed
    ├── themes
    └── zed
