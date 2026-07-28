-- kanagawa-lotus theme for wezterm
-- https://github.com/rebelot/kanagawa.nvim
return {
    foreground = "#545464",
    background = "#f2ecbc",

    cursor_bg = "#43436c",
    cursor_fg = "#f2ecbc",
    cursor_border = "#43436c",

    selection_fg = "#43436c",
    selection_bg = "#c9cbd1",

    scrollbar_thumb = "#9c9cbc",
    split = "#c9cbd1",

    ansi = {
        "#1f1f28", -- Black
        "#c84053", -- Red
        "#6f894e", -- Green
        "#debe97", -- Yellow
        "#6e8db4", -- Blue
        "#9c7b9c", -- Magenta
        "#6ca8bd", -- Cyan
        "#e6e0c2", -- White
    },
    brights = {
        "#7a7a87", -- Bright Black
        "#d7474b", -- Bright Red
        "#7e9e45", -- Bright Green
        "#e5b05f", -- Bright Yellow
        "#7aa89f", -- Bright Blue
        "#b391b4", -- Bright Magenta
        "#7eb4c9", -- Bright Cyan
        "#f2ecbc", -- Bright White
    },
    indexed = {
        [16] = "#e98a00", -- Orange
        [17] = "#e82424", -- Red
    },

    -- Tab bar 颜色配置（浅色主题）
    tab_bar = {
        background = "#e4e4c8",

        active_tab = {
            bg_color = "#f2ecbc",
            fg_color = "#545464",
            intensity = "Normal",
        },

        inactive_tab = {
            bg_color = "#e4e4c8",
            fg_color = "#9c9cbc",
            intensity = "Normal",
        },

        inactive_tab_hover = {
            bg_color = "#c9cbd1",
            fg_color = "#545464",
            intensity = "Normal",
        },

        new_tab = {
            bg_color = "#e4e4c8",
            fg_color = "#9c9cbc",
        },

        new_tab_hover = {
            bg_color = "#c9cbd1",
            fg_color = "#545464",
        },
    },
}
