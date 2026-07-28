local transparent = true

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      transparent_background = transparent,
      background = {
        light = "latte",
        dark = "mocha",
      },
      dim_inactive = {
        enabled = true,
        percentage = 0.35,
      },
    },
  },
  {
    "rebelot/kanagawa.nvim",
    opts = {
      theme = "lotus",
      transparent = transparent,
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = transparent,
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = {
      dark_variant = "main",
      light_variant = "dawn",
      transparency = transparent,
      italic_comment = false,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
