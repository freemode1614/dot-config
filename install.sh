#!/usr/bin/env bash
# =============================================================================
# Dotfiles 初始化脚本 (重构版 v2)
# =============================================================================
# 技术栈: zsh + sheldon + starship + mise
# 跨平台: macOS / Debian / Fedora / Arch / Alpine / openSUSE / WSL
# 场景: 0→1 (全新), 0.5→1 (补全), 1→1 (更新)
# 运行: ./install.sh [--yes] [--no-symlinks]
# =============================================================================

set -Eeuo pipefail

# --------------------------------------------
# 路径
# --------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/freemode1614/dot-config.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"

# --------------------------------------------
# 颜色
# --------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_step() {
  echo
  echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}  $*${NC}"
  echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
}

# ERR trap — 失败时打印上下文
trap 'rc=$?; log_error "命令失败 (exit=$rc) 在第 ${LINENO} 行: ${BASH_COMMAND}"' ERR

# --------------------------------------------
# Flags
# --------------------------------------------
ASSUME_YES=0
SKIP_SYMLINKS=0
for arg in "$@"; do
  case "$arg" in
    --yes|-y)        ASSUME_YES=1 ;;
    --no-symlinks)   SKIP_SYMLINKS=1 ;;
    -h|--help)
      cat <<EOF
用法: ./install.sh [--yes] [--no-symlinks]

  --yes          非交互 (适合 CI/SSH/curl | bash)
  --no-symlinks  跳过 symlink 创建 (交给各 app 默认 XDG_CONFIG_HOME)
EOF
      exit 0
      ;;
    *) log_warn "未知参数: $arg" ;;
  esac
done

# --------------------------------------------
# 加载 lib
# --------------------------------------------
# shellcheck source=lib/platform.sh
source "$LIB_DIR/platform.sh"
# shellcheck source=lib/pkg.sh
source "$LIB_DIR/pkg.sh"

# --------------------------------------------
# Phase 1: 环境检测
# --------------------------------------------
detect_installation_scenario() {
  if [[ -d "$CONFIG_DIR/.git" ]]; then
    printf '1→1\n'
  elif [[ -d "$CONFIG_DIR" ]] && [[ "$(ls -A "$CONFIG_DIR" 2>/dev/null)" ]]; then
    printf '0.5→1\n'
  else
    printf '0→1\n'
  fi
}

SCENARIO="$(detect_installation_scenario)"

if [[ "$OS" == "unsupported" ]]; then
  log_error "不支持的操作系统: $(uname -s)"
  exit 1
fi

if [[ "$OS" == "windows-shell" ]]; then
  log_error "不支持的 Windows shell 环境。"
  log_error "在 Windows 上请使用 WSL (Windows Subsystem for Linux)。"
  exit 1
fi

log_step "🚀 开始初始化 dotfiles"
echo "  操作系统: $OS"
echo "  架构:     $ARCH"
echo "  包管理器: $PKG_MGR"
[[ "$IS_WSL" == "1" ]] && echo "  WSL:      是"
echo "  安装场景: $SCENARIO"

# --------------------------------------------
# Phase 2: 包管理器
# --------------------------------------------
ensure_package_manager() {
  log_step "📦 准备包管理器"

  case "$OS" in
    macos)
      if command -v brew >/dev/null 2>&1; then
        log_ok "Homebrew 已安装"
      else
        log_info "安装 Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        log_ok "Homebrew 安装完成"
      fi
      # 写入 ~/.zprofile (幂等)
      if [[ "$(uname -m)" == "arm64" ]]; then
        BREW_BIN="/opt/homebrew/bin/brew"
      else
        BREW_BIN="/usr/local/bin/brew"
      fi
      if [[ -x "$BREW_BIN" ]] && ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
        printf '\n# Homebrew\neval "$(%s shellenv)"\n' "$BREW_BIN" >> "$HOME/.zprofile"
      fi
      # 当前会话可用
      eval "$("$BREW_BIN" shellenv)"
      ;;
    wsl)
      log_info "WSL: 使用 Linux 分支 (Debian/Ubuntu 默认)"
      sudo_run apt-get update -qq
      ;;
    linux-debian)
      pkg_update
      ;;
    linux-fedora)
      pkg_update
      ;;
    linux-arch)
      pkg_update
      ;;
    linux-alpine)
      pkg_update
      ;;
    linux-suse)
      pkg_update
      ;;
    *)
      log_warn "$OS 上未声明包管理器初始化, 假设系统已就绪"
      ;;
  esac
}

