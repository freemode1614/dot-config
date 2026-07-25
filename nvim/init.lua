# Configuration for neovide
if vim.g.neovide then
    vim.print(vim.g.neovide_version)
    vim.o.guifont = "Maple Mono NF CN:h10"
    vim.g.neovide_scale_factor = 1.35
    vim.g.neovide_window_blurred = true
    vim.g.neovide_cursor_animation_length = 0
    vim.g.neovide_opacity = 0.8
    vim.g.transparency = 1
end

-- bootstrap lazy. nvim, LazyVim and your plugins
require("config.lazy")
