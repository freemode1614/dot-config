# Bootstrap 初始化指南

这个目录包含了一套完整的 dotfiles 初始化系统，用于快速配置新电脑的开发环境。

## 🚀 快速开始

```bash
curl -fsSL https://raw.githubusercontent.com/freemode1614/dot-config/main/install.sh | bash -s -- --yes
```

详细安装说明（支持平台 / 大陆镜像 / brew 兜底）见 [docs/install.md](docs/install.md)。

## 📦 安装内容

脚本会自动安装以下工具：

### 🐚 Shell 环境
- **Zsh** - 现代化的 Shell
- **Sheldon** - Zsh 插件管理器（含 pure prompt）

### 📝 编辑器
- **Neovim** - 基于 LazyVim 的配置
- **Zed** - 下一代代码编辑器

### 🖥️ 终端工具
- **WezTerm** - GPU 加速终端模拟器
- **Zellij** - 终端复用器（替代 Tmux）

### 🔧 开发工具
- **Mise** - 开发工具版本管理器（Node.js, Python, Bun 等）
- **Lazygit** - 终端 Git UI
- **GitHub CLI** - GitHub 命令行工具
- **uv** - 极速 Python 包管理器

### 🤖 AI 工具
- **Opencode** - AI 编码助手

### ✨ 额外工具
- **fzf** - 模糊查找器
- **ripgrep** - 快速搜索工具
- **fd** - 现代化 find 替代
- **bat** - 带语法高亮的 cat
- **eza** - 现代化 ls 替代
- **yazi** - 终端文件管理器

## ⚙️ 安装后配置

### 1. 重新加载 Shell

```bash
source ~/.zshrc
```

### 2. 登录 GitHub

```bash
gh auth login
```

### 3. 配置 Zed

`zed/settings.json` 包含个人 SSH 和 AI 配置，已被 `.gitignore` 忽略。参考示例创建：

```bash
cp ~/.config/zed/settings.json.example ~/.config/zed/settings.json
# 编辑 settings.json 添加你的配置
```

### 4. 配置 Opencode

```bash
touch ~/.config/opencode/opencode.json
# 添加你的 API 配置
```

> 更多敏感信息处理方式见 [docs/security.md](docs/security.md)。

## 🗂️ 目录结构

```
~/.config/
├── docs/          # 文档 (安装/安全/故障排除)
├── gh/            # GitHub CLI 配置
├── lazygit/       # Lazygit 配置
├── lib/           # 安装脚本公共库 (platform/pkg/mirror)
├── mise/          # Mise 版本管理配置
├── nvim/          # Neovim 配置
├── opencode/      # Opencode AI 配置
├── pip/           # pip 配置
├── sheldon/       # Sheldon 插件配置
├── starship.toml  # Starship prompt 配置
├── tests/         # 单元测试
├── uv/            # uv Python 配置
├── wezterm/       # WezTerm 配置
├── yazi/          # Yazi 文件管理器配置
├── zed/           # Zed 编辑器配置
├── zellij/        # Zellij 配置
└── zsh/           # Zsh 配置
```

## 🔄 更新配置

```bash
cd ~/.config
git pull --rebase origin main   # 更新主仓库
./install.sh --yes              # 重跑安装 (刷新 mise tools / sheldon)
```

> `nvim/` 与 `wezterm/` 已 inline（不再使用子模块），clone 无需 `--recursive`。

## 📄 许可

MIT © [freemode1614](https://github.com/freemode1614)