# 配置详解

## 🎯 终端使用流程

### 本地开发

```bash
# 1. 打开 WezTerm（会尝试自动启动 Zellij）
# 2. 启动 Zellij（如未自动启动）
zellij attach main --create

# 3. 在 Zellij 内使用 Alt+hjkl 导航 Pane
# 4. 使用 Alt+1-9 切换 Tab
# 5. 需要 lazygit？按 Ctrl+b g（WezTerm 会打开新窗口）
# 6. 切换项目？按 Ctrl+b f（WezTerm 工作区切换）
```

### SSH 远程开发

SSH 后 Zellij 快捷键完全一致，无需重新适应：

```bash
ssh server
zellij attach dev --create
```

## 🖥️ 终端架构

本配置采用**分层架构**：

| 层级 | 工具 | 职责 |
|------|------|------|
| **窗口层** | WezTerm | 工作区管理、字体/外观、快速启动 |
| **会话层** | Zellij | Pane/Tab 管理、会话恢复、滚动/搜索 |

### WezTerm leader key: Ctrl+b

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

### Zellij Normal 模式快捷键（直接可用）

| 快捷键 | 功能 |
|--------|------|
| `Alt h/j/k/l` | 快速导航 |
| `Alt n` | 新建 Pane |
| `Alt t` | 新建 Tab |
| `Alt x` | 关闭 Pane |
| `Alt f` | 浮动 Pane |
| `Alt 1-9` | 切换 Tab |
| `Alt [/]` | 上/下一个 Tab |

### Zellij 模式切换

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `Ctrl+p` | Pane | Pane 管理（分屏、导航） |
| `Ctrl+t` | Tab | Tab 管理（新建、切换、重命名） |
| `Ctrl+s` | Scroll | 滚动/搜索（vim 风格按键） |
| `Ctrl+o` | Session | 会话管理（detach、切换） |
| `Ctrl+n` | Resize | 调整 Pane 大小 |
| `Ctrl+m` | Move | 移动 Pane |

**Tmux 兼容模式**：按 `Ctrl+b` 进入（与 WezTerm Leader 一致）

## 📝 各配置说明

### Zed 编辑器 (`zed/`)

- `keymap.json` - 快捷键映射
- `settings.json` - 主配置（包含个人 SSH 和 AI 配置，需按需修改，见 [security.md](security.md)）

### Zsh (`zsh/`)

- `.zshrc` - Zsh 主配置（mise activate、Starship、sheldon）

### Mise (`mise/`)

- `config.toml` - 工具版本管理配置
- 默认管理：Node.js、Bun、pnpm、Yarn

### Zellij (`zellij/`)

- `config.kdl` - 终端多路复用器配置，catppuccin-mocha 主题，默认布局 compact

### WezTerm (`wezterm/`)

- `wezterm.lua` - 主配置（leader key、自动启动 Zellij）
- `lua/catppuccin-mocha.lua` - 主题（与 Zellij / starship 统一）

### GitHub CLI (`gh/`)

- `config.yml` - 主配置
- `hosts.yml` - 主机认证信息（`.gitignore`，需 `gh auth login`）

### Opencode (`opencode/`)

- `opencode.json` - 主配置（`.gitignore`，需手动创建）
- `oh-my-opencode.json` - 插件配置

### 容器工具 (`containers/`)

- `containers.conf` - Podman 配置
- `registries.conf` - 镜像仓库配置