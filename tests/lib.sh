# Shared helpers for tests/*.test.sh: source it, write cases, end with `exit $failures`.
# shellcheck shell=bash
# shellcheck disable=SC2034 # repo, out and rc are used by the sourcing test
repo="$(cd "$(dirname "$0")/.." && pwd)"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
failures=0
out="" rc=0

pass() { echo "ok   $1"; }
fail() {
  echo "FAIL $1"
  printf '%s\n' "$out" | sed 's/^/     | /'
  failures=1
}

# run <cmd...>: capture combined output and exit status into $out / $rc.
run() {
  rc=0
  out=$("$@" 2>&1) || rc=$?
}

# expect <name> <want-rc> <line>...: $rc matches and each line appears verbatim.
expect() {
  local name=$1 want=$2 line
  shift 2
  if [[ $rc != "$want" ]]; then
    fail "$name: exit $rc, want $want"
    return
  fi
  for line in "$@"; do
    if ! grep -qxF -- "$line" <<<"$out"; then
      fail "$name: missing line '$line'"
      return
    fi
  done
  pass "$name"
}

# refute <name> <text>: the output does not contain <text>.
refute() {
  if grep -qF -- "$2" <<<"$out"; then fail "$1: unexpected '$2'"; else pass "$1"; fi
}

# newroot: an empty fixture repo root.
newroot() {
  local dir
  dir=$(mktemp -d "$work/root.XXXX")
  echo "$dir"
}

# concern <root> <group> <body>: an executable <group>/health with <body>.
concern() {
  mkdir -p "$1/$2"
  printf '#!/usr/bin/env bash\n%s\n' "$3" >"$1/$2/health"
  chmod +x "$1/$2/health"
}

# stub <dir> <name> <body>: an executable stub command.
stub() {
  mkdir -p "$1"
  printf '#!/usr/bin/env bash\n%s\n' "$3" >"$1/$2"
  chmod +x "$1/$2"
}

# toolbox: a PATH dir with basic tools only (no mise, systemctl, atuin or herdr).
toolbox() {
  local dir=$work/toolbox t
  if [[ ! -d $dir ]]; then
    mkdir -p "$dir"
    for t in bash env sed grep awk cat sort head tail tr cut wc timeout dirname \
      basename find mktemp rm sleep printf stat cmp date id ls jq; do
      ln -s "$(command -v "$t")" "$dir/$t"
    done
  fi
  echo "$dir"
}

# verdict <name> <status>: pass when <status> is 0.
verdict() { if (($2 == 0)); then pass "$1"; else fail "$1"; fi; }
