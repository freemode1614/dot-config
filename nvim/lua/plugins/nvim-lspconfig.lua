return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      enabled = false,
    },
    servers = {
      basedpyright = {
        settings = {
          basedpyright = {
            python = {
              -- 优先使用 .venv
              venvPath = ".",
              venv = ".venv",
            },
            disableOrganizeImports = true,
          },
        },
      },
    },
  },
}
