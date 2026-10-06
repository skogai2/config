#!/usr/bin/env bash
# Create/check symlinks from install paths into this repo, as listed in links.txt.
#
#   ./link.sh          create missing links, report everything (same as "link")
#   ./link.sh link     create missing links, report everything
#   ./link.sh check    report only, change nothing
#
# Exits non-zero if anything is not in the expected state. Never overwrites a
# real file or directory: move it into the repo first, then re-run.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
manifest="$repo/links.txt"
mode="${1:-link}"
rc=0

case "$mode" in
  link|check) ;;
  *) echo "usage: $0 [link|check]" >&2; exit 2 ;;
esac

while read -r name target _; do
  [[ -z "$name" || "$name" == \#* ]] && continue

  src="$repo/$name"
  dst="${target/#\~/$HOME}"

  if [[ ! -e "$src" ]]; then
    echo "MISSING-SRC  $src"
    rc=1
  elif [[ -L "$dst" ]]; then
    if [[ "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
      echo "ok           $dst"
    else
      echo "WRONG-LINK   $dst -> $(readlink "$dst")"
      rc=1
    fi
  elif [[ -e "$dst" ]]; then
    echo "NOT-A-LINK   $dst (real file or dir; move it into the repo, then re-run)"
    rc=1
  elif [[ "$mode" == link ]]; then
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "linked       $dst -> $src"
  else
    echo "UNLINKED     $dst"
    rc=1
  fi
done < "$manifest"

exit "$rc"
