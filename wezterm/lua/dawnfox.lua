-- dawnfox theme for wezterm
-- https://github.com/EdenEast/nightfox.nvim
return {
    foreground = "#575279",
    background = "#faf4ed",

    cursor_bg = "#575279",
    cursor_fg = "#faf4ed",
    cursor_border = "#575279",

    selection_fg = "#575279",
    selection_bg = "#d0d8d8",

    scrollbar_thumb = "#bdbfc9",
    split = "#286983",

    ansi = {
        "#575279", -- Black
        "#b4637a", -- Red
        "#618774", -- Green
        "#ea9d34", -- Yellow
        "#286983", -- Blue
        "#907aa9", -- Magenta
        "#56949f", -- Cyan
        "#e5e9f0", -- White
    },
    brights = {
        "#625c87", -- Bright Black
        "#c26d85", -- Bright Red
        "#629f81", -- Bright Green
        "#eea846", -- Bright Yellow
        "#2d81a3", -- Bright Blue
        "#9a80b9", -- Bright Magenta
        "#5ca8b4", -- Bright Cyan
        "#f2f4f8", -- Bright White
    },
    indexed = {
        [16] = "#d7827e", -- Peach
        [17] = "#b4637a", -- Pink
    },

    -- Tab bar 颜色配置（浅色主题）
    tab_bar = {
        background = "#ebe5df",
        
        active_tab = {
            bg_color = "#faf4ed",
            fg_color = "#575279",
            intensity = "Normal",
        },
        
        inactive_tab = {
            bg_color = "#ebe5df",
            fg_color = "#a8a3b3",
            intensity = "Normal",
        },
        
        inactive_tab_hover = {
            bg_color = "#d0d8d8",
            fg_color = "#575279",
            intensity = "Normal",
        },
        
        new_tab = {
            bg_color = "#ebe5df",
            fg_color = "#a8a3b3",
        },
        
        new_tab_hover = {
            bg_color = "#d0d8d8",
            fg_color = "#575279",
        },
    },
}
