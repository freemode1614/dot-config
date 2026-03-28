# Bootstrap 初始化指南

这个目录包含了一个完整的 dotfiles 初始化系统，用于快速配置新电脑的开发环境。

## 🚀 快速开始

### 方式一：直接运行（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/freemode1614/dot-config/main/install.sh | bash
```

### 方式二：克隆后运行

```bash
# 1. 克隆仓库（包含子模块）
git clone --recursive https://github.com/freemode1614/dot-config.git ~/.config

# 2. 运行安装脚本
cd ~/.config
./install.sh
```

## 📦 安装内容

脚本会自动安装以下工具：

### 🐚 Shell 环境
- **Zsh** - 现代化的 Shell
- **Oh My Zsh** - Zsh 配置框架
- **Powerlevel10k** - 快速、可定制的主题

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
- **Podman** - 容器引擎

### 🤖 AI 工具
- **Opencode** - AI 编码助手

### ✨ 额外工具
- **fzf** - 模糊查找器
- **ripgrep** - 快速搜索工具
- **fd** - 现代化 find 替代
- **bat** - 带语法高亮的 cat
- **eza** - 现代化 ls 替代
- **btop** - 系统资源监视器

## 🎯 使用流程

### 本地开发

1. 打开 WezTerm
2. 启动 Zellij 会话：
   ```bash
   zellij attach main --create
   ```
3. 在 Zellij 中使用快捷键：
   - `Alt+hjkl` - 导航 Pane
   - `Alt+1-9` - 切换 Tab
   - `Ctrl+b g` - 启动 lazygit
   - `Ctrl+b f` - 切换工作区

### SSH 远程开发

```bash
ssh server
zellij attach dev --create
# 所有快捷键与本地完全一致
```

## ⚙️ 安装后配置

### 1. 重新加载 Shell

```bash
source ~/.zshrc
```

### 2. 配置 Powerlevel10k

如果是首次安装，运行：

```bash
p10k configure
```

### 3. 登录 GitHub

```bash
gh auth login
```

### 4. 配置 Zed

Zed 的配置文件 `settings.json` 包含个人 SSH 和 AI 配置，已被 `.gitignore` 忽略。

参考示例创建你的配置：

```bash
cp ~/.config/zed/settings.json.example ~/.config/zed/settings.json
# 编辑 settings.json 添加你的配置
```

### 5. 配置 Opencode

```bash
# 创建配置文件
touch ~/.config/opencode/opencode.json

# 添加你的 API 配置（示例）
cat > ~/.config/opencode/opencode.json << 'EOF'
{
  "api_key": "your-api-key-here",
  "api_base": "https://api.openai.com/v1"
}
EOF
```

### 6. 设置字体

确保在终端设置中将字体更改为 **MesloLGS NF**（Nerd Font），以获得最佳图标显示效果。

## 🗂️ 目录结构

```
~/.config/
├── containers/     # Podman 配置
├── gh/            # GitHub CLI 配置
├── lazygit/       # Lazygit 配置
├── mise/          # Mise 版本管理配置
├── nvim/          # Neovim 配置（子模块）
├── opencode/      # Opencode AI 配置
├── pip/           # pip 配置
├── uv/            # uv Python 配置
├── wezterm/       # WezTerm 配置（子模块）
├── zed/           # Zed 编辑器配置
├── zellij/        # Zellij 配置
└── zsh/           # Zsh 配置
```

## 🔄 更新配置

```bash
cd ~/.config

# 更新主仓库
git pull origin main

# 更新子模块
git submodule update --remote --merge
```

## ⚠️ 注意事项

### 跨设备配置

以下文件包含个人敏感信息或设备特定配置，已被 `.gitignore` 忽略：

| 文件 | 说明 | 处理方式 |
|------|------|----------|
| `gh/hosts.yml` | GitHub 认证 | 运行 `gh auth login` |
| `zed/settings.json` | 个人 SSH 和 AI 配置 | 手动创建或修改 |
| `opencode/opencode.json` | API 配置 | 手动创建 |
| `containers/auth.json` | 镜像仓库认证 | 重新认证 |
| `zsh/.zsh_history` | Shell 历史 | 自动生成 |
| `zsh/.p10k.zsh` | P10k 配置 | 运行 `p10k configure` |

### 子模块

以下配置是 Git 子模块，独立维护：

- `nvim/` - [freemode1614/nvim](https://github.com/freemode1614/nvim)
- `wezterm/` - [freemode1614/dot-wezterm](https://github.com/freemode1614/dot-wezterm)

## 🛠️ 故障排除

### 安装失败

如果某个步骤失败，可以：

1. 单独运行失败的步骤函数（编辑脚本注释掉其他步骤）
2. 检查网络连接
3. 查看错误日志

### 配置不生效

```bash
# 重新加载 Zsh
source ~/.zshrc

# 或者重启终端
exec zsh
```

### 字体显示异常

确保安装了 Nerd Font：

```bash
# macOS
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font
```

然后在终端设置中将字体改为 `MesloLGS NF`。

## 📄 许可

MIT © [freemode1614](https://github.com/freemode1614)
