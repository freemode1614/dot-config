local wezterm = require("wezterm")
local action = wezterm.action

local config = wezterm.config_builder and wezterm.config_builder() or {}

local is_macos = string.match(wezterm.target_triple(), "apple") ~= nil

-- 基础设置
config.font = wezterm.font("Maple Mono NF CN")
config.font_size = 14.0
config.line_height = 1.2

config.window_close_confirmation = "AlwaysPrompt"
config.window_background_opacity = 0.8
if is_macos then
    config.macos_window_background_blur = 20
end
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

-- 主题设置 (Catppuccin Mocha, 与 zed/nvim/yazi/lazygit 一致)
config.colors = require("lua/catppuccin-mocha")

config.window_frame = {
    font = wezterm.font({ family = "Maple Mono NF CN", weight = "Bold" }),
    font_size = 12.0,
    -- Catppuccin Mocha 配色 (window_frame 不属于 config.colors, 需放在这里)
    active_titlebar_bg = "#1e1e2e",
    inactive_titlebar_bg = "#11111b",
    border_left_color = "#313244",
    border_right_color = "#313244",
    border_top_color = "#313244",
    border_bottom_color = "#313244",
}

config.keys = {
    -- Ctrl+Shift 拆分 / 导航 (在 zellij 内时由 zellij 处理; 这里只作用于 wezterm 窗格)
    { key = "|", mods = "CTRL|SHIFT", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "_", mods = "CTRL|SHIFT", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "H", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Left") },
    { key = "J", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Down") },
    { key = "K", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Up") },
    { key = "L", mods = "CTRL|SHIFT", action = action.ActivatePaneDirection("Right") },

    -- 字体调整 (跨平台)
    { key = "-", mods = "CMD", action = "DecreaseFontSize" },
    { key = "=", mods = "CMD", action = "IncreaseFontSize" },
    { key = "0", mods = "CMD", action = "ResetFontSize" },
    { key = "-", mods = "CTRL", action = "DecreaseFontSize" },
    { key = "=", mods = "CTRL", action = "IncreaseFontSize" },
    { key = "0", mods = "CTRL", action = "ResetFontSize" },
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
    -- 无显式命令时直接跑 zellij attach main (没有 session 则 --create)
    if not cmd then
        cmd = { args = { "zellij", "attach", "main", "--create" } }
    end
    wezterm.mux.spawn_window(cmd)
end)

return config
