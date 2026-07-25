-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- vim.o.background = "light"
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.lazyvim_picker = "snacks"

if vim.g.neovide then
  vim.o.guifont = "Mononoki Nerd Font Mono:h14" -- text below applies for VimScript
  vim.g.neovide_padding_top = 4
  vim.g.neovide_padding_bottom = 4
  vim.g.neovide_padding_right = 4
  vim.g.neovide_padding_left = 4
  vim.g.neovide_window_blurred = true
end
