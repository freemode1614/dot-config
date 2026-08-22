# ============================================
# Zsh 配置文件
# 技术栈: zsh + sheldon + mise + fzf
# ============================================

# --------------------------------------------
# 1. Homebrew 环境 (macOS / Linuxbrew)
# --------------------------------------------
if [[ -d "/opt/homebrew/bin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
    eval "$($HOME/.linuxbrew/bin/brew shellenv)"
elif [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# uv 环境 (由 uv 自动生成)
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# LM Studio CLI
export PATH="$PATH:$HOME/.lmstudio/bin"

# --------------------------------------------
# 2. Mise (开发工具版本管理)
# Mise shims 始终在 PATH，但 activate 懒加载
# --------------------------------------------
export PATH="$HOME/.local/share/mise/shims:$PATH"

__mise_activate() {
    unfunction __mise_activate
    export MISE_SHELL=zsh
    eval "$(mise activate zsh)"
}

# Rust 环境 (rustup 官方安装，不经 mise)
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Bun 全局包 bin (如使用系统 bun 而非 mise 管理)
[[ -d "$HOME/.bun/bin" ]] && export PATH="$HOME/.bun/bin:$PATH"

# --------------------------------------------
# 3. 补全系统
# --------------------------------------------
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# --------------------------------------------
# 4. Sheldon (插件)
# --------------------------------------------
if command -v sheldon &>/dev/null; then
    eval "$(sheldon source)"
fi

# --------------------------------------------
# 5. Starship Prompt
# --------------------------------------------
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# --------------------------------------------
# 5. 懒加载工具 (首次调用时才初始化)
# --------------------------------------------

# fzf — 只加载补全，不加载 key bindings (避免每次启动执行 fzf)
__fzf_init() {
    unfunction __fzf_init
    if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
        source /usr/share/fzf/key-bindings.zsh
    elif [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
        source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    elif [[ -f ~/.fzf/shell/key-bindings.zsh ]]; then
        source ~/.fzf/shell/key-bindings.zsh
    fi
}
alias fzf='__fzf_init && fzf'

# mise — 首次运行工具时激活
__mise_init() {
    unfunction mise
    __mise_activate
    mise "$@"
}
alias mise='__mise_init'

# gh — 始终在 PATH，opencode 同理
# --------------------------------------------
# 6. 其他工具 PATH
# --------------------------------------------
# OpenCode
export PATH="$HOME/.opencode/bin:$PATH"

# --------------------------------------------
# 7. 别名
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

alias mkdir="mkdir -pv"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"

alias oc="opencode"

# --------------------------------------------
# 8. 历史记录
# --------------------------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# --------------------------------------------
# 9. 其他选项
# --------------------------------------------
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NULL_GLOB

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# --------------------------------------------
# 10. 加载 conf.d 下的配置片段
# --------------------------------------------
for f in ${ZDOTDIR:-$HOME/.config/zsh}/conf.d/*.zsh; do
    [ -r "$f" ] && source "$f"
done

# Added by qodercli install
export PATH="$PATH:$HOME/.local/bin"
