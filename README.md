# dotfiles

> 个人开发环境配置文件，精心调优，随时可用。

## ✨ 简介

这是我的个人 dotfiles 仓库，托管了日常开发中使用的各种工具配置。

## 🗂️ 配置清单

| 目录 | 工具 | 说明 |
|------|------|------|
| `nvim/` | [Neovim](https://neovim.io) | 基于 LazyVim 的编辑器配置 |
| `zed/` | [Zed](https://zed.dev) | 下一代代码编辑器 |
| `wezterm/` | [WezTerm](https://wezfurlong.org/wezterm) | GPU 加速终端模拟器 |
| `fish/` | [Fish](https://fishshell.com) | 友好的交互式 Shell |
| `zellij/` | [Zellij](https://zellij.dev) | 终端多路复用器 |
| `omf/` | [Oh My Fish](https://github.com/oh-my-fish/oh-my-fish) | Fish Shell 框架 |
| `mise/` | [Mise](https://mise.jdx.dev) | 开发工具版本管理 |
| `lazygit/` | [Lazygit](https://github.com/jesseduffield/lazygit) | 终端 Git 客户端 |
| `gh/` | [GitHub CLI](https://cli.github.com) | GitHub 命令行工具 |
| `uv/` | [uv](https://github.com/astral-sh/uv) | Python 包管理器 |
| `pip/` | pip | Python 包管理器配置 |
| `containers/` | Podman | 容器工具配置 |
| `avante.nvim/` | [Avante.nvim](https://github.com/yetone/avante.nvim) | Neovim AI 助手 |
| `opencode/` | Opencode | AI 编码助手 |

## 📦 快速开始

### 克隆

```bash
git clone --recursive https://github.com/freemode1614/dotfiles.git ~/.config
```

或分开克隆子模块：

```bash
git clone https://github.com/freemode1614/dotfiles.git ~/.config
cd ~/.config
git submodule update --init --recursive
```

### 更新子模块

```bash
git submodule update --remote --merge
```

## 📝 子模块说明

本仓库包含以下 Git 子模块：

| 子模块 | 来源仓库 |
|--------|----------|
| `nvim` | [freemode1614/nvim](https://github.com/freemode1614/nvim) |
| `wezterm` | [freemode1614/dot-wezterm](https://github.com/freemode1614/dot-wezterm) |

## ⚠️ 注意事项

- 使用前建议检查各配置文件，根据个人需求调整
- 确保已安装对应的工具程序
- 建议先备份原有配置

## 📄 License

MIT © [freemode1614](https://github.com/freemode1614)
