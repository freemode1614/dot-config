# 故障排除

## Linux 上 Neovim AppImage 启动失败

WSL / 容器内缺少 FUSE：

```bash
# Debian/Ubuntu
sudo apt install fuse3 libfuse2

# Fedora
sudo dnf install fuse
```

## WezTerm 启动报错 (WSL)

在 Windows 主机安装 [WezTerm for Windows](https://wezfurlong.org/wezterm/install/windows.html)，
在 `~/.wezterm.lua` 里加：

```lua
local wsl_domains = { "Ubuntu", "Debian" }
config.default_domain = wsl_domains[1] or "WSL:Ubuntu"
```

## gh CLI 在 WSL 报认证失败

WSL 的 clock 漂移会导致 `gh auth login` 失败，先 `sudo hwclock -s` 同步硬件时钟。

## starship 字符乱码

确保终端字体包含 Nerd Font 字符（推荐 [CaskaydiaCove Nerd Font](https://www.nerdfonts.com/font-downloads)）。

## 安装失败

如果某个步骤失败，可以：

1. 单独运行失败的步骤函数（编辑脚本注释掉其他步骤）
2. 检查网络连接（大陆网络可加 `--china-mirror`）
3. 查看错误日志

## 配置不生效

```bash
# 重新加载 Zsh
source ~/.zshrc

# 或者重启终端
exec zsh
```