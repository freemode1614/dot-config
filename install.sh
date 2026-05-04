#!/bin/bash

# =============================================================================
# Dotfiles 初始化脚本 (重构版)
# =============================================================================
# 技术栈: zsh + sheldon + starship + mise
# 场景支持: 0→1 (全新安装), 0.5→1 (补全安装), 1→1 (更新)
# 运行: ./install.sh
# =============================================================================

set -euo pipefail

# --------------------------------------------
# 颜色定义
# --------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# --------------------------------------------
# 日志函数
# --------------------------------------------
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_step() {
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
}

# --------------------------------------------
# 变量
# --------------------------------------------
CONFIG_DIR="$HOME/.config"
DOTFILES_REPO="https://github.com/freemode1614/dot-config.git"

# --------------------------------------------
# Phase 1: 环境检测
# --------------------------------------------
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unsupported"
    fi
}

detect_arch() {
    case "$(uname -m)" in
        x86_64) echo "x86_64" ;;
        arm64|aarch64) echo "arm64" ;;
        *) echo "unknown" ;;
    esac
}

detect_installation_scenario() {
    local scenario="0→1"

    if [[ -d "$CONFIG_DIR/.git" ]]; then
        scenario="1→1"
    elif [[ -d "$CONFIG_DIR" ]] && [[ "$(ls -A "$CONFIG_DIR" 2>/dev/null)" ]]; then
        scenario="0.5→1"
    fi

    echo "$scenario"
}

OS=$(detect_os)
ARCH=$(detect_arch)
SCENARIO=$(detect_installation_scenario)

if [[ "$OS" == "unsupported" ]]; then
    log_error "不支持的操作系统: $OSTYPE"
    exit 1
fi

log_step "🚀 开始初始化 dotfiles"
echo "  操作系统: $OS ($ARCH)"
echo "  安装场景: $SCENARIO"

# --------------------------------------------
# Phase 2: 包管理器
# --------------------------------------------
install_package_manager() {
    log_step "📦 安装包管理器"

    if [[ "$OS" == "macos" ]]; then
        if command -v brew &>/dev/null; then
            log_success "Homebrew 已安装"
        else
            log_info "安装 Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            if [[ "$(uname -m)" == "arm64" ]]; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            log_success "Homebrew 安装完成"
        fi
    else
        log_info "更新 apt..."
        sudo apt-get update -qq
        log_success "apt 准备完成"
    fi
}

# --------------------------------------------
# Phase 3: 基础工具
# --------------------------------------------
install_base_tools() {
    log_step "🔧 安装基础工具"

    if [[ "$OS" == "macos" ]]; then
        brew install --quiet git curl wget
        if ! xcode-select -p &>/dev/null; then
            log_info "安装 Xcode Command Line Tools..."
            xcode-select --install
        fi
        brew install --quiet fzf ripgrep fd bat eza jq tree unzip starship
    else
        sudo apt-get install -y git curl wget build-essential fzf ripgrep fd-find bat jq tree unzip
        install_starship_linux
        install_eza_linux
    fi

    log_success "基础工具安装完成"
}

install_starship_linux() {
    if ! command -v starship &>/dev/null; then
        log_info "安装 Starship..."
        curl -fsSL https://starship.rs/install.sh | sh -s -- -y
    fi
}

install_eza_linux() {
    if ! command -v eza &>/dev/null; then
        log_info "安装 eza..."
        sudo apt-get install -y gpg
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt-get update -qq
        sudo apt-get install -y eza
    fi
}

# --------------------------------------------
# Phase 4: Mise (版本管理器)
# --------------------------------------------
install_mise() {
    log_step "🔨 安装 Mise"

    if ! command -v mise &>/dev/null; then
        log_info "安装 Mise..."
        curl https://mise.run | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi

    export PATH="$HOME/.local/share/mise/shims:$PATH"
    export MISE_SHELL=zsh

    if [[ -f "$CONFIG_DIR/mise/config.toml" ]]; then
        log_info "安装开发工具 (node, bun, pnpm, yarn, python)..."
        mise install
    fi

    log_success "Mise 安装完成"
}

