# WezTerm vs Zellij 快捷键冲突分析

## 当前配置对比

### WezTerm（Leader: `Ctrl+a`）
| 快捷键 | 功能 |
|--------|------|
| `Ctrl+a + v/s` | 垂直/水平分屏 |
| `Ctrl+a + h/j/k/l` | Pane 导航 |
| `Ctrl+a + c` | 新建 Tab |
| `Ctrl+a + 1-9` | 切换 Tab |
| `Ctrl+a + d` | 开发三栏布局 |
| `Ctrl+a + g` | 打开 lazygit |
| `Ctrl+a + [` | 复制模式 |

### Zellij（Mode-based）
| 快捷键 | 功能 |
|--------|------|
| `Ctrl+p` | 进入 Pane 模式 |
| `Ctrl+t` | 进入 Tab 模式 |
| `Ctrl+s` | 进入 Scroll 模式 |
| `Ctrl+o` | 进入 Session 模式 |
| `Alt+h/j/k/l` | 焦点移动 |
| `Alt+n` | 新建 Pane |

## 冲突分析

### 1. 无直接按键冲突 ✅
WezTerm 使用 `Ctrl+a` 作为 Leader，Zellij 使用 `Ctrl+p/t/s/o`，两者不冲突。

### 2. 功能重叠 ⚠️
两者都提供：
- Pane 分屏和管理
- Tab 管理
- 滚动/复制模式

**问题**：当你在 WezTerm 里运行 Zellij 时，WezTerm 的分屏和 Zellij 的分屏会同时存在，造成"双层分屏"的混乱。

```
WezTerm Window
├── Zellij Session
│   ├── Pane 1 (nvim)
│   ├── Pane 2 (terminal)  ← Zellij 分屏
│   └── Pane 3 (logs)
└── WezTerm Pane 2 (另一个 shell)  ← WezTerm 分屏
```

### 3. 推荐分工

| 层级 | 工具 | 职责 |
|------|------|------|
| **窗口层** | WezTerm | 工作区管理、字体渲染、搜索、外观 |
| **会话层** | Zellij | Pane/Tab 管理、会话恢复、远程连接 |

## 优化方案

### 方案 A：Zellij 为主（推荐）

让 Zellij 接管所有 Pane 和 Tab 管理，WezTerm 只负责窗口和工作区。

**WezTerm 调整：**
- 移除分屏相关快捷键（`v/s/h/j/k/l`）
- 移除 Tab 管理（`c/1-9/n/p`）
- 保留：工作区切换、快速启动工具、外观设置

**Zellij 保持：**
- 所有 Pane/Tab 管理
- 会话管理

**适用场景：**
- 主要在终端内工作（nvim、lazygit 等）
- 需要会话恢复功能
- 经常 SSH 到远程服务器

---

### 方案 B：WezTerm 为主

让 WezTerm 管理所有分屏，Zellij 只作为会话恢复工具。

**Zellij 调整：**
- 禁用 `Ctrl+p/t/s` 等快捷键
- 只保留会话管理功能
- 在 Zellij 内使用单 Pane

**WezTerm 保持：**
- 所有分屏和 Tab 管理

**适用场景：**
- 需要复杂的窗口布局
- 不依赖 Zellij 的会话恢复
- 经常在 Zellij 外工作

---

### 方案 C：混合模式（当前）

保持现状，但明确使用场景：

| 场景 | 使用 |
|------|------|
| 本地开发 | WezTerm 分屏 + Zellij 单 Pane |
| 远程 SSH | Zellij 分屏 |
| 会话恢复 | Zellij |

## 建议

根据你的使用习惯，我推荐 **方案 A（Zellij 为主）**，原因：

1. **更好的会话恢复** - Zellij 的会话恢复比 WezTerm 更完善
2. **远程友好** - SSH 后依然保持相同的快捷键
3. **统一管理** - 不会因为两层分屏而混乱
4. **Detach/Attach** - Zellij 可以在后台保持运行