# --------------------------------------------
# Phase 3: 基础工具
# --------------------------------------------
install_base_tools() {
  log_step "🔧 安装基础工具"

  case "$OS" in
    macos)
      if ! xcode-select -p >/dev/null 2>&1; then
        log_info "安装 Xcode Command Line Tools (可能弹 GUI)..."
        xcode-select --install || log_warn "跳过 CLT 安装"
      fi
      if [[ -f "$CONFIG_DIR/Brewfile" ]]; then
        log_info "应用 Brewfile..."
        brew bundle --no-upgrade --file="$CONFIG_DIR/Brewfile"
      else
        brew install --quiet git curl wget fzf ripgrep fd jq tree unzip starship eza bat
      fi
      ;;
    wsl)
      sudo_run apt-get install -y --no-install-recommends \
        git curl wget build-essential fzf ripgrep fd-find jq tree unzip ca-certificates
      install_starship_binary
      install_eza_binary
      ;;
    linux-debian)
      sudo_run apt-get install -y --no-install-recommends \
        git curl wget build-essential fzf ripgrep fd-find jq tree unzip ca-certificates fuse3
      install_starship_binary
      install_eza_debian_repo
      ;;
    linux-fedora)
      sudo_run dnf install -y \
        git curl wget @development-tools fzf ripgrep fd-find jq tree unzip \
        starship eza bat fuse
      ;;
    linux-arch)
      sudo_run pacman -S --needed --noconfirm --quiet \
        git curl wget base-devel fzf ripgrep fd jq tree unzip starship eza bat fuse2
      ;;
    linux-alpine)
      sudo_run apk add --quiet \
        git curl wget build-base fzf ripgrep fd jq tree unzip starship bash fuse3
      ;;
    linux-suse)
      sudo_run zypper --non-interactive install --no-recommends \
        git curl wget gcc make fzf ripgrep fd jq tree unzip
      install_starship_binary
      ;;
    *)
      log_warn "$OS 跳过基础工具安装, 请手动安装 git/curl/fzf/ripgrep/fd/jq/tree/unzip"
      ;;
  esac

  log_ok "基础工具安装完成"
}

install_starship_binary() {
  if command -v starship >/dev/null 2>&1; then return 0; fi
  log_info "安装 Starship (二进制)..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
}

install_eza_binary() {
  if command -v eza >/dev/null 2>&1; then return 0; fi
  log_info "安装 eza (GitHub release)..."
  local ver
  ver="$(curl -fsSL https://api.github.com/repos/eza-community/eza/releases/latest \
        | grep -Po '"tag_name": "\K[^"]*')"
  local tarball="eza_${ver//v/}_linux_${ARCH}.tar.gz"
  local url="https://github.com/eza-community/eza/releases/download/${ver}/${tarball}"
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/eza.tgz" "$url"
  tar -xzf "$tmp/eza.tgz" -C "$tmp"
  sudo_run install -m 0755 "$tmp"/eza /usr/local/bin/eza
  rm -rf "$tmp"
}

install_eza_debian_repo() {
  if command -v eza >/dev/null 2>&1; then return 0; fi
  log_info "安装 eza (gierens.de 源)..."
  sudo_run install -d -m 0755 /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo_run gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo_run tee /etc/apt/sources.list.d/gierens.list >/dev/null
  sudo_run chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  pkg_update
  pkg_install eza
}

# --------------------------------------------
# Phase 4: Mise
# --------------------------------------------
install_mise() {
  log_step "🔨 安装 Mise"

  if ! command -v mise >/dev/null 2>&1; then
    log_info "安装 Mise..."
    curl -fsSL https://mise.run | sh
  fi
  export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
  export MISE_SHELL=zsh

  if [[ -f "$CONFIG_DIR/mise/config.toml" ]]; then
    log_info "安装开发工具 (node, bun, pnpm, yarn, biome)..."
    (cd "$CONFIG_DIR" && mise install || true)
  fi

  log_ok "Mise 安装完成"
}

# --------------------------------------------
# Phase 5: Sheldon
# --------------------------------------------
install_sheldon() {
  log_step "🐚 安装 Sheldon"

  if ! command -v sheldon >/dev/null 2>&1; then
    log_info "安装 Sheldon..."
    curl -fsSL https://rossmacarthur.github.io/install.sh | sh -s -- repo sheldon-org/sheldon
  fi

  if [[ -f "$CONFIG_DIR/sheldon/plugins.toml" ]]; then
    log_info "应用 Sheldon 插件配置..."
    (cd "$CONFIG_DIR" && sheldon lock --update) || log_warn "sheldon lock 失败 (可忽略)"
    log_ok "Sheldon 插件安装完成"
  fi
}

# --------------------------------------------
# Phase 6: Dotfiles 仓库
# --------------------------------------------
setup_dotfiles() {
  log_step "📁 设置 Dotfiles 仓库"

  case "$SCENARIO" in
    0→1)
      log_info "克隆 dotfiles 仓库..."
      git clone --depth 1 -b "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$CONFIG_DIR"
      log_ok "Dotfiles 克隆完成"
      ;;
    0.5→1)
      if [[ "$ASSUME_YES" -eq 1 ]]; then
        local ans="y"
      else
        read -r -p "当前 $CONFIG_DIR 非 git 仓库, 是否备份并替换? [y/N] " ans < /dev/tty || ans="n"
      fi
      if [[ ! "$ans" =~ ^[Yy]$ ]]; then
        log_info "已取消, 保留现有 $CONFIG_DIR"
        exit 0
      fi
      local backup="$HOME/.config_backup_$(date +%Y%m%d-%H%M%S)"
      log_warn "备份现有配置 -> $backup"
      mv "$CONFIG_DIR" "$backup"
      git clone --depth 1 -b "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$CONFIG_DIR"
      log_ok "Dotfiles 初始化完成"
      ;;
    1→1)
      log_info "更新 dotfiles 仓库..."
      (cd "$CONFIG_DIR" && git pull --autostash --rebase --depth 20 origin "$DOTFILES_BRANCH") || \
        log_warn "git pull 失败 (可手动处理)"
      log_ok "Dotfiles 更新完成"
      ;;
  esac
}