# --------------------------------------------
# Phase 5: Sheldon (Zsh 插件管理器)
# --------------------------------------------
install_sheldon() {
    log_step "🐚 安装 Sheldon"

    if ! command -v sheldon &>/dev/null; then
        log_info "安装 Sheldon..."
        curl -fsSL https://rossmacarthur.github.io/install.sh | sh -s -- repo sheldon-org/sheldon
    fi

    if [[ -f "$CONFIG_DIR/sheldon/plugins.toml" ]]; then
        log_info "应用 Sheldon 插件配置..."
        cd "$CONFIG_DIR"
        sheldon lock --update
        log_success "Sheldon 插件安装完成"
    fi
}

# --------------------------------------------
# Phase 6: Dotfiles 仓库
# --------------------------------------------
setup_dotfiles() {
    log_step "📁 设置 Dotfiles 仓库"

    if [[ "$SCENARIO" == "0→1" ]]; then
        log_info "克隆 dotfiles 仓库..."
        git clone --recursive "$DOTFILES_REPO" "$CONFIG_DIR"
        log_success "Dotfiles 克隆完成"

    elif [[ "$SCENARIO" == "0.5→1" ]]; then
        log_info "当前 .config 非 git 仓库，初始化为 dotfiles..."
        local backup_dir="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
        log_warn "备份现有配置到 $backup_dir"
        mv "$CONFIG_DIR" "$backup_dir"
        git clone --recursive "$DOTFILES_REPO" "$CONFIG_DIR"
        log_success "Dotfiles 初始化完成"

    elif [[ "$SCENARIO" == "1→1" ]]; then
        log_info "更新 dotfiles 仓库..."
        cd "$CONFIG_DIR"
        git pull --autostash origin main
        git submodule update --recursive --merge
        log_success "Dotfiles 更新完成"
    fi

    cd "$CONFIG_DIR"
}

# --------------------------------------------
# Phase 7: Neovim & WezTerm (Submodules)
# --------------------------------------------
install_submodules() {
    log_step "📦 安装 Neovim 和 WezTerm (Submodules)"

    if [[ "$OS" == "macos" ]]; then
        brew install --cask neovim wezterm
    else
        install_neovim_linux
        install_wezterm_linux
    fi

    log_info "更新 Git Submodules..."
    cd "$CONFIG_DIR"
    git submodule update --init --recursive

    log_success "Neovim 和 WezTerm 安装完成"
}

install_neovim_linux() {
    if ! command -v nvim &>/dev/null; then
        log_info "安装 Neovim..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
        chmod u+x nvim.appimage
        sudo mv nvim.appimage /usr/local/bin/nvim
        sudo apt-get install -y ripgrep fd-find
    fi
}

install_wezterm_linux() {
    if ! command -v wezterm &>/dev/null; then
        log_info "安装 WezTerm..."
        curl -LO https://github.com/wez/wezterm/releases/latest/download/wezterm.AppImage
        chmod +x WezTerm-*.AppImage
        sudo mv WezTerm-*.AppImage /usr/local/bin/wezterm
    fi
}

# --------------------------------------------
# Phase 8: 应用工具
# --------------------------------------------
install_applications() {
    log_step "🖥️  安装应用工具"

    if [[ "$OS" == "macos" ]]; then
        brew install --cask zed
        brew install zellij lazygit gh yazi
    else
        install_zed_linux
        install_zellij_linux
        install_lazygit_linux
        install_yazi_linux
        install_gh_linux
    fi

    log_success "应用工具安装完成"
}

install_zed_linux() {
    if ! command -v zed &>/dev/null; then
        log_info "安装 Zed..."
        curl -f https://zed.dev/install.sh | sh
    fi
}

install_zellij_linux() {
    if ! command -v zellij &>/dev/null; then
        log_info "安装 Zellij..."
        curl --proto '=https' --tlsv1.2 -LsSf https://get.zellij.io/install.sh | sh
    fi
}

install_lazygit_linux() {
    if ! command -v lazygit &>/dev/null; then
        log_info "安装 Lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit lazygit.tar.gz
    fi
}

