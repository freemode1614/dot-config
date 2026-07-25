vim.api.nvim_create_autocmd("BufRead", {
  pattern = { "*" },
  callback = function()
    pcall(vim.cmd.TSBufEnable, "highlight")
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "typescriptreact", "typescript" },
  callback = function()
    vim.b.autoformat = false
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  pattern = { "*" },
  callback = function()
    vim.cmd([[highlight PackageInfoUpToDateVersion guifg=#3C4048]])
    vim.cmd([[highlight PackageInfoOutdatedVersion guifg=#d19a66]])
    vim.cmd([[highlight PackageInfoInvalidVersion guifg=#ee4b2b]])
  end,
})