# --------------------------------------------
# Phase 7: Neovim & WezTerm
# --------------------------------------------
install_editors() {
  log_step "📝 安装编辑器"

  case "$OS" in
    macos)
      brew install --cask neovim wezterm
      ;;
    *)
      install_neovim_linux
      install_wezterm_linux
      ;;
  esac
  log_ok "Neovim 和 WezTerm 安装完成"
}

# 解析 GitHub release 元数据, 选出匹配 ARCH 的 asset
github_release_asset() {
  # 用法: github_release_asset <repo> <pattern_substring>
  # 返回第一个下载 URL
  local repo="$1" pattern="$2"
  curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
    | grep -Po '"browser_download_url": "\K[^"]+' \
    | grep -F "$pattern" \
    | head -n 1
}

install_neovim_linux() {
  if command -v nvim >/dev/null 2>&1; then
    log_info "Neovim 已安装 ($(nvim --version | head -n1))"
    return 0
  fi

  local url
  case "$ARCH" in
    x86_64) url="$(github_release_asset neovim/neovim 'linux-x86_64.tar.gz')" ;;
    arm64)  url="$(github_release_asset neovim/neovim 'linux-arm64.tar.gz')"  ;;
    *)
      log_error "Neovim: 不支持的架构 $ARCH"
      return 1
      ;;
  esac
  if [[ -z "$url" ]]; then
    log_error "无法解析 Neovim release URL"
    return 1
  fi
  local tmp; tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/nvim.tar.gz" "$url"
  tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"
  sudo_run install -m 0755 "$tmp"/nvim-linux-*/bin/nvim /usr/local/bin/nvim
  rm -rf "$tmp"
  log_ok "Neovim 安装完成"
}

install_wezterm_linux() {
  if command -v wezterm >/dev/null 2>&1; then
    log_info "WezTerm 已安装"
    return 0
  fi

  # AppImage 在 x86_64/arm64 上文件名不同, 用 GitHub API 找匹配 asset
  local url
  case "$ARCH" in
    x86_64) url="$(github_release_asset wez/wezterm 'Ubuntu22.04-x86_64.AppImage')" ;;
    arm64)  url="$(github_release_asset wez/wezterm 'Ubuntu22.04-aarch64.AppImage')" ;;
    *)
      log_error "WezTerm: 不支持的架构 $ARCH"
      return 1
      ;;
  esac
  if [[ -z "$url" ]]; then
    log_error "无法解析 WezTerm release URL"
    return 1
  fi
  local tmp; tmp="$(mktemp -d)"
  curl -fsSL -L -o "$tmp/wezterm.AppImage" "$url"
  chmod +x "$tmp/wezterm.AppImage"
  sudo_run mv "$tmp/wezterm.AppImage" /usr/local/bin/wezterm
  rm -rf "$tmp"
  log_ok "WezTerm 安装完成"
}

