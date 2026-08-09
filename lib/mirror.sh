#!/usr/bin/env bash
# =============================================================================
# lib/mirror.sh — 国内镜像源配置 (大陆网络环境优化)
# =============================================================================
# 用法:
#   source lib/mirror.sh           # 自动检测 + 启用
#   source lib/mirror.sh --force   # 强制启用, 不检测
#   source lib/mirror.sh --off     # 禁用, 重置为默认
#
# 启用后会 export 以下变量供后续安装步骤使用:
#   HOMEBREW_API_DOMAIN, HOMEBREW_BOTTLE_DOMAIN, HOMEBREW_BREW_GIT_REMOTE
#   PIP_INDEX_URL
#   npm_config_registry (npm)
#   CARGO_REGISTRIES_CRATES_IO (cargo)
#   GOPROXY (go)
#   DOCKER_REGISTRY_MIRROR (podman/docker)
#
# 同时提供 apply_apt_mirror / apply_dnf_mirror / apply_pacman_mirror /
# apply_apk_mirror / apply_pnpm_mirror 函数供 install.sh 调用
# =============================================================================

[[ -n "${__MIRROR_SH_LOADED:-}" ]] && return 0
__MIRROR_SH_LOADED=1

: "${USE_CHINA_MIRROR:=auto}"

# 解析 flag
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) USE_CHINA_MIRROR=1 ;;
    --on)    USE_CHINA_MIRROR=1 ;;
    --off)   USE_CHINA_MIRROR=0 ;;
    --auto)  USE_CHINA_MIRROR=auto ;;
    *)       ;;
  esac
  shift
done

# -----------------------------------------------------------------------------
# 检测函数
# -----------------------------------------------------------------------------

# 短超时探测 github.com 是否可达 (2s 足够)
detect_restricted() {
  # 优先用 curl; 退化 wget; 退化 ping
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --max-time 2 -o /dev/null https://github.com 2>/dev/null
    return $?
  fi
  if command -v wget >/dev/null 2>&1; then
    wget -q --timeout=2 --spider https://github.com 2>/dev/null
    return $?
  fi
  # 无法判断: 假定受限
  return 1
}

should_use_mirror() {
  case "$USE_CHINA_MIRROR" in
    1|on|true|yes) return 0 ;;
    0|off|false|no) return 1 ;;
    auto)
      # 1. TZ 提示
      [[ -n "${TZ:-}" ]] && [[ "$TZ" == *"Shanghai"* || "$TZ" == *"Chongqing"* || "$TZ" == *"Hongkong"* ]] && return 0
      # 2. 语言/区域 (C.UTF-8 通常不带; zh_CN.* 是)
      case "${LANG:-}${LC_ALL:-}" in
        *zh_CN*|*zh_HK*|*zh_TW*) return 0 ;;
      esac
      # 3. 网络连通性
      if detect_restricted; then
        return 1
      fi
      return 0
      ;;
    *) return 1 ;;
  esac
}

# -----------------------------------------------------------------------------
# 镜像端点
# -----------------------------------------------------------------------------

export_mirrors() {
  # Homebrew
  export HOMEBREW_API_DOMAIN="${HOMEBREW_API_DOMAIN:-https://mirrors.ustc.edu.cn/homebrew-bottles/api}"
  export HOMEBREW_BOTTLE_DOMAIN="${HOMEBREW_BOTTLE_DOMAIN:-https://mirrors.ustc.edu.cn/homebrew-bottles}"
  export HOMEBREW_BREW_GIT_REMOTE="${HOMEBREW_BREW_GIT_REMOTE:-https://mirrors.ustc.edu.cn/brew.git}"

  # pip
  export PIP_INDEX_URL="${PIP_INDEX_URL:-https://pypi.tuna.tsinghua.edu.cn/simple}"

  # npm
  export npm_config_registry="${npm_config_registry:-https://registry.npmmirror.com}"

  # cargo
  export CARGO_REGISTRIES_CRATES_IO_INDEX="${CARGO_REGISTRIES_CRATES_IO_INDEX:-sparse+https://rsproxy.cn/index/}"
  export CARGO_NET_GIT_FETCH_WITH_CLI="${CARGO_NET_GIT_FETCH_WITH_CLI:-true}"

  # Go
  export GOPROXY="${GOPROXY:-https://goproxy.cn,direct}"

  # gh CLI 二进制下载代理
  export GH_DOWNLOAD_PROXY="${GH_DOWNLOAD_PROXY:-https://ghfast.top}"
}

