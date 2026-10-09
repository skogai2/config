# Containers: Docker → Podman

This is a living record of the container-runtime setup, updated directly as
the agreement changes — not derived from any single dotfiles file. It
documents a deliberate divergence from Omarchy's stock Docker setup, the same
way `window-manager.md` tracks divergence from Omarchy's default bindings.

## Why

Omarchy ships a full Docker environment by default: `docker`,
`docker-buildx`, `docker-compose`, `lazydocker`, `ufw-docker`, a `docker.socket`
enabled at boot, Docker-specific UFW rules, a `Super+Shift+D` TUI binding, a
Docker.desktop launcher, and menu entries — plus an opt-in (never used on this
machine) "Sudoless Docker" toggle that adds the user to the root-equivalent
`docker` group. Emil decided to move off Docker entirely in favor of Podman
(rootless by default, no always-on root daemon) rather than keep tuned the
sudoless-vs-sudo Docker tradeoff.

## What changes

- **Packages:** remove `docker`, `docker-compose`, `docker-buildx`,
  `ufw-docker`. Install `podman`, `podman-docker` (provides/conflicts with
  `docker` — this is what lets the `docker` command keep working, backed by
  Podman), `podman-compose`.
- **`lazydocker` stays installed.** It has no hard dependency on the `docker`
  package; it just shells out to `docker`/`docker-compose` at runtime, so it
  keeps working once those resolve to Podman via `podman-docker`.
- **No changes needed to:** `~/.config/hypr` (`Super+Shift+D` binding),
  Docker.desktop launcher, Omarchy menu entries, or the `d=docker` atuin
  alias — all of them call `docker`, which keeps working.
- **systemd:** disable/stop `docker.socket`. Podman doesn't need an
  always-on root daemon; `podman.socket` (user-level) is only needed if
  something specifically wants the Docker-compatible REST API, which nothing
  here does.
- **Firewall:** remove the Docker-specific UFW rules (`allow-docker-dns`
  entries for `172.17.0.1:53`) and the `ufw-docker` iptables hook in
  `/etc/ufw/after.rules`. Podman's rootless networking (pasta) doesn't route
  through a host bridge the way Docker's does, so these rules become dead
  weight, not a safety net.
- **Compose files:** two live stacks exist outside this repo —
  `~/tmp/docker-compose.yml` (termix + guacd; confirmed disposable, no data
  migration needed) and `~/claude/projects/gptme/docker-compose.yml`
  (gptme-server + computer-use). `docker compose` itself resolves to
  `podman-compose` as an "external compose provider" (podman's own
  mechanism), so the compose files and their documented `docker compose ...`
  commands work unchanged — no need to type `podman-compose` explicitly.

## Status

Executed 2026-10-07. What actually happened, in order:

1. `sudo systemctl disable --now docker.socket`.
2. `sudo pacman -S podman podman-docker podman-compose` — pacman detected the
   `podman-docker` ↔ `docker` conflict itself and removed `docker` as part of
   the same transaction (confirmed at the prompt, not a separate step).
3. `sudo pacman -Rns docker-compose docker-buildx ufw-docker`.
4. Also installed `podlet` (not originally planned) — generates systemd
   Quadlet units from a podman command/compose file/existing object, for
   later use if any of these stacks should move from compose to proper
   user-level systemd units.
5. Verified `docker version` reports "Podman Engine", and `docker compose
   version` invokes podman-compose via podman's external-provider
   mechanism (prints a one-time notice, silenced per step 6).
6. `atuin dotfiles var set PODMAN_COMPOSE_WARNING_LOGS false` — silences
   that "Executing external compose provider" notice on every invocation.
7. Firewall: removed the two `allow-docker-dns` UFW rules (`172.17.0.1:53`,
   for `172.16.0.0/12` and `192.168.0.0/16`) via `sudo ufw delete`. Found
   that `ufw-docker`'s package removal left its iptables hook orphaned in
   `/etc/ufw/after.rules` (package removal doesn't revert hand-injected file
   edits made by `ufw-docker install`) — a `# BEGIN UFW AND DOCKER` /
   `# END UFW AND DOCKER` block referencing the now-nonexistent `docker0`
   interface and `DOCKER-USER` chain. Backed up to
   `/etc/ufw/after.rules.bak-docker-removal` and stripped with `sed`, then
   `sudo ufw reload`.
8. Confirmed `lazydocker`, the `Super+Shift+D` Hyprland binding,
   Docker.desktop, and the Omarchy menu entries needed no changes — they all
   call `docker`, which is now Podman.

Confirmed clean: `grep -n "ufw-docker\|DOCKER-USER" /etc/ufw/after.rules`
after the strip + `ufw reload` prints nothing.

Outstanding: final confirmation that both compose stacks (`~/tmp`,
`~/claude/projects/gptme`) come up cleanly under `docker compose up`.
