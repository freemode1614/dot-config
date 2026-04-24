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

# Homebrew 镜像配置
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
export HOMEBREW_NO_AUTO_UPDATE=1

# 添加 ~/.local/bin 到 PATH（uv, pipx, cargo 等工具安装位置）
# 这行由 uv 生成，保持独立以便工具自行更新
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# LM Studio CLI
export PATH="$PATH:$HOME/.lmstudio/bin"

# --------------------------------------------
# 2. 补全系统初始化
# --------------------------------------------
# 需要在加载插件之前初始化，因为许多插件使用 compdef
autoload -Uz compinit
# 使用缓存加速 compinit，仅在 .zcompdump 超过 24 小时才重新生成
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Oh My Zsh 缓存目录（部分插件依赖此变量）
export ZSH_CACHE_DIR="$HOME/.cache/oh-my-zsh"
[[ -d "$ZSH_CACHE_DIR/completions" ]] || mkdir -p "$ZSH_CACHE_DIR/completions"

# --------------------------------------------
# 3. Sheldon 插件管理器
# --------------------------------------------
# Sheldon 替代 Oh My Zsh 的插件管理功能
# 配置文件: ~/.config/sheldon/plugins.toml
# https://github.com/rossmacarthur/sheldon

if command -v sheldon &>/dev/null; then
    eval "$(sheldon source)"
fi

# --------------------------------------------
# 4. 开发工具管理器
# --------------------------------------------

# mise - 管理多版本开发工具（Node, Python, Rust 等）
# https://mise.jdx.dev/
# 使用更快的激活方式 - 只设置 PATH，不使用完整的 activate
# 这避免了每次启动时的 hook-env 开销（约 1.6 秒）
if command -v mise &>/dev/null; then
  # 只设置 shim 路径，延迟完整激活
  export PATH="$HOME/.local/share/mise/shims:$PATH"
  export MISE_SHELL=zsh

  # 定义一个函数，在需要时激活完整的 mise 功能
  mise_activate() {
    eval "$(mise activate zsh)"
  }

fi

# --------------------------------------------
# 5. 别名 (Aliases)
# --------------------------------------------

# 终端工具
alias zj="zellij"           # 终端复用器
alias lg="lazygit"          # TUI Git 客户端
alias cl="clear"            # 清屏
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
alias vim="nvim"

# 安全操作
alias mkdir="mkdir -pv"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"

# OpenCode
alias oc="opencode"

# --------------------------------------------
# 6. 历史记录配置
# --------------------------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# --------------------------------------------
# 7. 其他选项
# --------------------------------------------
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NULL_GLOB

# 自动补全配置
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# --------------------------------------------
# 8. 其他工具配置
# --------------------------------------------

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# opencode
export PATH=/Users/tzhu/.opencode/bin:$PATH