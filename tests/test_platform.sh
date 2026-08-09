#!/usr/bin/env bash
# tests/test_platform.sh — unit tests for lib/platform.sh
# Run: bash tests/test_platform.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Counter files (shared across subshells via /tmp)
COUNTER_DIR="$(mktemp -d)"
PASS_FILE="$COUNTER_DIR/pass"
FAIL_FILE="$COUNTER_DIR/fail"
FAILED_FILE="$COUNTER_DIR/failed"
: > "$PASS_FILE"
: > "$FAIL_FILE"
: > "$FAILED_FILE"
trap 'rm -rf "$COUNTER_DIR"' EXIT

pass() { echo "$1" >> "$PASS_FILE"; echo "  ok  $2"; }
fail() {
  echo "$1" >> "$FAIL_FILE"
  echo "$2: got '$3', expected '$4'" >> "$FAILED_FILE"
  echo "  FAIL $2 (got '$3', expected '$4')"
}
assert_eq() {
  local got="$1" expected="$2" name="$3"
  if [[ "$got" == "$expected" ]]; then
    pass "$got" "$name"
  else
    fail 1 "$name" "$got" "$expected"
  fi
}

# Helper: create a stub file that overrides `uname`
make_uname_stub() {
  local arch="$1" kernel="$2"
  local tmpfile
  tmpfile="$(mktemp)"
  cat > "$tmpfile" << EOF
uname() {
  case "\$1" in
    -m) echo "$arch" ;;
    -s) echo "$kernel" ;;
    *)  command uname "\$@" ;;
  esac
}
export -f uname
EOF
  echo "$tmpfile"
}

# ---------------------------------------------------------------------------
echo "TEST: detect_arch"
# ---------------------------------------------------------------------------
for arch in x86_64 amd64 aarch64 arm64 armv7l i386 unknown; do
  stub="$(make_uname_stub "$arch" Linux)"
  (
    source "$stub"
    cd "$REPO_ROOT"
    source lib/platform.sh >/dev/null 2>&1
    result="$(detect_arch)"
    case "$arch" in
      x86_64|amd64) expected="x86_64" ;;
      aarch64|arm64) expected="arm64" ;;
      armv7l|armv7) expected="armv7" ;;
      i386|i686) expected="i386" ;;
      *) expected="unknown" ;;
    esac
    assert_eq "$result" "$expected" "arch=$arch"
  )
  rm -f "$stub"
done

# ---------------------------------------------------------------------------
echo ""
echo "TEST: detect_os (Darwin)"
# ---------------------------------------------------------------------------
(
  stub="$(make_uname_stub arm64 Darwin)"
  source "$stub"
  cd "$REPO_ROOT"
  source lib/platform.sh >/dev/null 2>&1
  result="$(detect_os)"
  assert_eq "$result" "macos" "macOS arm64"
  rm -f "$stub"
)

# ---------------------------------------------------------------------------
echo ""
echo "TEST: detect_os (Linux with /etc/os-release)"
# ---------------------------------------------------------------------------
for id in debian ubuntu fedora arch alpine opensuse; do
  fake_etc="$(mktemp -d)"
  cat > "$fake_etc/os-release" <<EOF
ID=$id
NAME=test
EOF
  (
    stub="$(make_uname_stub x86_64 Linux)"
    source "$stub"
    export _TEST_OS_RELEASE_PATH="$fake_etc/os-release"
    cd "$REPO_ROOT"
    source lib/platform.sh >/dev/null 2>&1
    result="$(detect_os)"
    case "$id" in
      debian|ubuntu) expected="linux-debian" ;;
      fedora)        expected="linux-fedora" ;;
      arch)          expected="linux-arch"   ;;
      alpine)        expected="linux-alpine" ;;
      opensuse)      expected="linux-suse"   ;;
    esac
    assert_eq "$result" "$expected" "linux/$id"
    rm -f "$stub"
    rm -rf "$fake_etc"
  )
done

# ---------------------------------------------------------------------------
echo ""
echo "TEST: detect_pkg_manager (real env)"
# ---------------------------------------------------------------------------
cd "$REPO_ROOT"
(
  source lib/platform.sh >/dev/null 2>&1
  result="$(detect_pkg_manager)"
  case "$result" in
    brew|apt-get|dnf|yum|pacman|apk|zypper|none)
      pass "$result" "pkg manager: $result" ;;
    *)
      fail 1 "pkg manager" "$result" "(brew|apt-get|dnf|yum|pacman|apk|zypper|none)" ;;
  esac
)

# ---------------------------------------------------------------------------
echo ""
echo "TEST: mirror.sh flag parsing"
# ---------------------------------------------------------------------------
cd "$REPO_ROOT"
(
  source lib/mirror.sh --force 2>&1
  assert_eq "$USING_CHINA_MIRROR" "1" "--force"
)
(
  source lib/mirror.sh --off 2>&1
  assert_eq "$USING_CHINA_MIRROR" "0" "--off"
)

# ---------------------------------------------------------------------------
echo ""
echo "TEST: mirror.sh exports expected env vars (--force)"
# ---------------------------------------------------------------------------
(
  cd "$REPO_ROOT"
  source lib/mirror.sh --force
  for var in HOMEBREW_API_DOMAIN HOMEBREW_BOTTLE_DOMAIN PIP_INDEX_URL \
             npm_config_registry CARGO_REGISTRIES_CRATES_IO_INDEX GOPROXY \
             GH_DOWNLOAD_PROXY; do
    if [[ -n "${!var:-}" ]]; then
      pass "$var set" "$var = ${!var}"
    else
      fail 1 "$var empty" "${!var:-}" "<non-empty>"
    fi
  done
)

# ---------------------------------------------------------------------------
echo ""
echo "════════════════════════════════════════════════════════════"
PASS="$(wc -l < "$PASS_FILE" | tr -d ' ')"
FAIL="$(wc -l < "$FAIL_FILE" | tr -d ' ')"
echo "Results: $PASS passed, $FAIL failed"
echo "════════════════════════════════════════════════════════════"

if [[ "$FAIL" -gt 0 ]]; then
  echo ""
  echo "Failed tests:"
  while IFS= read -r line; do
    echo "  - $line"
  done < "$FAILED_FILE"
  exit 1
fi

exit 0