-- cyberdream theme for wezterm
return {
    foreground = "#ffffff",
    background = "#16181a",

    cursor_bg = "#ffffff",
    cursor_fg = "#16181a",
    cursor_border = "#ffffff",

    selection_fg = "#ffffff",
    selection_bg = "#3c4048",

    scrollbar_thumb = "#16181a",
    split = "#16181a",

    ansi = { "#16181a", "#ff6e5e", "#5eff6c", "#f1ff5e", "#5ea1ff", "#bd5eff", "#5ef1ff", "#ffffff" },
    brights = { "#3c4048", "#ff6e5e", "#5eff6c", "#f1ff5e", "#5ea1ff", "#bd5eff", "#5ef1ff", "#ffffff" },
    indexed = { [16] = "#ffbd5e", [17] = "#ff6e5e" },

    -- Tab bar 颜色配置（深色主题）
    tab_bar = {
        background = "#1a1d1f",
        
        active_tab = {
            bg_color = "#16181a",
            fg_color = "#ffffff",
            intensity = "Normal",
        },
        
        inactive_tab = {
            bg_color = "#1a1d1f",
            fg_color = "#8b9198",
            intensity = "Normal",
        },
        
        inactive_tab_hover = {
            bg_color = "#3c4048",
            fg_color = "#ffffff",
            intensity = "Normal",
        },
        
        new_tab = {
            bg_color = "#1a1d1f",
            fg_color = "#8b9198",
        },
        
        new_tab_hover = {
            bg_color = "#3c4048",
            fg_color = "#ffffff",
        },
    },
}
