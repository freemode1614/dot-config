# justfile — dotfiles 维护命令
# 安装: brew install just  OR  cargo install just

# 默认显示帮助
default:
    @just --list

# 检查 shell 脚本语法
check:
    bash -n install.sh
    bash -n lib/platform.sh
    bash -n lib/pkg.sh
    command -v shellcheck >/dev/null && shellcheck -S warning install.sh lib/*.sh || echo "shellcheck 未安装, 已跳过"

# macOS: 用 Brewfile 一键安装
brew-bundle:
    brew bundle --file=Brewfile

# 更新所有内容
update:
    git pull --rebase origin main
    just install

# 重跑安装 (非交互)
install:
    ./install.sh --yes

# 仅创建配置软链 (重跑会先备份已有文件)
symlinks:
    ./install.sh --yes

# 清理 mise 缓存
mise-clean:
    mise cache clear

# 清理 sheldon 插件缓存
sheldon-clean:
    rm -rf ~/.local/share/sheldon
    sheldon lock --update

# 列出安装的工具版本
versions:
    @echo "mise:"
    @mise --version 2>/dev/null || echo "  (not installed)"
    @echo "starship:"
    @starship --version 2>/dev/null || echo "  (not installed)"
    @echo "sheldon:"
    @sheldon --version 2>/dev/null || echo "  (not installed)"

# doctor: 深度自检
doctor:
    @echo "==> Platform"
    @bash -c 'source lib/platform.sh && echo "OS=$OS ARCH=$ARCH PKG_MGR=$PKG_MGR IS_WSL=$IS_WSL"'
    @echo "==> Symlinks"
    @bash -c 'for f in .zshrc .config/mise/config.toml .config/zellij/config.kdl .config/lazygit/config.yml .config/yazi/yazi.toml .config/sheldon/plugins.toml .config/starship.toml; do test -L "$f" && echo "OK $f -> $(readlink $f)" || echo "MISS $f"; done'