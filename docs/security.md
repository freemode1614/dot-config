# 跨设备与敏感信息

## 跨设备注意事项

以下配置包含个人敏感信息或设备特定配置，已加入 `.gitignore`：

| 文件/目录 | 说明 | 处理方式 |
|-----------|------|----------|
| `gh/hosts.yml` | GitHub 认证信息 | 在新设备上运行 `gh auth login` |
| `zed/settings.json` | 包含 SSH 和本地 AI 配置 | 编辑后使用，或创建 `settings.json.example` |
| `opencode/opencode.json` | 包含 API 地址 | 手动创建或复制示例配置 |
| `zsh/.zsh_history` | Shell 历史记录 | 自动生成 |
| `zsh/.zcompdump-*` | 自动补全缓存 | 自动生成 |

## 环境变量注入

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

## 备份与同步建议

1. **核心配置**：本仓库跟踪通用配置
2. **敏感配置**：使用密码管理器或私人仓库管理
3. **安全审计**：本仓库使用 [gitleaks](https://github.com/gitleaks/gitleaks) 通过 CI 扫描每个 commit，防止敏感数据入库；本地也可以用 `gitleaks detect` 自查