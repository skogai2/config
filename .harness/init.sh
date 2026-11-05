#!/bin/bash
# Harness init.sh for skogai-config (stack: markdown docs + shell checks)
# Usage: .harness/init.sh [smoke_test|full_test|focused_test <test_file>]
# Default: full_test
#
# smoke_test   — bash syntax check of bin/* and tests/*.sh (<15s).
# focused_test — run exactly one test file. Exit 0 means it ran and passed;
#                exit 3 means skipped (file missing); a test's own exit 3 is
#                remapped to 1 so it can't pass as a skip.
# full_test    — every tests/*.test.sh, then bin/check-routes on this repo.
#                No coverage metric: the checks are the coverage.

set -e

TARGET=${1:-full_test}
FOCUS_FILE="${2:-}"

if [ "$TARGET" = "focused_test" ] && [ -z "$FOCUS_FILE" ]; then
    echo "focused_test requires a test file argument" >&2
    exit 2
fi

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== Harness ${TARGET} ==="
echo "Project: $PROJECT_ROOT"
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

shell_files() {
    find bin tests -type f \( -path 'bin/*' -o -name '*.sh' \) 2>/dev/null | sort
}

case "$TARGET" in
    smoke_test)
        echo "--- Shell Syntax Check ---"
        for f in $(shell_files); do
            bash -n "$f"
        done
        echo "Syntax check complete."
        ;;
    focused_test)
        if [ ! -f "$FOCUS_FILE" ]; then
            echo "focused_test: test file '$FOCUS_FILE' does not exist -- skipped (exit 3)."
            exit 3
        fi
        echo "--- Focused Test ($FOCUS_FILE) ---"
        rc=0
        bash "$FOCUS_FILE" || rc=$?
        if [ "$rc" -eq 3 ]; then
            rc=1
        fi
        [ "$rc" -eq 0 ] || exit "$rc"
        ;;
    full_test)
        echo "--- Tests ---"
        for t in tests/*.test.sh; do
            [ -e "$t" ] || continue
            echo "# $t"
            bash "$t"
        done
        echo ""
        echo "--- Routes ---"
        bin/check-routes "$PROJECT_ROOT"
        echo "All routes resolve."
        ;;
    *)
        echo "unknown target: $TARGET" >&2
        exit 2
        ;;
esac

echo ""
echo "=== ${TARGET} Complete ==="
