#!/usr/bin/env bash
# tests/test_bash_syntax.sh — bash -n smoke test on all scripts
# Run: bash tests/test_bash_syntax.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
FAIL=0
FAILED=()

# Use portable path display (macOS realpath has no --relative-to)
relative_path() {
  local p="$1"
  case "$p" in
    "$REPO_ROOT"/*) echo "${p#$REPO_ROOT/}" ;;
    *) echo "$p" ;;
  esac
}

echo "Testing bash syntax of scripts in $REPO_ROOT"

for f in "$REPO_ROOT/install.sh" \
         "$REPO_ROOT"/lib/*.sh \
         "$REPO_ROOT"/tests/*.sh; do
  [[ -f "$f" ]] || continue
  if bash -n "$f" 2>/dev/null; then
    PASS=$((PASS+1))
    echo "  ok  $(relative_path "$f")"
  else
    FAIL=$((FAIL+1))
    FAILED+=("$f")
    echo "  FAIL $(relative_path "$f"):"
    bash -n "$f" 2>&1 | head -3 | sed 's/^/      /'
  fi
done

# Brewfile TOML-ish syntax (not bash, skip)
# TOML validation
for f in "$REPO_ROOT/mise/config.toml"; do
  [[ -f "$f" ]] || continue
  if python3 -c "import tomllib; tomllib.load(open('$f','rb'))" 2>/dev/null; then
    PASS=$((PASS+1))
    echo "  ok  $(relative_path "$f") (TOML)"
  else
    FAIL=$((FAIL+1))
    echo "  FAIL $(relative_path "$f") (TOML)"
  fi
done

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
