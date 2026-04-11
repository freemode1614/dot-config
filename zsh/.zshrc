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
# 2. Oh My Zsh 配置
# --------------------------------------------

export ZSH="$HOME/.oh-my-zsh"

# 主题使用 oh-my-posh，所以这里设置为空白
ZSH_THEME=""

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
    # 开发工具（已移除 npm, yarn, pip 以避免启动变慢）
    # ----------------------------
    node                # Node.js 别名和补全（轻量级）
    bun                 # Bun 运行时支持（后台生成补全）
    deno                # Deno 运行时支持（后台生成补全）
    python              # Python 别名: py, python2/3（轻量级）
    # npm/yarn/pip 插件已移除 - 它们会在启动时执行外部命令导致变慢
    # 相关别名已手动添加在下方的 Aliases 部分

    # ----------------------------
    # 实用增强
    # ----------------------------
    z                   # 目录快速跳转 (z <目录名>)
    colored-man-pages   # 彩色 man 手册页面
    command-not-found   # 命令未找到时提示安装方式
    fast-syntax-highlighting  # 语法高亮
)

source $ZSH/oh-my-zsh.sh

# --------------------------------------------
# 3. Oh My Posh 主题配置
# --------------------------------------------
if command -v oh-my-posh &>/dev/null; then
  eval "$(oh-my-posh init zsh --config ~/.poshthemes/robbyrussell.omp.json)"
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

# 包管理器
alias p="pnpm"              # pnpm 简写

# npm 别名（替代 npm 插件）
alias npmg="npm i -g"
alias npmS="npm i -S"
alias npmD="npm i -D"
alias npmF="npm i -f"
alias npmE='PATH="$(npm bin):$PATH"'
alias npmO="npm outdated"
alias npmU="npm update"
alias npmV="npm -v"
alias npmL="npm list"
alias npmL0="npm ls --depth=0"

# yarn 别名（替代 yarn 插件）
alias y="yarn"
alias ya="yarn add"
alias yad="yarn add --dev"
alias yap="yarn add --peer"
alias yb="yarn build"
alias ycc="yarn cache clean"
alias yd="yarn dev"
alias yf="yarn format"
alias yh="yarn help"
alias yi="yarn init"
alias yin="yarn install"
alias yln="yarn lint"
alias ylnf="yarn lint --fix"
alias yp="yarn pack"
alias yrm="yarn remove"
alias yrun="yarn run"
alias ys="yarn serve"
alias yst="yarn start"
alias yt="yarn test"
alias ytc="yarn test --coverage"
alias yui="yarn upgrade-interactive"
alias yup="yarn upgrade"
alias yv="yarn version"
alias yw="yarn workspace"
alias yws="yarn workspaces"
alias yy="yarn why"

# pip 别名（替代 pip 插件）
alias pipi="pip install"
alias pipu="pip uninstall"
alias pipl="pip list"
alias pipo="pip outdated"
alias pipf="pip freeze"
alias pipr="pip install -r requirements.txt"

# ls 相关
alias ll="ls -lh"
alias la="ls -la"
alias lla="ls -la"

# 目录导航
alias ..="cd .."
alias ...="cd ../.."
alias ~="cd ~"

# 安全操作
alias mkdir="mkdir -pv"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"
# OpenCode
alias oc="opencode"

# --------------------------------------------
# 6. 第三方 Zsh 插件（由 install.sh 安装）
# --------------------------------------------

# 延迟加载 zsh-autosuggestions（节省约 1 秒启动时间）
# 在第一次提示符显示后加载
zsh_autosuggestions_load() {
  local autosuggest_file=""
  if [ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    autosuggest_file="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  elif [ -f "$(brew --prefix 2>/dev/null)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    autosuggest_file="$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  elif [ -f "$HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    autosuggest_file="$HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi

  if [ -n "$autosuggest_file" ]; then
    source "$autosuggest_file"
  fi
}

# 在第一次提示符显示后加载 autosuggestions
autoload -Uz add-zsh-hook
load_autosuggestions_after_prompt() {
  add-zsh-hook -d precmd load_autosuggestions_after_prompt
  zsh_autosuggestions_load
}
add-zsh-hook precmd load_autosuggestions_after_prompt

# 如果 brew 安装了 fast-syntax-highlighting 且 oh-my-zsh 没加载，则手动加载
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting" ]; then
  [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  [ -f "$HOME/.local/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ] && source "$HOME/.local/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
fi

# --------------------------------------------
# 7. 历史记录配置
# --------------------------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# --------------------------------------------
# 8. 其他选项
# --------------------------------------------
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NULL_GLOB

# 自动补全配置
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# --------------------------------------------
# 9. 其他工具配置
# --------------------------------------------

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