# --------------------------------------------
# Phase 8: 应用工具
# --------------------------------------------
install_applications() {
  log_step "🖥️  安装应用工具"

  case "$OS" in
    macos)
      brew install --cask zed
      brew install zellij lazygit gh yazi
      ;;
    wsl)
      install_zed_linux
      install_zellij_linux
      install_lazygit_linux
      install_yazi_linux
      install_gh_linux
      ;;
    linux-debian)
      install_zed_linux
      install_zellij_linux
      install_lazygit_linux
      install_yazi_linux
      install_gh_debian_repo
      ;;
    linux-fedora)
      install_zed_linux
      install_zellij_linux
      install_lazygit_linux
      install_yazi_linux
      install_gh_linux
      ;;
    linux-arch)
      install_zed_linux
      install_zellij_linux
      install_lazygit_linux
      install_yazi_linux
      install_gh_linux
      ;;
    linux-alpine)
      install_zed_linux
      install_zellij_linux
      install_lazygit_linux
      install_yazi_linux
      install_gh_linux
      ;;
    linux-suse)
      install_zed_linux
      install_zellij_linux
      install_lazygit_linux
      install_yazi_linux
      install_gh_linux
      ;;
    *)
      log_warn "$OS 跳过应用工具安装"
      ;;
  esac

  log_ok "应用工具安装完成"
}

install_zed_linux() {
  if command -v zed >/dev/null 2>&1; then return 0; fi
  log_info "安装 Zed..."
  curl -fsSL https://zed.dev/install.sh | sh
}

install_zellij_linux() {
  if command -v zellij >/dev/null 2>&1; then return 0; fi
  log_info "安装 Zellij..."
  curl --proto '=https' --tlsv1.2 -LsSf https://get.zellij.io/install.sh | sh
}

install_lazygit_linux() {
  if command -v lazygit >/dev/null 2>&1; then return 0; fi
  log_info "安装 Lazygit..."
  local ver url
  ver="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
        | grep -Po '"tag_name": "\K[^"]*')"
  case "$ARCH" in
    x86_64) url="https://github.com/jesseduffield/lazygit/releases/download/${ver}/lazygit_${ver}_linux_x86_64.tar.gz" ;;
    arm64)  url="https://github.com/jesseduffield/lazygit/releases/download/${ver}/lazygit_${ver}_linux_arm64.tar.gz" ;;
    *) log_error "Lazygit: 不支持的架构 $ARCH"; return 1 ;;
  esac
  local tmp; tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/lazygit.tar.gz" "$url"
  tar -xzf "$tmp/lazygit.tar.gz" -C "$tmp"
  sudo_run install -m 0755 "$tmp/lazygit" /usr/local/bin/lazygit
  rm -rf "$tmp"
  log_ok "Lazygit 安装完成"
}

install_yazi_linux() {
  if command -v yazi >/dev/null 2>&1; then return 0; fi
  if command -v cargo >/dev/null 2>&1; then
    log_info "安装 Yazi (cargo)..."
    cargo install --locked yazi
  else
    log_warn "cargo 未安装, 跳过 yazi; 可通过 'mise use -g rust' 后再装"
  fi
}

install_gh_debian_repo() {
  install_gh_linux
}

install_gh_linux() {
  if command -v gh >/dev/null 2>&1; then return 0; fi
  case "$PKG_MGR" in
    apt-get)
      log_info "安装 GitHub CLI (apt 源)..."
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo_run dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
      sudo_run chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo_run tee /etc/apt/sources.list.d/github-cli.list >/dev/null
      pkg_update
      pkg_install gh
      ;;
    dnf|yum)
      sudo_run "$PKG_MGR" install -y 'https://github.com/cli/cli/releases/download/v2.65.0/gh_2.65.0_linux_'"$ARCH"'.rpm' 2>/dev/null || \
        log_warn "请手动安装 gh: https://github.com/cli/cli/releases"
      ;;
    pacman)
      sudo_run pacman -S --needed --noconfirm github-cli
      ;;
    apk)
      sudo_run apk add github-cli~community
      # 需要 community 源; 若失败请手动启用
      ;;
    zypper)
      sudo_run zypper ar -f https://cli.github.com/packages/rpm/gh-cli.repo gh-cli 2>/dev/null || true
      sudo_run zypper --non-interactive install --no-recommends gh
      ;;
    *)
      log_warn "未知包管理器 $PKG_MGR, 请手动安装 gh"
      ;;
  esac
}

