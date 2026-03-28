# Dotfiles

> 个人开发环境配置集合，精心调优，随时可用。

## ✨ 简介

这是我的个人 dotfiles 仓库，托管了日常开发中使用的各种工具配置。

## 🗂️ 配置清单

| 配置目录 | 应用名称 | 应用描述 |
|----------|----------|----------|
| `nvim/` | [Neovim](https://neovim.io) | 基于 LazyVim 的编辑器配置（子模块） |
| `zed/` | [Zed](https://zed.dev) | 下一代代码编辑器 |
| `wezterm/` | [WezTerm](https://wezfurlong.org/wezterm) | GPU 加速终端模拟器（子模块） |
| `zsh/` | [Zsh](https://www.zsh.org) | 强大的交互式 Shell |
| `zellij/` | [Zellij](https://zellij.dev) | 终端多路复用器 |
| `mise/` | [Mise](https://mise.jdx.dev) | 开发工具版本管理器 |
| `lazygit/` | [Lazygit](https://github.com/jesseduffield/lazygit) | 终端 Git 客户端 |
| `gh/` | [GitHub CLI](https://cli.github.com) | GitHub 命令行工具 |
| `pip/` | pip | Python 包管理器配置 |
| `uv/` | [uv](https://github.com/astral-sh/uv) | 极速 Python 包管理器 |
| `containers/` | [Podman](https://podman.io) | 无守护进程容器引擎 |
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

**🐳 容器化**
- [Podman](https://podman.io) - `containers/` - 容器引擎配置

**🤖 AI 工具**
- [Opencode](https://opencode.ai) - `opencode/` - AI 编码助手

## 📦 快速开始

### 克隆仓库

```bash
# 完整克隆（包含子模块）
git clone --recursive https://github.com/freemode1614/dot-config.git ~/.config

# 或分开克隆
```bash
git clone https://github.com/freemode1614/dot-config.git ~/.config
cd ~/.config
git submodule update --init --recursive
```

### 更新子模块

```bash
git submodule update --remote --merge
```

## 📝 配置说明

### Zed 编辑器 (`zed/`)

- `settings.json` - 主配置文件（注意：包含个人 SSH 和 AI 配置，需按需修改）
- `keymap.json` - 快捷键映射

**注意**：`settings.json` 中包含了个人 SSH 连接配置和本地 AI 服务地址，使用前请根据你的环境修改。

### WezTerm (`wezterm/`)

- `wezterm.lua` - 主配置文件
- `lua/` - 主题和外观配置

**注意**：状态栏显示了用户名，可根据需要修改 `wezterm.lua` 中的状态栏文本。

### Zsh (`zsh/`)

- `.zshrc` - Zsh 主配置
- `.p10k.zsh` - Powerlevel10k 主题配置

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
| `containers/auth.json` | 镜像仓库认证 | 在新设备上重新认证 |
| `zsh/.zsh_history` | Shell 历史记录 | 自动生成 |
| `zsh/.zcompdump-*` | 自动补全缓存 | 自动生成 |
| `zsh/.p10k.zsh` | Powerlevel10k 配置 | 运行 `p10k configure` 生成 |

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

## 📝 子模块说明

| 子模块 | 来源仓库 |
|--------|----------|
| `nvim` | [freemode1614/nvim](https://github.com/freemode1614/nvim) |
| `wezterm` | [freemode1614/dot-wezterm](https://github.com/freemode1614/dot-wezterm) |

## 📄 License

MIT © [freemode1614](https://github.com/freemode1614)