# -----------------------------------------------------------------------------
# 系统包管理器镜像写入
# -----------------------------------------------------------------------------

apply_apt_mirror() {
  local distro="${1:-debian}"
  local codename
  codename="$(grep VERSION_CODENAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')"
  [[ -z "$codename" ]] && codename="bookworm"

  local mirror_host="mirrors.tuna.tsinghua.edu.cn"
  local base_url
  case "$distro" in
    debian)  base_url="https://$mirror_host/debian" ;;
    ubuntu)  base_url="https://$mirror_host/ubuntu" ;;
    *)       log_warn "apt 镜像: 未识别 $distro, 跳过"; return 0 ;;
  esac

  log_info "切换 apt 源到 $mirror_host ($distro $codename)..."
  sudo_run cp /etc/apt/sources.list "/etc/apt/sources.list.bak.$(date +%Y%m%d-%H%M%S)"

  cat <<EOF | sudo_run tee /etc/apt/sources.list >/dev/null
deb $base_url $codename main contrib non-free non-free-firmware
deb $base_url $codename-updates main contrib non-free non-free-firmware
deb $base_url $codename-backports main contrib non-free non-free-firmware
deb $base_url $codename-security main contrib non-free non-free-firmware
EOF

  pkg_update
}

apply_dnf_mirror() {
  log_info "切换 dnf 源到 mirrors.aliyun.com..."
  sudo_run mkdir -p /etc/yum.repos.d/backup
  sudo_run mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/ 2>/dev/null || true
  sudo_run dnf config-manager --add-repo https://mirrors.aliyun.com/fedora/releases/\$releasever/Everything/x86_64/os/ 2>/dev/null || \
    sudo_run curl -fsSL -o /etc/yum.repos.d/fedora.repo https://mirrors.aliyun.com/fedora/releases/\$releasever/Everything/x86_64/os/repo/repo.yaml 2>/dev/null || true
  sudo_run dnf clean all
  sudo_run dnf makecache --quiet
}

apply_pacman_mirror() {
  log_info "切换 pacman 源到 mirrors.tuna.tsinghua.edu.cn..."
  local ts; ts="$(date +%Y%m%d-%H%M%S)"
  sudo_run cp /etc/pacman.d/mirrorlist "/etc/pacman.d/mirrorlist.bak.$ts" 2>/dev/null || true
  cat <<'EOF' | sudo_run tee /etc/pacman.d/mirrorlist >/dev/null
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch
EOF
  sudo_run pacman -Sy --noconfirm --quiet
}

apply_apk_mirror() {
  log_info "切换 apk 源到 mirrors.aliyun.com..."
  local ts; ts="$(date +%Y%m%d-%H%M%S)"
  sudo_run cp /etc/apk/repositories "/etc/apk/repositories.bak.$ts" 2>/dev/null || true
  cat <<'EOF' | sudo_run tee /etc/apk/repositories >/dev/null
https://mirrors.aliyun.com/alpine/v3.19/main
https://mirrors.aliyun.com/alpine/v3.19/community
EOF
  sudo_run apk update --quiet
}

apply_pnpm_mirror() {
  if command -v pnpm >/dev/null 2>&1 || [[ -f "$HOME/.local/share/mise/installs/pnpm/"* ]]; then
    log_info "配置 pnpm 镜像..."
    pnpm config set registry https://registry.npmmirror.com 2>/dev/null || true
  fi
}

# -----------------------------------------------------------------------------
# 入口
# -----------------------------------------------------------------------------

if should_use_mirror; then
  export_mirrors
  export USING_CHINA_MIRROR=1
else
  export USING_CHINA_MIRROR=0
fi