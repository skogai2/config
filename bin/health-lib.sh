# shellcheck shell=bash
# shellcheck disable=SC2034 # failed is read by the sourcing health script
# Helpers sourced by the <group>/health scripts; the contract is in bin/health.
# A script reports through `report`, then ends with `exit "$failed"`.

failed=0

# report <line>: print an `ok ...` / `FAIL ...` line; a FAIL marks the run failed.
report() {
  echo "$1"
  [[ $1 == FAIL* ]] && failed=1
  return 0
}

# need <check> <cmd>: true when <cmd> is on PATH, else reports it not found.
need() {
  command -v "$2" >/dev/null && return 0
  report "FAIL $1: $2 not found"
  return 1
}

# tilde <path>: <path> with a leading $HOME shown as ~.
tilde() {
  case $1 in
    "$HOME" | "$HOME"/*) printf '%s%s\n' '~' "${1#"$HOME"}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

# join <sep> <item>...: the items joined by <sep>.
join() {
  local sep=$1 out="" item
  shift
  for item in "$@"; do out+=${out:+$sep}$item; done
  printf '%s\n' "$out"
}

# stock_check <check> <path-under-~/.config> <page>: fails when the personal
# file is missing or byte-identical to Omarchy's stock copy (a refresh ran).
stock_check() {
  local name=$1 mine=$HOME/.config/$2
  local stock=${OMARCHY_CONFIG:-$HOME/.local/share/omarchy/config}/$2
  if [[ ! -f $mine ]]; then
    report "FAIL $name: $(tilde "$mine") not found"
  elif [[ ! -f $stock ]]; then
    report "ok $name: no Omarchy stock to compare"
  elif cmp -s "$mine" "$stock"; then
    report "FAIL $name: matches Omarchy stock, personal changes lost (see $3)"
  else
    report "ok $name"
  fi
}
