-- tokyonight-moon theme for wezterm
-- https://github.com/folke/tokyonight.nvim
return {
    foreground = "#c8d3f5",
    background = "#222436",

    cursor_bg = "#c8d3f5",
    cursor_fg = "#222436",
    cursor_border = "#c8d3f5",

    selection_fg = "#c8d3f5",
    selection_bg = "#2f334d",

    scrollbar_thumb = "#2f334d",
    split = "#1e2030",

    ansi = {
        "#1b1d2b", -- Black
        "#ff757f", -- Red
        "#c3e88d", -- Green
        "#ffc777", -- Yellow
        "#82aaff", -- Blue
        "#c099ff", -- Magenta
        "#86e1fc", -- Cyan
        "#828bb8", -- White
    },
    brights = {
        "#444a73", -- Bright Black
        "#ff8d94", -- Bright Red
        "#c7fb6d", -- Bright Green
        "#ffd8ab", -- Bright Yellow
        "#9ab8ff", -- Bright Blue
        "#caabff", -- Bright Magenta
        "#b2f5f5", -- Bright Cyan
        "#c8d3f5", -- Bright White
    },
    indexed = {
        [16] = "#ff966c", -- Orange
        [17] = "#c53b53", -- Dark Red
    },

    -- Tab bar 颜色配置（深色主题）
    tab_bar = {
        background = "#1e2030",

        active_tab = {
            bg_color = "#222436",
            fg_color = "#c8d3f5",
            intensity = "Normal",
        },

        inactive_tab = {
            bg_color = "#1e2030",
            fg_color = "#565f89",
            intensity = "Normal",
        },

        inactive_tab_hover = {
            bg_color = "#2f334d",
            fg_color = "#c8d3f5",
            intensity = "Normal",
        },

        new_tab = {
            bg_color = "#1e2030",
            fg_color = "#565f89",
        },

        new_tab_hover = {
            bg_color = "#2f334d",
            fg_color = "#c8d3f5",
        },
    },
}
