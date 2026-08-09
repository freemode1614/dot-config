# Dotfiles

> 个人开发环境配置集合，精心调优，随时可用。

## ✨ 简介

这是我的个人 dotfiles 仓库，托管了日常开发中使用的各种工具配置。
支持 macOS / Linux / WSL，跨架构，内置大陆网络镜像支持。

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

## 📦 快速开始

```bash
# 推荐 (macOS/Linux 通用)
curl -fsSL https://raw.githubusercontent.com/freemode1614/dot-config/main/install.sh | bash -s -- --yes
```

`install.sh` 会自动检测 OS / 架构 / 包管理器，安装基础工具、mise 语言版本、
sheldon 插件、常用应用，并创建幂等软链。详细说明见 [docs/install.md](docs/install.md)，
包括大陆网络镜像、brew 兜底、支持平台列表等。

### 常用命令

```bash
./install.sh --china-mirror --yes   # 大陆网络启用镜像
./install.sh --no-symlinks          # 跳过软链创建
just test                           # 跑单元测试
just ci                             # 全部 check + 测试
```

## 🎯 终端使用流程

本配置采用 **WezTerm（窗口层）+ Zellij（会话层）** 分层架构：

- 打开 WezTerm 即自动启动 Zellij（`main` 会话）
- **Ctrl+b** 为 WezTerm leader key：`g` 启动 lazygit、`f/F` 切换/新建工作区、`z/Z` Zellij 会话
- Zellij 内 **Alt+hjkl** 导航 Pane、**Alt+1-9** 切换 Tab
- SSH 远程开发走 Zellij，快捷键与本地完全一致

完整快捷键表见 [docs/config.md](docs/config.md)。

## 📄 维护

- 安装 / 平台 / 镜像：见 [docs/install.md](docs/install.md)
- 故障排除：见 [docs/troubleshooting.md](docs/troubleshooting.md)
- 跨设备 / 敏感信息 / gitleaks：见 [docs/security.md](docs/security.md)

`nvim/` 和 `wezterm/` 已 inline 进本仓库（不再使用 submodule）。如需独立的
LazyVim / WezTerm 配置，可参考：
[freemode1614/nvim](https://github.com/freemode1614/nvim) 和
[freemode1614/dot-wezterm](https://github.com/freemode1614/dot-wezterm)。

## 📄 License

MIT © [freemode1614](https://github.com/freemode1614)