# --------------------------------------------
# Phase 9: OpenCode
# --------------------------------------------
install_opencode() {
  log_step "🤖 安装 OpenCode"

  if command -v opencode >/dev/null 2>&1; then
    log_info "OpenCode 已安装"
  else
    export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
    if command -v mise >/dev/null 2>&1; then
      mise install node@latest || true
    fi
    if command -v npm >/dev/null 2>&1; then
      npm install -g @opencode/cli
    else
      log_warn "未找到 npm, 跳过 OpenCode 安装"
    fi
  fi
  log_ok "OpenCode 安装完成"
  log_warn "opencode.json 含 API 配置, 已被 .gitignore 忽略"
}

# --------------------------------------------
# Phase 10: uv
# --------------------------------------------
install_uv() {
  log_step "🐍 安装 uv"

  if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi
  log_ok "uv 安装完成"
}

# --------------------------------------------
# Phase 11: 配置链接 (幂等)
# --------------------------------------------
link_config() {
  local src="$1" dst="$2"
  [[ -e "$src" ]] || { log_warn "源不存在: $src"; return 0; }

  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    return 0
  fi

  if [[ -e "$dst" ]]; then
    local ts; ts="$(date +%Y%m%d-%H%M%S)"
    log_warn "备份 $dst -> ${dst}.${ts}.bak"
    mv "$dst" "${dst}.${ts}.bak"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  log_info "已链接: $dst -> $src"
}

create_symlinks() {
  if [[ "$SKIP_SYMLINKS" -eq 1 ]]; then
    log_info "跳过 symlink (--no-symlinks)"
    return 0
  fi
  log_step "🔗 创建配置链接"

  link_config "$CONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc"
  link_config "$CONFIG_DIR/starship.toml" "$HOME/.config/starship.toml"
  link_config "$CONFIG_DIR/mise/config.toml" "$HOME/.config/mise/config.toml"
  link_config "$CONFIG_DIR/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
  link_config "$CONFIG_DIR/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
  link_config "$CONFIG_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
  link_config "$CONFIG_DIR/sheldon/plugins.toml" "$HOME/.config/sheldon/plugins.toml"

  log_ok "配置链接创建完成"
}

# --------------------------------------------
# 主流程
# --------------------------------------------
main() {
  log_step "🎉 欢迎使用 Dotfiles 初始化脚本！"
  echo
  echo "此脚本将安装以下工具:"
  echo "  - Starship / Sheldon / Mise / Neovim / WezTerm"
  echo "  - Zed / Zellij / Lazygit / GitHub CLI / Yazi"
  echo "  - OpenCode / uv / fzf / ripgrep / fd / eza / bat 等"
  echo
  echo "检测到的平台: $OS ($ARCH) via $PKG_MGR"
  echo

  if [[ "$SCENARIO" != "1→1" && "$ASSUME_YES" -ne 1 ]]; then
    read -r -p "是否继续安装? [y/N] " ans < /dev/tty || ans="n"
    [[ "$ans" =~ ^[Yy]$ ]] || { log_info "安装已取消"; exit 0; }
  fi

  ensure_package_manager
  install_base_tools
  setup_dotfiles
  install_mise
  install_sheldon
  install_editors
  install_applications
  install_opencode
  install_uv
  create_symlinks

  log_step "🎊 安装完成！"
  echo
  echo "══════════════════════════════════════════════════════════════"
  echo "  下一步:"
  echo "══════════════════════════════════════════════════════════════"
  echo
  echo "1. 重新加载 shell:"
  echo "   source ~/.zshrc"
  echo
  echo "2. 登录 GitHub (如需要):"
  echo "   gh auth login"
  echo
  echo "3. 配置 OpenCode (需要 API 密钥):"
  echo "   编辑 ~/.config/opencode/opencode.json"
  echo
  echo "4. 启动 Zellij:"
  echo "   zellij attach main --create"
  echo
  [[ "$OS" == "wsl" ]] && {
    echo "──────────────────────────────────────────────────────────────"
    echo "  WSL 提示:"
    echo "  - WezTerm 在 Windows 端安装: https://wezfurlong.org"
    echo "  - WezTerm 内通过 \\'wsl.exe\\' 自动连入 WSL"
    echo "  - GUI 应用 (Zed) 在 WSLg 或 Windows 主机上运行"
    echo "──────────────────────────────────────────────────────────────"
    echo
  }
  echo "══════════════════════════════════════════════════════════════"
  echo

  log_ok "Dotfiles 初始化完成 🚀"
}

main "$@"