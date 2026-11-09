#!/usr/bin/env bash
# Tests for machine/units: the skogai-health timer, service and notify unit.
set -u

# shellcheck source=tests/lib.sh
source "$(dirname "$0")/lib.sh"

units=$repo/machine/units

# has <name> <file> <line>...: each line appears verbatim in machine/units/<file>.
has() {
  local name=$1 file=$units/$2
  shift 2
  out=$(cat "$file" 2>&1)
  rc=0
  expect "$name" 0 "$@"
}

has "service: oneshot running bin/health" skogai-health.service \
  "Type=oneshot" "ExecStart=%h/.config/skogai/bin/health" \
  "OnFailure=skogai-health-notify.service" \
  "Environment=PATH=%h/.local/bin:%h/.local/share/mise/shims:/usr/local/bin:/usr/bin:/bin"

has "notify: critical desktop notification" skogai-health-notify.service \
  "Type=oneshot" \
  "ExecStart=/usr/bin/notify-send -u critical -a skogai-health \"skogai-health failed\" \
\"journalctl --user -u skogai-health -n 50\""

has "timer: hourly after startup, enabled by timers.target" skogai-health.timer \
  "OnStartupSec=10min" "OnUnitActiveSec=1h" "[Install]" "WantedBy=timers.target"

verify() {
  local need
  for need in "$(command -v systemd-analyze)" "$HOME/.config/skogai/bin/health" \
    /usr/bin/notify-send; do
    if [[ ! -x $need ]]; then
      echo "skip systemd-analyze verify: ${need:-systemd-analyze} not available"
      return
    fi
  done
  run systemd-analyze --user verify "$units"/skogai-health.service \
    "$units"/skogai-health-notify.service "$units"/skogai-health.timer
  expect "systemd-analyze verify accepts the units" 0
}

verify

exit $failures
