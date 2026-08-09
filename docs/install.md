# 安装指南

`install.sh` 支持 macOS / Linux / WSL 等桌面环境，自动检测 OS / 架构 / 包管理器。

## 一键安装

```bash
# 推荐 (macOS/Linux 通用)
curl -fsSL https://raw.githubusercontent.com/freemode1614/dot-config/main/install.sh | bash -s -- --yes

# 或者克隆后运行
git clone https://github.com/freemode1614/dot-config.git ~/.config
cd ~/.config
./install.sh
```

`install.sh` 会自动：

1. 检测 OS / 架构 / 包管理器
2. 提示确认安装 (可用 `--yes` 跳过)
3. 安装基础工具 (git, fzf, ripgrep, fd, jq, tree, unzip, starship, eza, bat)
4. 安装 Mise 并按 `mise/config.toml` 安装语言版本
5. 安装 Sheldon 并应用 `sheldon/plugins.toml`
6. 安装 Neovim / WezTerm / Zed / Zellij / Lazygit / gh / Yazi
7. 创建幂等的配置软链 (可用 `--no-symlinks` 跳过)

## 支持平台

| 平台 | 状态 | 备注 |
|------|------|------|
| **macOS** (Apple Silicon / Intel) | ✅ | Homebrew + `Brewfile` |
| **Debian / Ubuntu** (x86_64 / arm64) | ✅ | apt |
| **Fedora / RHEL / Rocky** (x86_64 / arm64) | ✅ | dnf / yum |
| **Arch / Manjaro** | ✅ | pacman |
| **Alpine** | ✅ | apk (musl) |
| **openSUSE / SLE** | ✅ | zypper |
| **WSL 1/2** | ✅ | Ubuntu/Debian 发行版默认走 apt |
| Windows (Git Bash / MSYS) | ❌ | 请用 WSL |
| FreeBSD / OpenBSD | ⚠️ | 部分工具不工作，欢迎 PR |

## 大陆网络环境

如在国内访问 github / homebrew 慢，可启用国内镜像：

```bash
./install.sh --china-mirror --yes
```

启用后会：

- `HOMEBREW_API_DOMAIN` / `HOMEBREW_BOTTLE_DOMAIN` → `mirrors.ustc.edu.cn`
- `npm_config_registry` → `registry.npmmirror.com`
- `PIP_INDEX_URL` → `pypi.tuna.tsinghua.edu.cn`
- `CARGO_REGISTRIES_CRATES_IO_INDEX` → `rsproxy.cn`
- `GOPROXY` → `goproxy.cn,direct`
- GitHub release asset (Neovim / WezTerm / Lazygit / Fonts / Zed) → `ghfast.top` 代理
- 可选将系统包源 (apt/dnf/pacman/apk) 切换到 tuna / aliyun

检测依据（任一为真即启用）：`TZ=Asia/Shanghai` 等、`LANG=zh_CN.*`、2 秒内 `github.com` 不可达。显式 flag 优先级最高。

`lib/mirror.sh` 也可以单独 `source` 后让 shell 直接使用镜像变量：

```bash
source ~/.config/lib/mirror.sh --force
brew update   # 现在走 USTC 镜像
```

## brew 不可用时的兜底

macOS 上 Homebrew 偶尔会出现 Ruby 兼容问题（vendored Ruby 4 + sorbet 报错）。`install.sh` 现在会探测 `brew --version` 是否可用，失败时自动走 `macos_curl_fallback()`：

- Zed：从 `zed-industries/zed` release 拉 dmg → `/Applications/Zed.app`
- WezTerm：从 `wez/wezterm` release 拉 zip → `/Applications/WezTerm.app`
- Font：默认不装（个人偏好），可通过 `--with-font` 或 `INSTALL_FONT=1` 启用，默认 `MapleMono-NF-CN`（中文友好）

> 兜底走 `ghfast.top` 代理，所以大陆网络也能安装。

如果 brew 长期挂掉，可以重装：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## macOS 推荐流程 (Brewfile)

```bash
brew bundle --file ~/.config/Brewfile
```

## 更新

```bash
cd ~/.config
git pull --rebase origin main
./install.sh --yes
```

> 历史版本曾使用 git submodule 管理 `nvim/` 和 `wezterm/`；现已直接 inline，clone 不需要 `--recursive`。

## 自检 (doctor)

`install.sh` 修改环境之前会打印 OS / arch / pkg manager。如需深度检查：

```bash
./install.sh --help          # 验证脚本本身
bash -n install.sh           # bash 语法检查
shellcheck install.sh lib/   # 需要安装 shellcheck
just ci                      # 跑全部 check + 单元测试
```