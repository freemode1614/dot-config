#!/bin/bash

# =============================================================================
# Dotfiles 初始化脚本
# =============================================================================
# 用途：在新电脑上快速安装并配置所有开发工具
# 运行：curl -fsSL https://raw.githubusercontent.com/freemode1614/dot-config/main/install.sh | bash
# 或者：./install.sh
# =============================================================================

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_step() { echo -e "\n${CYAN}══════════════════════════════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"; }

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unsupported"
    fi
}

OS=$(detect_os)

if [[ "$OS" == "unsupported" ]]; then
    log_error "不支持的操作系统: $OSTYPE"
    exit 1
fi

log_step "🚀 开始初始化 dotfiles - 操作系统: $OS"

# =============================================================================
# 1. 安装 Homebrew（macOS）
# =============================================================================
install_homebrew() {
    log_step "📦 检查并安装 Homebrew"
    
    if command -v brew &>/dev/null; then
        log_success "Homebrew 已安装"
        brew update
    else
        log_info "正在安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # 添加到 PATH
        if [[ "$OS" == "macos" ]]; then
            if [[ "$(uname -m)" == "arm64" ]]; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi
        log_success "Homebrew 安装完成"
    fi
}

# =============================================================================
# 2. 安装基础工具
# =============================================================================
install_base_tools() {
    log_step "🔧 安装基础开发工具"
    
    if [[ "$OS" == "macos" ]]; then
        # macOS 基础工具
        brew install --quiet git curl wget
        
        # 安装 Xcode Command Line Tools（如果需要）
        if ! xcode-select -p &>/dev/null; then
            log_info "安装 Xcode Command Line Tools..."
            xcode-select --install
        fi
    else
        # Linux
        sudo apt-get update
        sudo apt-get install -y git curl wget build-essential
    fi
    
    log_success "基础工具安装完成"
}

