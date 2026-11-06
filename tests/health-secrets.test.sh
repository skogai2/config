#!/usr/bin/env bash
# Tests for secrets/health: ~/.ssh, age key and fnox config permissions.
set -u

# shellcheck source=tests/lib.sh
source "$(dirname "$0")/lib.sh"

me=$(id -un)

# secrets <home> [env...]: run secrets/health with a temp HOME.
secrets() {
  local home=$1
  shift
  run env HOME="$home" FNOX_CONFIG="$home/etc/skogai/fnox.toml" FNOX_CONFIG_OWNER="$me" "$@" \
    "$repo/secrets/health"
}

# newhome: a temp HOME with a 700 ~/.ssh and two 600 age keys.
newhome() {
  local h
  h=$(mktemp -d "$work/home.XXXX")
  mkdir -m 700 "$h/.ssh"
  touch "$h/.ssh/a-age.txt" "$h/.ssh/b-age.txt" "$h/.ssh/id_rsa"
  chmod 600 "$h/.ssh/a-age.txt" "$h/.ssh/b-age.txt"
  echo "$h"
}

# deploy <home> <file-mode> <dir-mode>: a fake fnox config under <home>/etc/skogai.
deploy() {
  mkdir -p "$1/etc/skogai"
  echo 'secret = "ciphertext"' >"$1/etc/skogai/fnox.toml"
  chmod "$2" "$1/etc/skogai/fnox.toml"
  chmod "$3" "$1/etc/skogai"
}

test_ok() {
  local h
  h=$(newhome)
  secrets "$h"
  expect "secrets: all ok, config not deployed" 0 \
    "ok ssh-dir" "ok age-keys: 2 keys" "ok fnox-config: not deployed"
  deploy "$h" 644 755
  secrets "$h"
  expect "secrets: deployed config ok" 0 "ok fnox-config"
  refute "secrets: config contents never printed" "ciphertext"
}

test_ssh() {
  local h
  h=$(mktemp -d "$work/home.XXXX")
  secrets "$h"
  expect "secrets: no ~/.ssh" 1 "FAIL ssh-dir: ~/.ssh not found" "ok age-keys: 0 keys"
  h=$(newhome)
  chmod 755 "$h/.ssh"
  chmod 644 "$h/.ssh/b-age.txt" "$h/.ssh/a-age.txt"
  secrets "$h"
  expect "secrets: open modes fail" 1 \
    "FAIL ssh-dir: ~/.ssh is 755 $me, want 700 $me" \
    "FAIL age-keys: a-age.txt 644 $me, b-age.txt 644 $me"
  refute "secrets: non-age files ignored" "id_rsa"
}

test_fnox() {
  local h
  h=$(newhome)
  deploy "$h" 644 775
  secrets "$h"
  expect "fnox: only the wrong dir is listed" 1 \
    "FAIL fnox-config: $h/etc/skogai is 775 $me, want 644/755 $me"
  deploy "$h" 664 775
  secrets "$h"
  expect "fnox: file and dir both listed" 1 \
    "FAIL fnox-config: $h/etc/skogai/fnox.toml is 664 $me; $h/etc/skogai is 775 $me, want 644/755 $me"
  deploy "$h" 644 755
  secrets "$h" FNOX_CONFIG_OWNER=root
  expect "fnox: wrong owner" 1 \
    "FAIL fnox-config: $h/etc/skogai/fnox.toml is 644 $me; $h/etc/skogai is 755 $me, want 644/755 root"
}

test_ok
test_ssh
test_fnox

exit $failures
