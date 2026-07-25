-- cyberdream light theme for wezterm
-- 优化对比度，确保浅色文字在浅色背景下清晰可见

return {
    -- 前景色（主要文字）- 深色确保清晰
    foreground = "#1a1a1a",

    -- 背景色 - 柔和的米灰白色，减少刺眼感
    background = "#e8e4df",

    -- 光标颜色
    cursor_bg = "#1a1a1a",
    cursor_fg = "#e8e4df",
    cursor_border = "#1a1a1a",

    -- 选中文本颜色
    selection_fg = "#1a1a1a",
    selection_bg = "#c8c4bf",

    -- 滚动条和分割线
    scrollbar_thumb = "#b8b4af",
    split = "#c8c4bf",

    -- ANSI 颜色（16色）
    -- 修正：黑色应该是深色，不是白色！
    ansi = {
        "#3d3d3d", -- Black (0) - 改为深灰色，确保可见
        "#d32f2f", -- Red (1) - 稍微调暗增强对比
        "#388e3c", -- Green (2)
        "#f57c00", -- Yellow (3) - 使用橙色替代黄色，在浅色背景更清晰
        "#1976d2", -- Blue (4)
        "#7b1fa2", -- Magenta (5)
        "#00838f", -- Cyan (6)
        "#212121", -- White (7) - 实际是灰色，作为前景色
    },

    -- Bright ANSI 颜色（加亮版本）
    brights = {
        "#616161", -- Bright Black (8) - 中等灰色，确保在浅色背景可见
        "#e53935", -- Bright Red (9)
        "#43a047", -- Bright Green (10)
        "#fb8c00", -- Bright Yellow (11)
        "#1e88e5", -- Bright Blue (12)
        "#8e24aa", -- Bright Magenta (13)
        "#00acc1", -- Bright Cyan (14)
        "#000000", -- Bright White (15) - 纯黑，确保最大对比
    },

    -- 索引颜色（额外颜色）
    indexed = {
        [16] = "#ff6d00", -- 亮橙色
        [17] = "#ff1744", -- 亮红色
    },

    -- 额外配置：加粗文字颜色
    -- bold = {
    --     foreground = "#000000",
    -- },

    -- Tab bar 颜色配置（浅色主题）
    tab_bar = {
        -- 背景色
        background = "#d8d4cf",
        
        -- 激活的 tab
        active_tab = {
            bg_color = "#e8e4df",
            fg_color = "#1a1a1a",
            intensity = "Normal",
        },
        
        -- 非激活的 tab
        inactive_tab = {
            bg_color = "#d8d4cf",
            fg_color = "#616161",
            intensity = "Normal",
        },
        
        -- 非激活 tab 悬停
        inactive_tab_hover = {
            bg_color = "#c8c4bf",
            fg_color = "#1a1a1a",
            intensity = "Normal",
        },
        
        -- 新建 tab 按钮
        new_tab = {
            bg_color = "#d8d4cf",
            fg_color = "#616161",
        },
        
        -- 新建 tab 按钮悬停
        new_tab_hover = {
            bg_color = "#c8c4bf",
            fg_color = "#1a1a1a",
        },
    },
}