# =============================================================================
# 3. 克隆 dotfiles 仓库
# =============================================================================
clone_dotfiles() {
    log_step "📁 克隆 dotfiles 仓库"
    
    CONFIG_DIR="$HOME/.config"
    
    if [[ -d "$CONFIG_DIR/.git" ]]; then
        log_warn "~/.config 已经是一个 git 仓库"
        log_info "更新仓库..."
        cd "$CONFIG_DIR"
        git pull origin main
    else
        # 备份现有的 .config
        if [[ -d "$CONFIG_DIR" ]] && [[ "$(ls -A "$CONFIG_DIR" 2>/dev/null)" ]]; then
            BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
            log_warn "备份现有的 ~/.config 到 $BACKUP_DIR"
            mkdir -p "$BACKUP_DIR"
            mv "$CONFIG_DIR"/* "$BACKUP_DIR"/ 2>/dev/null || true
        fi
        
        log_info "克隆 dotfiles 仓库（包含子模块）..."
        git clone --recursive https://github.com/freemode1614/dot-config.git "$CONFIG_DIR"
    fi
    
    cd "$CONFIG_DIR"
    log_success "Dotfiles 仓库准备完成"
}

# =============================================================================
# 4. 安装 Zsh 和 Oh My Zsh
# =============================================================================
install_zsh() {
    log_step "🐚 安装并配置 Zsh"
    
    # 安装 Zsh
    if ! command -v zsh &>/dev/null; then
        if [[ "$OS" == "macos" ]]; then
            brew install zsh
        else
            sudo apt-get install -y zsh
        fi
    fi
    
    # 安装 Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "安装 Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # 安装 Powerlevel10k 主题
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
        log_info "安装 Powerlevel10k 主题..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    fi
    
    # 安装 Zsh 插件
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
        log_info "安装 zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    fi
    
    if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
        log_info "安装 zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    fi
    
    # 创建 zsh 配置链接
    if [[ -f "$HOME/.config/zsh/.zshrc" ]]; then
        # 备份现有的 .zshrc
        if [[ -f "$HOME/.zshrc" ]]; then
            mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d)"
        fi
        ln -sf "$HOME/.config/zsh/.zshrc" "$HOME/.zshrc"
    fi
    
    # 设置默认 shell 为 zsh
    if [[ "$SHELL" != *"zsh"* ]]; then
        log_info "设置 Zsh 为默认 shell..."
        chsh -s "$(which zsh)"
    fi
    
    log_success "Zsh 配置完成"
}

# =============================================================================
# 5. 安装 Mise（版本管理器）
# =============================================================================
install_mise() {
    log_step "🔨 安装 Mise（开发工具版本管理器）"
    
    if ! command -v mise &>/dev/null; then
        log_info "安装 Mise..."
        curl https://mise.run | sh
        
        # 添加到当前 session
        export PATH="$HOME/.local/bin:$PATH"
        eval "$("$HOME/.local/bin/mise" activate bash)"
    fi
    
    log_success "Mise 安装完成"
    
    # 安装配置的工具
    if [[ -f "$HOME/.config/mise/config.toml" ]]; then
        log_info "安装配置的开发工具（Node.js, Bun, pnpm, Yarn）..."
        mise install
        log_success "开发工具安装完成"
    fi
}

# =============================================================================
# 6. 安装终端模拟器（WezTerm）
# =============================================================================
install_wezterm() {
    log_step "🖥️  安装 WezTerm 终端模拟器"
    
    if ! command -v wezterm &>/dev/null; then
        if [[ "$OS" == "macos" ]]; then
            brew install --cask wezterm
        else
            # Linux - 从 GitHub 下载
            curl -LO https://github.com/wez/wezterm/releases/latest/download/wezterm.AppImage
            chmod +x wezterm.AppImage
            sudo mv wezterm.AppImage /usr/local/bin/wezterm
        fi
    fi
    
    log_success "WezTerm 安装完成"
}

# =============================================================================
# 7. 安装 Neovim
# =============================================================================
install_neovim() {
    log_step "📝 安装 Neovim"
    
    if ! command -v nvim &>/dev/null; then
        if [[ "$OS" == "macos" ]]; then
            brew install neovim
        else
            # Linux - 使用预编译的 AppImage
            log_info "下载 Neovim AppImage..."
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
            chmod u+x nvim.appimage
            sudo mv nvim.appimage /usr/local/bin/nvim
            
            # 安装依赖（用于 LazyVim）
            sudo apt-get install -y ripgrep fd-find
        fi
    fi
    
    log_success "Neovim 安装完成"
    
    # 安装 nvim 插件（LazyVim 会自动安装）
    log_info "首次启动 Neovim 时会自动安装插件..."
}

# =============================================================================
# 8. 安装 Zed 编辑器
# =============================================================================
install_zed() {
    log_step "⚡ 安装 Zed 编辑器"
    
    if ! command -v zed &>/dev/null; then
        if [[ "$OS" == "macos" ]]; then
            brew install --cask zed
        else
            # Linux
            curl -f https://zed.dev/install.sh | sh
        fi
    fi
    
    log_success "Zed 安装完成"
    
    # 提示配置
    log_warn "注意：Zed 的配置文件 settings.json 包含个人设置，已被 .gitignore 忽略"
    log_info "请参考 zed/settings.json.example 创建你的配置"
}

# =============================================================================
# 9. 安装 Zellij（终端复用器）
# =============================================================================
install_zellij() {
    log_step "🪟 安装 Zellij 终端复用器"
    
    if ! command -v zellij &>/dev/null; then
        if [[ "$OS" == "macos" ]]; then
            brew install zellij
        else
            # Linux - 下载预编译二进制
            log_info "下载 Zellij 预编译版本..."
            curl -LO https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz
            tar -xzf zellij-x86_64-unknown-linux-musl.tar.gz
            chmod +x zellij
            sudo mv zellij /usr/local/bin/
            rm zellij-x86_64-unknown-linux-musl.tar.gz
        fi
    fi
    
    log_success "Zellij 安装完成"
}

# =============================================================================
# 10. 安装 Lazygit
# =============================================================================
install_lazygit() {
    log_step "🌳 安装 Lazygit"
    
    if ! command -v lazygit &>/dev/null; then
        if [[ "$OS" == "macos" ]]; then
            brew install lazygit
        else
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf lazygit.tar.gz lazygit
            sudo install lazygit /usr/local/bin
            rm lazygit lazygit.tar.gz
        fi
    fi
    
    log_success "Lazygit 安装完成"
}

# =============================================================================
# 11. 安装 GitHub CLI
# =============================================================================
install_gh() {
    log_step "🐙 安装 GitHub CLI"
    
    if ! command -v gh &>/dev/null; then
        if [[ "$OS" == "macos" ]]; then
            brew install gh
        else
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt-get update
            sudo apt-get install gh -y
        fi
    fi
    
    log_success "GitHub CLI 安装完成"
    log_warn "运行 'gh auth login' 来配置 GitHub 认证"
}

# =============================================================================
# 12. 安装 uv（Python 包管理器）
# =============================================================================
install_uv() {
    log_step "🐍 安装 uv（Python 包管理器）"
    
    if ! command -v uv &>/dev/null; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    
    log_success "uv 安装完成"
}

# =============================================================================
# 13. 安装 Podman（容器引擎）
# =============================================================================
install_podman() {
    log_step "🐳 安装 Podman 容器引擎"
    
    if ! command -v podman &>/dev/null; then
        if [[ "$OS" == "macos" ]]; then
            brew install podman
            podman machine init
            podman machine start
        else
            sudo apt-get install -y podman
        fi
    fi
    
    log_success "Podman 安装完成"
}

# =============================================================================
# 14. 安装 Opencode
# =============================================================================
install_opencode() {
    log_step "🤖 安装 Opencode AI 助手"
    
    if ! command -v opencode &>/dev/null; then
        # 需要 Node.js
        if ! command -v node &>/dev/null; then
            log_warn "Node.js 未安装，将使用 mise 安装..."
            mise use -g node@latest
            export PATH="$HOME/.local/share/mise/installs/node/latest/bin:$PATH"
        fi
        
        # 安装 opencode
        npm install -g @opencode/cli
    fi
    
    log_success "Opencode 安装完成"
    log_warn "注意：需要配置 opencode.json（包含 API 配置），已被 .gitignore 忽略"
}

# =============================================================================
# 15. 安装其他推荐工具
# =============================================================================
install_extra_tools() {
    log_step "✨ 安装其他推荐工具"
    
    if [[ "$OS" == "macos" ]]; then
        # macOS 额外工具
        brew install --quiet \
            fzf \
            ripgrep \
            fd \
            bat \
            eza \
            btop \
            tldr \
            tree \
            jq \
            yq \
            stow \
            2>/dev/null || true
    else
        # Linux 额外工具
        sudo apt-get install -y \
            fzf \
            ripgrep \
            fd-find \
            bat \
            tree \
            jq \
            2>/dev/null || true
        
        # 安装 eza（现代化的 ls）
        if ! command -v eza &>/dev/null; then
            sudo apt-get install -y gpg
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            sudo apt-get update
            sudo apt-get install -y eza
        fi
        
        # 安装 btop（从预编译二进制）
        if ! command -v btop &>/dev/null; then
            log_info "下载 btop..."
            curl -LO https://github.com/aristocratos/btop/releases/latest/download/btop-x86_64-linux.tbz
            tar -xjf btop-x86_64-linux.tbz
            sudo mv btop/bin/btop /usr/local/bin/
            rm -rf btop btop-x86_64-linux.tbz
        fi
    fi
    
    log_success "额外工具安装完成"
}

# =============================================================================
# 16. 创建配置文件链接
# =============================================================================
create_symlinks() {
    log_step "🔗 创建配置文件链接"
    
    # zsh
    if [[ -d "$HOME/.config/zsh" ]]; then
        ln -sf "$HOME/.config/zsh/.zshrc" "$HOME/.zshrc"
        log_info "已链接 .zshrc"
    fi
    
    log_success "配置文件链接创建完成"
}

# =============================================================================
# 17. 安装 Nerd Font（用于 Powerlevel10k）
# =============================================================================
install_nerd_font() {
    log_step "🔤 安装 Nerd Font（推荐：MesloLGS NF）"
    
    if [[ "$OS" == "macos" ]]; then
        # macOS 通过 Homebrew 安装字体
        if ! brew list --cask font-meslo-lg-nerd-font &>/dev/null; then
            brew tap homebrew/cask-fonts
            brew install --cask font-meslo-lg-nerd-font 2>/dev/null || log_warn "字体安装可能需要手动确认"
        fi
    fi
    
    log_info "请确保在终端设置中将字体更改为 'MesloLGS NF'"
    log_info "配置完成后，运行 'p10k configure' 来设置 Powerlevel10k 主题"
}

# =============================================================================
# 主安装流程
# =============================================================================
main() {
    log_step "🎉 欢迎使用 Dotfiles 初始化脚本！"
    
    echo ""
    echo "此脚本将安装以下工具："
    echo "  - Homebrew（macOS）/ apt（Linux）"
    echo "  - Zsh + Oh My Zsh + Powerlevel10k"
    echo "  - Neovim（编辑器）"
    echo "  - Zed（编辑器）"
    echo "  - WezTerm（终端模拟器）"
    echo "  - Zellij（终端复用器）"
    echo "  - Mise（版本管理器）"
    echo "  - Lazygit（Git UI）"
    echo "  - GitHub CLI"
    echo "  - uv（Python 包管理器）"
    echo "  - Podman（容器引擎）"
    echo "  - Opencode（AI 助手）"
    echo "  - 其他开发工具（fzf, ripgrep, bat, eza 等）"
    echo ""
    
    read -p "是否继续安装？ (y/N) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "安装已取消"
        exit 0
    fi
    
    # 执行安装步骤
    install_homebrew
    install_base_tools
    clone_dotfiles
    install_zsh
    install_mise
    install_wezterm
    install_neovim
    install_zed
    install_zellij
    install_lazygit
    install_gh
    install_uv
    install_podman
    install_opencode
    install_extra_tools
    create_symlinks
    install_nerd_font
    
    # 完成
    log_step "🎊 安装完成！"
    
    echo ""
    echo "══════════════════════════════════════════════════════════════"
    echo "  下一步操作："
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    echo "1. 重新启动终端或运行："
    echo "   source ~/.zshrc"
    echo ""
    echo "2. 配置 Powerlevel10k（如果这是你第一次安装）："
    echo "   p10k configure"
    echo ""
    echo "3. 登录 GitHub："
    echo "   gh auth login"
    echo ""
    echo "4. 配置 Opencode（需要 API 密钥）："
    echo "   opencode --version"
    echo ""
    echo "5. 启动 Zellij："
    echo "   zellij attach main --create"
    echo ""
    echo "6. 启动 WezTerm 并体验完整工作流"
    echo ""
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    
    log_success "Dotfiles 初始化完成！享受你的新开发环境吧 🚀"
}

# 运行主函数
main "$@"
