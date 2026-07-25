-- nightfox theme for wezterm
-- https://github.com/EdenEast/nightfox.nvim
return {
    foreground = "#cdcecf",
    background = "#192330",

    cursor_bg = "#cdcecf",
    cursor_fg = "#192330",
    cursor_border = "#cdcecf",

    selection_fg = "#cdcecf",
    selection_bg = "#2b3b51",

    scrollbar_thumb = "#2b3b51",
    split = "#719cd6",

    ansi = {
        "#393b44", -- Black
        "#c94f6d", -- Red
        "#81b29a", -- Green
        "#dbc074", -- Yellow
        "#719cd6", -- Blue
        "#9d79d6", -- Magenta
        "#63cdcf", -- Cyan
        "#dfdfe0", -- White
    },
    brights = {
        "#575860", -- Bright Black
        "#d16983", -- Bright Red
        "#8ebaa4", -- Bright Green
        "#e0c989", -- Bright Yellow
        "#86abdc", -- Bright Blue
        "#baa1e2", -- Bright Magenta
        "#7ad5d6", -- Bright Cyan
        "#e4e4e5", -- Bright White
    },
    indexed = {
        [16] = "#f4a261", -- Orange
        [17] = "#d67ad2", -- Pink
    },

    -- Tab bar 颜色配置（深色主题）
    tab_bar = {
        background = "#131a24",
        
        active_tab = {
            bg_color = "#192330",
            fg_color = "#cdcecf",
            intensity = "Normal",
        },
        
        inactive_tab = {
            bg_color = "#131a24",
            fg_color = "#71839b",
            intensity = "Normal",
        },
        
        inactive_tab_hover = {
            bg_color = "#2b3b51",
            fg_color = "#cdcecf",
            intensity = "Normal",
        },
        
        new_tab = {
            bg_color = "#131a24",
            fg_color = "#71839b",
        },
        
        new_tab_hover = {
            bg_color = "#2b3b51",
            fg_color = "#cdcecf",
        },
    },
}
