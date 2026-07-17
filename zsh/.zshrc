# ============================================
# Zsh 配置文件
# 技术栈: zsh + sheldon + starship + mise
# ============================================

# --------------------------------------------
# 1. Homebrew 环境 (macOS) — 仅当未设置时执行
# --------------------------------------------
if [[ -z "$_HOMEBREW_SHELLENV_DONE" ]]; then
    if [[ -d "/opt/homebrew/bin" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    export _HOMEBREW_SHELLENV_DONE=1
fi

# Homebrew 镜像 (可选，取消注释使用)
# export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
# export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"

# uv 环境 (由 uv 自动生成)
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# LM Studio CLI
export PATH="$PATH:$HOME/.lmstudio/bin"

# --------------------------------------------
# 2. Mise (开发工具版本管理)
# --------------------------------------------
if command -v mise &>/dev/null; then
    export PATH="$HOME/.local/share/mise/shims:$PATH"
    eval "$(mise activate zsh)" 2>/dev/null
fi

# Bun 全局包 bin
export PATH="$HOME/.bun/bin:$PATH"

# --------------------------------------------
# 3. 补全系统 — 优化 compinit 性能
# --------------------------------------------
autoload -Uz compinit

# 使用固定的 zcompdump 路径，避免多终端竞争
ZCOMPDUMP_FILE="$HOME/.config/zsh/.zcompdump-$ZSH_VERSION"

# 跳过 compaudit 安全检查（已知安全目录），大幅提升 compinit 速度
# 每天重新扫描一次补全文件，其余时间使用缓存
if [[ -n "$ZCOMPDUMP_FILE"(#qN.mh+24) ]]; then
    compinit -u -d "$ZCOMPDUMP_FILE"
else
    compinit -u -C -d "$ZCOMPDUMP_FILE"
fi

# --------------------------------------------
# 4. Starship Prompt
# --------------------------------------------
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# --------------------------------------------
# 5. Sheldon (Zsh 插件管理器)
# --------------------------------------------
if command -v sheldon &>/dev/null; then
    eval "$(sheldon source)"
fi

# --------------------------------------------
# 6. zoxide (目录跳转) — sheldon 已加载插件，只需 init
# --------------------------------------------
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# --------------------------------------------
# 7. fzf (模糊搜索) — 延迟加载
# --------------------------------------------
if command -v fzf &>/dev/null; then
    eval "$(fzf --zsh)"
fi

# --------------------------------------------
# 8. 别名
# --------------------------------------------
alias lg="lazygit"
alias cl="clear"
alias y="yazi"
alias z="zellij"

function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias n="nvim"

alias mkdir="mkdir -pv"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"

alias oc="opencode"

# --------------------------------------------
# 9. 历史记录
# --------------------------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# --------------------------------------------
# 10. 其他选项
# --------------------------------------------
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NULL_GLOB

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# --------------------------------------------
# 11. 其他工具配置
# --------------------------------------------
# Bun completions (由 mise 管理)
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# OpenCode
export PATH="$HOME/.opencode/bin:$PATH"

# --------------------------------------------
# 12. 自动启动 zellij（交互式 shell 且不在 zellij 内）
# --------------------------------------------
# if [[ -n "$TERM_PROGRAM" && -z "$ZELLIJ" && -x "$(command -v zellij)" ]]; then
#     exec zellij
# fi
