# Dotfiles

> 个人开发环境配置集合，精心调优，随时可用。

## ✨ 简介

这是我的个人 dotfiles 仓库，托管了日常开发中使用的各种工具配置。

## 🗂️ 配置清单

| 配置目录 | 应用名称 | 应用描述 |
|----------|----------|----------|
| `nvim/` | [Neovim](https://neovim.io) | 基于 LazyVim 的编辑器配置（已 inline） |
| `zed/` | [Zed](https://zed.dev) | 下一代代码编辑器 |
| `wezterm/` | [WezTerm](https://wezfurlong.org/wezterm) | GPU 加速终端模拟器（已 inline） |
| `zsh/` | [Zsh](https://www.zsh.org) | 强大的交互式 Shell |
| `zellij/` | [Zellij](https://zellij.dev) | 终端多路复用器 |
| `mise/` | [Mise](https://mise.jdx.dev) | 开发工具版本管理器 |
| `lazygit/` | [Lazygit](https://github.com/jesseduffield/lazygit) | 终端 Git 客户端 |
| `gh/` | [GitHub CLI](https://cli.github.com) | GitHub 命令行工具 |
| `pip/` | pip | Python 包管理器配置 |
| `uv/` | [uv](https://github.com/astral-sh/uv) | 极速 Python 包管理器 |
| `opencode/` | [Opencode](https://opencode.ai) | AI 编码助手配置 |

### 按类别分组

**📝 编辑器**
- [Neovim](https://neovim.io) - `nvim/`
- [Zed](https://zed.dev) - `zed/`

**💻 终端工具**
- [WezTerm](https://wezfurlong.org/wezterm) - `wezterm/`
- [Zellij](https://zellij.dev) - `zellij/`
- [Zsh](https://www.zsh.org) - `zsh/`

**🔧 开发工具**
- [Mise](https://mise.jdx.dev) - `mise/` - 管理 Node.js、Python 等版本
- [Lazygit](https://github.com/jesseduffield/lazygit) - `lazygit/` - 终端 Git UI
- [GitHub CLI](https://cli.github.com) - `gh/` - GitHub 命令行

**🐍 Python 生态**
- [uv](https://github.com/astral-sh/uv) - `uv/` - 极速包管理器
- pip - `pip/` - 传统包管理器配置

**🤖 AI 工具**
- [Opencode](https://opencode.ai) - `opencode/` - AI 编码助手

## 📦 快速开始

### 支持平台

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

### 一键安装

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

### 大陆网络环境

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
- GitHub release asset (Neovim / WezTerm / Lazygit) → `ghfast.top` 代理
- 可选将系统包源 (apt/dnf/pacman/apk) 切换到 tuna / aliyun

检测依据（任一为真即启用）：`TZ=Asia/Shanghai` 等、`LANG=zh_CN.*`、2 秒内 `github.com` 不可达。显式 flag 优先级最高。

`lib/mirror.sh` 也可以单独 `source` 后让 shell 直接使用镜像变量：

```bash
source ~/.config/lib/mirror.sh --force
brew update   # 现在走 USTC 镜像
```

### macOS 推荐流程 (Brewfile)

```bash
brew bundle --file ~/.config/Brewfile
```

### 更新

```bash
cd ~/.config
git pull --rebase origin main
./install.sh --yes
```

> 历史版本曾使用 git submodule 管理 `nvim/` 和 `wezterm/`；现已直接 inline，clone 不再需要 `--recursive`。

## 🎯 终端使用流程

### 本地开发

```bash
# 1. 打开 WezTerm
# 2. 启动 Zellij（如未自动启动）
zellij attach main --create

# 3. 在 Zellij 内使用 Alt+hjkl 导航 Pane
# 4. 使用 Alt+1-9 切换 Tab
# 5. 需要 lazygit？按 Ctrl+b g（WezTerm 会在新窗口打开）
# 6. 切换项目？按 Ctrl+b f（WezTerm 工作区切换）
```

### SSH 远程开发

```bash
# SSH 后 Zellij 快捷键完全一致
ssh server
zellij attach dev --create

# 所有快捷键与本地相同，无需重新适应
```

## 📝 配置说明

### Zed 编辑器 (`zed/`)

- `settings.json` - 主配置文件（注意：包含个人 SSH 和 AI 配置，需按需修改）
- `keymap.json` - 快捷键映射

**注意**：`settings.json` 中包含了个人 SSH 连接配置和本地 AI 服务地址，使用前请根据你的环境修改。

### WezTerm + Zellij（终端架构）

本配置采用**分层架构**：

| 层级 | 工具 | 职责 |
|------|------|------|
| **窗口层** | WezTerm | 工作区管理、字体/外观、快速启动 |
| **会话层** | Zellij | Pane/Tab 管理、会话恢复、滚动/搜索 |

这种设计避免了"双层分屏"的混乱，且 SSH 远程后快捷键保持一致。

#### WezTerm（`wezterm/`）- 窗口管理

**Leader Key**: `Ctrl+b`

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+b f` | 切换工作区 |
| `Ctrl+b F` | 新建工作区 |
| `Ctrl+b [/]` | 上/下一个工作区 |
| `Ctrl+b g` | 启动 lazygit（新窗口） |
| `Ctrl+b t` | 启动 btop（新窗口） |
| `Ctrl+b z` | 启动 Zellij（main 会话） |
| `Ctrl+b Z` | 启动 Zellij（dev 会话） |
| `Ctrl+b [` | 复制模式 |
| `Cmd +/-` | 调整字体大小 |

#### Zellij（`zellij/`）- 会话管理

**Normal 模式快捷键**（直接可用）：

| 快捷键 | 功能 |
|--------|------|
| `Alt h/j/k/l` | 快速导航 |
| `Alt n` | 新建 Pane |
| `Alt t` | 新建 Tab |
| `Alt x` | 关闭 Pane |
| `Alt f` | 浮动 Pane |
| `Alt 1-9` | 切换 Tab |
| `Alt [/]` | 上/下一个 Tab |

**模式切换**（按后进入对应模式）：

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `Ctrl+p` | Pane | Pane 管理（分屏、导航） |
| `Ctrl+t` | Tab | Tab 管理（新建、切换、重命名） |
| `Ctrl+s` | Scroll | 滚动/搜索（vim 风格按键） |
| `Ctrl+o` | Session | 会话管理（detach、切换） |
| `Ctrl+n` | Resize | 调整 Pane 大小 |
| `Ctrl+m` | Move | 移动 Pane |

**Tmux 兼容模式**：按 `Ctrl+b` 进入（与 WezTerm Leader 一致）

### Zsh (`zsh/`)

- `.zshrc` - Zsh 主配置

### Mise (`mise/`)

- `config.toml` - 工具版本管理配置

默认管理：Node.js、Bun、pnpm、Yarn

### Zellij (`zellij/`)

- `config.kdl` - 终端多路复用器配置

使用类似 Tmux 的键位绑定，默认布局为 compact。

### GitHub CLI (`gh/`)

- `config.yml` - 主配置
- `hosts.yml` - 主机认证信息（**已加入 .gitignore，需手动配置**）

### Opencode (`opencode/`)

- `opencode.json` - 主配置文件（**已加入 .gitignore，需手动配置**）
- `oh-my-opencode.json` - 插件配置

### 容器工具 (`containers/`)

- `containers.conf` - Podman 配置
- `registries.conf` - 镜像仓库配置

## ⚠️ 跨设备注意事项

以下配置包含个人敏感信息或设备特定配置，已加入 `.gitignore`：

| 文件/目录 | 说明 | 处理方式 |
|-----------|------|----------|
| `gh/hosts.yml` | GitHub 认证信息 | 在新设备上运行 `gh auth login` |
| `zed/settings.json` | 包含 SSH 和本地 AI 配置 | 编辑后使用，或创建 `settings.json.example` |
| `opencode/opencode.json` | 包含 API 地址 | 手动创建或复制示例配置 |
| `zsh/.zsh_history` | Shell 历史记录 | 自动生成 |
| `zsh/.zcompdump-*` | 自动补全缓存 | 自动生成 |

## 🔧 环境变量注入

对于包含敏感信息的配置，建议使用环境变量：

### Zed AI 配置示例

在 `settings.json` 中使用环境变量替代硬编码的 API 地址：

```json
{
  "language_models": {
    "openai_compatible": {
      "MyProvider": {
        "api_url": "${OPENAI_API_BASE}"
      }
    }
  }
}
```

然后在 `.zshrc` 或 `.bashrc` 中设置：

```bash
export OPENAI_API_BASE="http://your-api-endpoint/v1"
```

## 🔄 备份与同步建议

1. **核心配置**：本仓库跟踪通用配置
2. **敏感配置**：使用密码管理器或私人仓库管理
3. **大型文件**：Neovim 和 WezTerm 作为子模块，保持独立更新

## 📝 维护说明

`nvim/` 和 `wezterm/` 已 inline 进本仓库（不再使用 submodule）。如需独立的 LazyVim / WezTerm 配置，可参考：

- [freemode1614/nvim](https://github.com/freemode1614/nvim)
- [freemode1614/dot-wezterm](https://github.com/freemode1614/dot-wezterm)

## 🛠️ 故障排除

### Linux 上 Neovim AppImage 启动失败

WSL / 容器内缺少 FUSE：

```bash
# Debian/Ubuntu
sudo apt install fuse3 libfuse2

# Fedora
sudo dnf install fuse
```

### WezTerm 启动报错 (WSL)

在 Windows 主机安装 [WezTerm for Windows](https://wezfurlong.org/wezterm/install/windows.html)，
在 `~/.wezterm.lua` 里加：

```lua
local wsl_domains = { "Ubuntu", "Debian" }
config.default_domain = wsl_domains[1] or "WSL:Ubuntu"
```

### gh CLI 在 WSL 报认证失败

WSL 的 clock 漂移会导致 `gh auth login` 失败，先 `sudo hwclock -s` 同步硬件时钟。

### starship 字符乱码

确保终端字体包含 Nerd Font 字符（推荐 [CaskaydiaCove Nerd Font](https://www.nerdfonts.com/font-downloads)）。

## 🩺 自检 (doctor)

`install.sh` 不修改环境之前会打印 OS / arch / pkg manager。如需深度检查：

```bash
./install.sh --help          # 验证脚本本身
bash -n install.sh           # bash 语法检查
shellcheck install.sh lib/   # 需要安装 shellcheck
```

## 📄 License

MIT © [freemode1614](https://github.com/freemode1614)
