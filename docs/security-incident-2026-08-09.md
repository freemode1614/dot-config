# Security incident response — 凭证 rotate 清单

**时间**：2026-08-09
**事件**：本地仓库的 `zed/settings.json` 和 `zed/settings_1.json` 在 GitHub 公开历史中包含个人敏感信息（SSH 主机别名、Tailscale CGNAT IP、同事用户名+项目路径、AI API endpoint）。

> ⚠️ 本文档**不重复**具体泄露值（用户名 / IP / 主机别名 / API endpoint），
> 以免重新引入敏感数据。原文参见 `git show backup/main-pre-filter:zed/settings.json`
> （如果 backup tag 还存在）或本地 `~/.config/zed/settings.json`（权限 600）。

**状态**：本地 + 远端历史已通过 `git-filter-repo` 清理（commit `211dea9`）。force-push 之前的 commit 仍可能存在于：
- GitHub Events（API 可查但 object 已被 GC）
- 任何 fork / clone / 镜像

## 建议执行的 rotate 操作

按优先级从高到低：

### 🔴 立即（24h 内）

#### 1. 同事沟通

```
跟那位同事说一声:
  之前我在公开 dotfiles 仓库里泄露了你的用户名 + 一条内网项目路径
  (因为 zed ssh_connections 字段配置失误)
  现在历史已清理, 跟你道个歉
  如果你的项目路径涉及敏感信息, 建议:
    - 检查那台机器的访问日志
    - 必要时 rotate 相关凭证
```

#### 2. Tailscale 凭证 rotate

100.64.0.0/10 段的 Tailscale CGNAT IP 即使不暴露外部，
用户名 + 路径的组合可能已被索引（GitHub 代码搜索）。

```bash
# 在 Tailscale 控制台 (https://login.tailscale.com/admin):
# 1. Devices → 找到对应 IP 的设备
# 2. Disable / Re-authenticate 该设备
# 3. 如果是无人值守机器 (server / NAS), 重新生成 auth key
```

#### 3. SSH 主机凭证处理

`host` 是 SSH config 别名（短名），指向的可能是：

```bash
# 查看 ~/.ssh/config 里该别名指向哪里
grep -A5 "^Host <别名>$" ~/.ssh/config

# 如果是密钥认证, rotate:
ssh-keygen -t ed25519 -C "rotated-2026-08-09" -f ~/.ssh/id_ed25519_<别名>_new
# 然后在对应机器上:
#   1. 把新公钥加到 ~/.ssh/authorized_keys
#   2. 从 authorized_keys 删除旧 key
#   3. 验证新 key 能登
#   4. 在 ~/.ssh/config 更新 IdentityFile
```

### 🟠 一周内

#### 4. 检查 GitHub 上的 fork / mirror

- 你的 GitHub 组织/个人页 → 仓库 → Forks（看有没有别人的 fork）
- 如果你或别人启用了 GitHub Archive / push mirror，需联系相关方清理

#### 5. 检查 secrets scanning 服务

```bash
# GitHub 自动 secrets scanning 应已标红, 但旧的 force push 后需要刷新
# 访问 https://github.com/<user>/dot-config/security/secret-scanning
# 如果还有历史告警, 点 Dismiss 或 Create allowlist
```

### 🟢 可选

#### 6. 通知 GitHub 支持（如果数据敏感度极高）

```bash
# 通过 https://support.github.com/contact 申请
# "Remove sensitive data from public repository"
# 提供 commit SHA 和文件路径
# GitHub 会把对应 blob 从 cached objects 中删除
```

## 不要做的事

- ❌ 不要 `git commit --amend` 旧 commit（历史 SHA 已改变，但 GitHub 仍会保留旧对象）
- ❌ 不要相信"只要删 commit 就够了"——GitHub Archive、搜索引擎缓存、第三方镜像都可能保留
- ❌ 不要用同一密钥/凭证在其他服务上

## 备份 tag 状态（注意：可能不是真备份）

```
backup/main-pre-filter          → 当前 main commit (新) ← 不是备份!
backup/multi-platform-pre-filter → 当前 feature/multi-platform commit (新) ← 不是备份
backup/config-cleanup-pre-filter → 当前 feature/config-cleanup commit (新) ← 不是备份
```

git-filter-repo 会把已有 tags 移动到新 commit 上，原始历史已在本机丢失。
真正的恢复需要从外部来源（push 前的 clone、GitHub Events API 等）。

## 教训

1. **dotfiles 仓库不应该有 settings.json** — 应该有 `settings.json.example` + 让用户 cp
2. **`git rm --cached` 不是清理历史** — 只是停止跟踪，历史 commit 仍含数据
3. **`redact_private_values: true`** 应该是 editor 默认值，不是 opt-in
4. **CI 加 gitleaks/trufflehog** 自动扫描 commit 中的 secrets
5. **敏感配置放外部** (1Password CLI / pass / age 加密) 而不是 dotfiles

## 已执行的清理操作（参考）

- `git filter-repo --invert-paths --path zed/settings.json --path zed/settings_1.json --path zed/settings_backup.json --path containers/podman-connections.json --path containers/podman-connections.json.lock --path containers/auth.json --path uv/uv-receipt.json --force`
- `git filter-repo --replace-text <(echo 'USERNAME==>REDACTED') --force`
- `git push --force origin main feature/multi-platform feature/config-cleanup`
- 后续 commit `daef8d2` 加入本文档（值已 redact，不会重新泄露）