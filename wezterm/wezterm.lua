local wezterm = require("wezterm")
local action = wezterm.action

local config = wezterm.config_builder and wezterm.config_builder() or {}

-- 基础设置
config.font = wezterm.font("Maple Mono NF CN")
config.font_size = 14.0
config.line_height = 1.2

config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 20
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.enable_scroll_bar = false
-- 左右 Alt 都直通 zellij (不组合字符), 让 Alt+hjkl 在两侧都生效
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.window_padding = {
    left = 8,
    right = 8,
    top = 8,
    bottom = 8,
}

config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true

config.default_cursor_style = "BlinkingBlock"

config.scrollback_lines = 100000

config.max_fps = 120
config.animation_fps = 60

-- 主题设置
config.colors = require("lua/tokyonight")

config.window_frame = {
    font = wezterm.font({ family = "Maple Mono NF CN", weight = "Bold" }),
    font_size = 12.0,
    active_titlebar_bg = "#131a24",
    inactive_titlebar_bg = "#192330",
}

-- Leader Key (与 zellij tmux 兼容模式同键, 互不冲突)
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
    -- Pane 拆分 / 导航 (在 zellij 内时由 zellij 处理; 这里只作用于 wezterm 窗格)
    { key = "|", mods = "CTRL|SHIFT", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "_", mods = "CTRL|SHIFT", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "H", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Left") },
    { key = "J", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Down") },
    { key = "K", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Up") },
    { key = "L", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Right") },

    -- Leader 快捷键 (与 README/BOOTSTRAP 文档对齐)
    { key = "f", mods = "LEADER", action = "SwitchToWorkspace" },
    { key = "F", mods = "LEADER", action = "RenameWorkspace", args = { "New workspace" } },
    { key = "[", mods = "LEADER", action = "ActivateWorkspaceRelative", args = { -1 } },
    { key = "]", mods = "LEADER", action = "ActivateWorkspaceRelative", args = {  1 } },
    { key = "g", mods = "LEADER", action = "SpawnCommandInNewWindow", args = { "lazygit" } },
    { key = "t", mods = "LEADER", action = "SpawnCommandInNewWindow", args = { "btop" } },
    { key = "z", mods = "LEADER", action = "SpawnCommandInNewWindow", args = { "zellij", "attach", "main", "--create" } },
    { key = "Z", mods = "LEADER", action = "SpawnCommandInNewWindow", args = { "zellij", "attach", "dev",  "--create" } },
    { key = "Insert", mods = "LEADER", action = "ActivateCopyMode" },

    -- 字体调整 (macOS 标准)
    { key = "-", mods = "CMD", action = "DecreaseFontSize" },
    { key = "=", mods = "CMD", action = "IncreaseFontSize" },
    { key = "0", mods = "CMD", action = "ResetFontSize" },
}

config.mouse_bindings = {}

-- 状态栏
wezterm.on("update-status", function(window, pane)
    local cells = {}

    local workspace = window:active_workspace()
    if workspace and workspace ~= "default" then
        table.insert(cells, " workspace: " .. workspace .. " ")
    end

    local time = wezterm.strftime("%H:%M")
    table.insert(cells, " " .. time .. " ")

    local text = table.concat(cells, "│")

    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
    local color_scheme = window:effective_config().resolved_palette

    window:set_right_status(wezterm.format({
        { Background = { Color = "none" } },
        { Foreground = { Color = color_scheme.background } },
        { Text = SOLID_LEFT_ARROW },
        { Background = { Color = color_scheme.background } },
        { Foreground = { Color = color_scheme.foreground } },
        { Text = text },
    }))
end)

-- Tab 标题格式化
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local cwd = tab.active_pane.current_working_dir
    local fp_name = tab.active_pane.foreground_process_name

    local shells = {
        zsh = true, bash = true, fish = true, sh = true, dash = true,
        ksh = true, csh = true, tcsh = true, ash = true, nu = true,
    }

    -- 主标签：cwd 优先，cwd 拿不到时不退到 "N: zsh" 这种废 title
    local main_label
    if cwd then
        main_label = wezterm.basename(cwd)
    else
        main_label = "shell"
    end

    -- 正在跑命令时把命令名拼到后面
    if fp_name and not shells[fp_name] then
        main_label = main_label .. " (" .. wezterm.basename(fp_name) .. ")"
    end

    local fixed_width = 30
    if #main_label > fixed_width then
        main_label = main_label:sub(1, fixed_width - 3) .. "..."
    end

    return {
        { Text = " " .. main_label .. " " },
    }
end)

-- 窗口标题
wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
    local title = tab.active_pane.title
    return title
end)

-- 启动时自动运行 zellij, 匹配 README "打开 WezTerm 即用 Zellij" 流程
wezterm.on("gui-startup", function(cmd)
    -- 仅当 spawn 时直接调 zellij attach; 如已有 session 则 attach main, 没有则 --create
    cmd:SpawnCommandInExistingWindow { args = { "zellij", "attach", "main", "--create" } }
end)

return config
