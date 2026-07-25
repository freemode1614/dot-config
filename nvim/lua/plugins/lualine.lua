return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.sections.lualine_a = {
      {
        "mode",
        fmt = function(str)
          return " " .. str:gsub("%s+", ""):sub(1, 3) .. " "
        end,
      },
    }
    opts.sections.lualine_b = {}
    opts.sections.lualine_c = { { "filename", path = 1 } }
    opts.sections.lualine_x = {
      {
        function()
          local clients = {}
          for _, client in ipairs(vim.lsp.get_clients()) do
            if client.attached_buffers[vim.api.nvim_get_current_buf()] then
              table.insert(clients, client.name)
            end
          end
          local indicator = #clients > 0 and "●" or "○"
          local names = #clients > 0 and table.concat(clients, ", ") or ""
          return indicator .. (names ~= "" and " " .. names or "")
        end,
      },
      "diagnostics",
    }
    opts.sections.lualine_y = { "diff", "branch" }
    opts.sections.lualine_z = {
      function()
        return os.date("%m-%d %a %H:%M")
      end,
    }

    opts.options.disabled_filetypes = {
      statusline = {
        "dashboard",
        "alpha",
        "starter",
        "fzf",
        "ministarter",
        "lazyterm",
        "snacks_dashboard",
        "snacks_explorer",
      },
    }
  end,
}