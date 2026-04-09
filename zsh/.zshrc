# ============================================
# Zsh 配置文件
# ============================================

# 使用中科大镜像（推荐，速度快）
export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"

# --------------------------------------------
# 1. 基础环境变量 & PATH 设置（按优先级排序）
# --------------------------------------------

# Homebrew - 支持 Apple Silicon 和 Intel Mac
# 必须先初始化，因为后续工具可能依赖 brew 安装的软件
if [[ -d "/opt/homebrew/bin" ]]; then
    # Apple Silicon Mac (M1/M2/M3/M4)
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
    # Intel Mac
    eval "$(/usr/local/bin/brew shellenv)"
fi

# 添加 ~/.local/bin 到 PATH（uv, pipx, cargo 等工具安装位置）
# 这行由 uv 生成，保持独立以便工具自行更新
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# --------------------------------------------
# 2. Oh My Zsh 配置
# --------------------------------------------

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="frontcube"
plugins=(
    # ----------------------------
    # 基础必备
    # ----------------------------
    git                 # Git 别名和自动补全: gst, gco, ggpull 等
    sudo                # 按 Esc 两次自动添加 sudo
    history             # h, hs, hsi 快速搜索历史

    # ----------------------------
    # macOS 相关
    # ----------------------------
    macos               # macOS 特有功能: pbcopy/pbpaste, man-preview 等
    brew                # Homebrew 别名: bcubc, bcubo 等

    # ----------------------------
    # 开发工具（根据你安装的工具）
    # ----------------------------
    # node                # Node.js 别名和补全
    # npm                 # npm 别名: npmG, npmL 等
    # bun                 # Bun 运行时支持
    # python              # Python 别名: py, python2/3
    # pip                 # pip 别名和补全

    # ----------------------------
    # 实用增强
    # ----------------------------
    z                   # 目录快速跳转 (z <目录名>)
    colored-man-pages   # 彩色 man 手册页面
    command-not-found   # 命令未找到时提示安装方式
)

source $ZSH/oh-my-zsh.sh

# --------------------------------------------
# 3. 开发工具管理器
# --------------------------------------------

# mise - 管理多版本开发工具（Node, Python, Rust 等）
# https://mise.jdx.dev/
if command -v mise &>/dev/null; then
    eval "$(mise activate zsh --shims)"
fi

# --------------------------------------------
# 4. 别名 (Aliases)
# --------------------------------------------

# 终端工具
alias zj="zellij"           # 终端复用器
alias lg="lazygit"          # TUI Git 客户端
alias ya="yazi"             # Yazi 文件管理器

# Yazi 文件管理器 - 退出后自动切换到当前目录
# 使用方法: yy (进入 yazi，退出后自动 cd 到当前目录)
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# 编辑器
alias v="nvim"              # Neovim 简写
alias vi="nvim"

# 包管理器
alias p="pnpm"              # pnpm 简写

# OpenCode 配置切换（家用/公司）
alias ocwork='cd ~/.config/opencode && ln -sf opencode.json.work opencode.json && ln -sf oh-my-opencode.json.work oh-my-opencode.json && echo "OpenCode: 切换到公司配置"'
alias ochome='cd ~/.config/opencode && ln -sf opencode.json.home opencode.json && ln -sf oh-my-opencode.json.home oh-my-opencode.json && echo "OpenCode: 切换到家用配置"'

# --------------------------------------------
# 5. 第三方 Zsh 插件（由 install.sh 安装）
# --------------------------------------------

# 自动建议：根据历史记录灰色提示命令，按 → 接受
source ~/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# 语法高亮：实时命令语法高亮（需在 omz 之后加载）
source ~/.local/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# --------------------------------------------
# 6. 其他工具配置（后续按需添加）
# --------------------------------------------

# 例如：
# - oh-my-posh 主题
# - fzf 配置
# - zoxide 初始化
# 等等...
