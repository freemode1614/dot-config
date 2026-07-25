return {
  "f-person/auto-dark-mode.nvim",
  enabled = false,
  lazy = false,
  priority = 1000,
  opts = {
    update_interval = 1000,
    set_dark_mode = function()
      vim.o.background = "dark"
      vim.cmd("colorscheme rose-pine")
    end,
    set_light_mode = function()
      vim.o.background = "light"
      vim.cmd("colorscheme rose-pine")
    end,
  },
}
