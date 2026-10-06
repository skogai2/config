# rootless podman always wins; overrides any other DOCKER_HOST (skogai DECISIONS.md, 2026-09-25)
# set -gx DOCKER_HOST unix:///run/user/1000/podman/podman.sock
