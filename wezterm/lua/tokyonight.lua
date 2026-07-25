-- tokyonight storm theme for wezterm
-- https://github.com/folke/tokyonight.nvim
return {
    foreground = "#c0caf5",
    background = "#1a1b26",

    cursor_bg = "#c0caf5",
    cursor_fg = "#1a1b26",
    cursor_border = "#c0caf5",

    selection_fg = "#c0caf5",
    selection_bg = "#2f334d",

    scrollbar_thumb = "#2f334d",
    split = "#16161e",

    ansi = {
        "#15161e", -- Black
        "#f7768e", -- Red
        "#9ece6a", -- Green
        "#e0af68", -- Yellow
        "#7aa2f7", -- Blue
        "#bb9af7", -- Magenta
        "#7dcfff", -- Cyan
        "#a9b1d6", -- White
    },
    brights = {
        "#414868", -- Bright Black
        "#f7768e", -- Bright Red
        "#9ece6a", -- Bright Green
        "#e0af68", -- Bright Yellow
        "#7aa2f7", -- Bright Blue
        "#bb9af7", -- Bright Magenta
        "#7dcfff", -- Bright Cyan
        "#c0caf5", -- Bright White
    },
    indexed = {
        [16] = "#ff9e64", -- Orange
        [17] = "#f7768e", -- Dark Red
    },

    tab_bar = {
        background = "#16161e",

        active_tab = {
            bg_color = "#1a1b26",
            fg_color = "#c0caf5",
            intensity = "Normal",
        },

        inactive_tab = {
            bg_color = "#16161e",
            fg_color = "#565f89",
            intensity = "Normal",
        },

        inactive_tab_hover = {
            bg_color = "#2f334d",
            fg_color = "#c0caf5",
            intensity = "Normal",
        },

        new_tab = {
            bg_color = "#16161e",
            fg_color = "#565f89",
        },

        new_tab_hover = {
            bg_color = "#2f334d",
            fg_color = "#c0caf5",
        },
    },
}