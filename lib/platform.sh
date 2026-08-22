#!/usr/bin/env bash
# =============================================================================
# lib/platform.sh — 跨平台检测与分发
# =============================================================================
# 提供:
#   - detect_os(): 输出标准化 OS id
#   - detect_arch(): 输出标准化 arch id
#   - detect_pkg_manager(): 输出系统包管理器
#   - is_wsl: 0/1
#   - os_id, arch_id, pkg_mgr 三个环境变量, source 即生效
# =============================================================================

# 防止重复 source
[[ -n "${__PLATFORM_SH_LOADED:-}" ]] && return 0
__PLATFORM_SH_LOADED=1

# 防止 set -u 下可能未绑定的报错
: "${OS:=unknown}"
: "${ARCH:=unknown}"
: "${PKG_MGR:=none}"
: "${IS_WSL:=0}"

detect_os() {
  local kernel
  kernel="$(uname -s 2>/dev/null || echo unknown)"
  case "$kernel" in
    Darwin)
      printf 'macos\n'
      return 0
      ;;
    Linux)
      # WSL: /proc/sys/kernel/osrelease 含 "microsoft" 或 "WSL"
      # 可通过 _TEST_OS_RELEASE_PATH override 单元测试
      local osrel="${_TEST_OS_RELEASE_PATH:-/etc/os-release}"
      if [[ -r /proc/sys/kernel/osrelease ]] && \
         grep -Eqi 'microsoft|wsl' /proc/sys/kernel/osrelease 2>/dev/null; then
        printf 'wsl\n'
        return 0
      fi

      # 优先读取 os-release (systemd 标准)
      if [[ -r "$osrel" ]]; then
        # shellcheck disable=SC1090
        . "$osrel"
        case "${ID:-}" in
          ubuntu|debian|linuxmint|pop|elementary|zorin) printf 'linux-debian\n'; return 0 ;;
          fedora|rhel|centos|rocky|almalinux|nobara)    printf 'linux-fedora\n'; return 0 ;;
          arch|manjaro|endeavouros|garuda)               printf 'linux-arch\n';   return 0 ;;
          alpine)                                         printf 'linux-alpine\n'; return 0 ;;
          opensuse|sles)                                  printf 'linux-suse\n';   return 0 ;;
          *)
            # 退化: alpine 仍可通过 /etc/alpine-release 识别
            [[ -r /etc/alpine-release ]] && { printf 'linux-alpine\n'; return 0; }
            printf 'linux-unknown\n'
            return 0
            ;;
        esac
      fi

      printf 'linux-unknown\n'
      return 0
      ;;
    FreeBSD|OpenBSD|NetBSD)
      printf 'bsd\n'
      return 0
      ;;
    MINGW*|MSYS*|CYGWIN*)
      printf 'windows-shell\n'
      return 0
      ;;
    *)
      printf 'unsupported\n'
      return 1
      ;;
  esac
}

detect_arch() {
  case "$(uname -m 2>/dev/null || echo unknown)" in
    x86_64|amd64)  printf 'x86_64\n' ;;
    aarch64|arm64) printf 'arm64\n'   ;;
    armv7l|armv7)  printf 'armv7\n'   ;;
    i386|i686)     printf 'i386\n'    ;;
    *)             printf 'unknown\n' ;;
  esac
}

detect_pkg_manager() {
  for m in apt-get dnf yum pacman apk zypper brew; do
    if command -v "$m" >/dev/null 2>&1; then
      printf '%s\n' "$m"
      return 0
    fi
  done
  printf 'none\n'
  return 1
}

is_wsl() {
  [[ "$(detect_os)" == "wsl" ]]
}

# 一次性填充变量
OS="$(detect_os)"
ARCH="$(detect_arch)"
PKG_MGR="$(detect_pkg_manager)"
[[ "$OS" == "wsl" ]] && IS_WSL=1
export OS ARCH PKG_MGR IS_WSL