install_yazi_linux() {
    if ! command -v yazi &>/dev/null; then
        log_info "安装 Yazi..."
        cargo install --locked yazi
    fi
}

install_gh_linux() {
    if ! command -v gh &>/dev/null; then
        log_info "安装 GitHub CLI..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt-get update -qq
        sudo apt-get install gh -y
    fi
}

# --------------------------------------------
# Phase 9: OpenCode
# --------------------------------------------
install_opencode() {
    log_step "🤖 安装 OpenCode"

    if ! command -v opencode &>/dev/null; then
        if ! command -v node &>/dev/null; then
            log_info "安装 Node.js..."
            mise install node@latest
        fi
        export PATH="$HOME/.local/share/mise/shims:$PATH"
        npm install -g @opencode/cli
    fi

    log_success "OpenCode 安装完成"
    log_warn "注意：opencode.json 包含 API 配置，已被 .gitignore 忽略"
}

# --------------------------------------------
# Phase 10: UV (Python 包管理器)
# --------------------------------------------
install_uv() {
    log_step "🐍 安装 UV"

    if ! command -v uv &>/dev/null; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi

    log_success "UV 安装完成"
}

# --------------------------------------------
# Phase 11: 配置链接
# --------------------------------------------
create_symlinks() {
    log_step "🔗 创建配置链接"

    if [[ -f "$CONFIG_DIR/zsh/.zshrc" ]]; then
        if [[ -L "$HOME/.zshrc" ]]; then
            rm "$HOME/.zshrc"
        elif [[ -f "$HOME/.zshrc" ]]; then
            mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d)"
        fi
        ln -sf "$CONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc"
        log_info "已链接 .zshrc"
    fi

    if [[ -f "$CONFIG_DIR/starship.toml" ]]; then
        mkdir -p "$HOME/.config"
        ln -sf "$CONFIG_DIR/starship.toml" "$HOME/.config/starship.toml"
        log_info "已链接 starship.toml"
    fi

    log_success "配置链接创建完成"
}

# --------------------------------------------
# 主流程
# --------------------------------------------
main() {
    log_step "🎉 欢迎使用 Dotfiles 初始化脚本！"

    echo ""
    echo "此脚本将安装以下工具："
    echo "  - Starship (跨 shell prompt)"
    echo "  - Sheldon (Zsh 插件管理器)"
    echo "  - Mise (Node, Bun, pnpm, Yarn, Python 版本管理)"
    echo "  - Neovim (代码编辑器)"
    echo "  - WezTerm (终端模拟器)"
    echo "  - Zed (编辑器)"
    echo "  - Zellij (终端复用器)"
    echo "  - Lazygit (Git UI)"
    echo "  - GitHub CLI"
    echo "  - Yazi (文件管理器)"
    echo "  - OpenCode (AI 助手)"
    echo "  - UV (Python 包管理器)"
    echo "  - 其他开发工具 (fzf, ripgrep, bat, eza 等)"
    echo ""

    if [[ "$SCENARIO" != "1→1" ]]; then
        read -p "是否继续安装？ (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "安装已取消"
            exit 0
        fi
    fi

    install_package_manager
    install_base_tools
    setup_dotfiles
    install_mise
    install_sheldon
    install_submodules
    install_applications
    install_opencode
    install_uv
    create_symlinks

    log_step "🎊 安装完成！"

    echo ""
    echo "══════════════════════════════════════════════════════════════"
    echo "  下一步操作："
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    echo "1. 重新启动终端或运行："
    echo "   source ~/.zshrc"
    echo ""
    echo "2. 配置 GitHub（如果需要）："
    echo "   gh auth login"
    echo ""
    echo "3. 配置 OpenCode（需要 API 密钥）："
    echo "   opencode --version"
    echo ""
    echo "4. 启动 Zellij："
    echo "   zellij attach main --create"
    echo ""
    echo "5. 启动 WezTerm 并体验完整工作流"
    echo ""
    echo "══════════════════════════════════════════════════════════════"
    echo ""

    log_success "Dotfiles 初始化完成！享受你的新开发环境吧 🚀"
}

main "$@"
