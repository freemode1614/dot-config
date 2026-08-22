#!/usr/bin/env bash
# =============================================================================
# lib/pkg.sh — 跨发行版包安装与更新
# =============================================================================
# 调用方应先 source lib/platform.sh
#
# 提供:
#   - pkg_update: 刷新包索引
#   - pkg_install <pkg...>: 安装一个或多个包
#   - sudo_run: 用 sudo 包裹命令 (Debian 系需要; Arch/WSL 默认 root)
# =============================================================================

[[ -n "${__PKG_SH_LOADED:-}" ]] && return 0
__PKG_SH_LOADED=1

# 加载平台信息 (若未 source)
# shellcheck source=lib/platform.sh
source "$(dirname "${BASH_SOURCE[0]}")/platform.sh"

log_info()  { echo -e "\033[0;34m[INFO]\033[0m  $*"; }
log_warn()  { echo -e "\033[1;33m[WARN]\033[0m  $*"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $*" >&2; }
log_ok()    { echo -e "\033[0;32m[OK]\033[0m    $*"; }

# 是否需要 sudo (root / WSL 默认 Ubuntu/无密码 sudo 都不需要)
needs_sudo() {
  [[ $EUID -eq 0 ]] && return 1
  command -v sudo >/dev/null 2>&1
}

sudo_run() {
  if needs_sudo; then
    sudo "$@"
  else
    "$@"
  fi
}

pkg_update() {
  case "$PKG_MGR" in
    apt-get)
      sudo_run apt-get update -qq
      ;;
    dnf|yum)
      sudo_run "$PKG_MGR" -y -q check-update || true
      ;;
    pacman)
      sudo_run pacman -Sy --noconfirm --quiet
      ;;
    apk)
      sudo_run apk update --quiet
      ;;
    zypper)
      sudo_run zypper --quiet refresh
      ;;
    brew)
      brew update --quiet || true
      ;;
    *)
      log_warn "未识别的包管理器 ($PKG_MGR), 跳过 update"
      ;;
  esac
}

pkg_install() {
  if [[ $# -eq 0 ]]; then
    log_error "pkg_install: 缺少包名参数"
    return 1
  fi

  case "$PKG_MGR" in
    apt-get)
      sudo_run apt-get install -y --no-install-recommends "$@"
      ;;
    dnf|yum)
      sudo_run "$PKG_MGR" install -y "$@"
      ;;
    pacman)
      sudo_run pacman -S --needed --noconfirm --quiet "$@"
      ;;
    apk)
      sudo_run apk add --quiet "$@"
      ;;
    zypper)
      sudo_run zypper --non-interactive install --no-recommends "$@"
      ;;
    brew)
      brew install "$@"
      ;;
    *)
      log_error "不支持的包管理器: $PKG_MGR"
      return 1
      ;;
  esac
}

# 转换包名映射 (apt 名 vs 其他发行版名差异)
# 用法: pkg_install "$(pkg_map fd)" -> fd-find on Debian, fd on Fedora
pkg_map() {
  case "$1" in
    fd)
      case "$PKG_MGR" in
        apt-get) printf 'fd-find\n' ;;
        *)       printf 'fd\n'     ;;
      esac
      ;;
    eza)
      case "$PKG_MGR" in
        apt-get)
          # Debian 系额外源; 交给 caller 处理
          printf 'eza\n'
          ;;
        dnf|yum) printf 'eza\n' ;;
        pacman)  printf 'eza\n' ;;
        apk)     printf 'eza\n' ;;
        zypper)  printf 'eza\n' ;;
        brew)    printf 'eza\n' ;;
        *)       printf '%s\n' "$1" ;;
      esac
      ;;
    ripgrep) printf 'ripgrep\n' ;;
    bat)
      case "$PKG_MGR" in
        apt-get) printf 'bat\n' ;; # 较新 Debian 已是 bat, 旧版用 'bat' 也可
        *)       printf 'bat\n' ;;
      esac
      ;;
    *)
      printf '%s\n' "$1"
      ;;
  esac
}