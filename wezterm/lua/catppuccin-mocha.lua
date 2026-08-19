-- Catppuccin Mocha for WezTerm
-- https://github.com/catppuccin/catppuccin
-- 调色板 hex 值与 zed/nvim/yazi/lazygit 对齐
return {
  foreground = "#cdd6f4",
  background = "#1e1e2e",
  cursor_bg = "#f5e0dc",
  cursor_border = "#f5e0dc",
  cursor_fg = "#1e1e2e",
  selection_bg = "#45475a",
  selection_fg = "#f5e0dc",

  ansi = {
    "#45475a",  -- black
    "#f38ba8",  -- red
    "#a6e3a1",  -- green
    "#f9e2af",  -- yellow
    "#89b4fa",  -- blue
    "#cba6f7",  -- magenta
    "#94e2d5",  -- cyan
    "#bac2de",  -- white
  },

  brights = {
    "#585b70",  -- bright black
    "#f38ba8",  -- bright red
    "#a6e3a1",  -- bright green
    "#f9e2af",  -- bright yellow
    "#89b4fa",  -- bright blue
    "#f5c2e7",  -- bright magenta
    "#94e2d5",  -- bright cyan
    "#a6adc8",  -- bright white
  },

  -- Tab bar (matches titlebar styling)
  tab_bar = {
    background = "#181825",
    inactive_tab = {
      bg_color = "#313244",
      fg_color = "#a6adc8",
    },
    active_tab = {
      bg_color = "#1e1e2e",
      fg_color = "#cdd6f4",
    },
    new_tab = {
      bg_color = "#181825",
      fg_color = "#a6adc8",
    },
  },
}