return {
  {
    "mfussenegger/nvim-dap",
    init = function()
      local function project_root()
        local start = vim.api.nvim_buf_get_name(0)
        if start == "" then
          start = vim.fn.getcwd()
        end
        local found = vim.fs.find({ ".git", "pyproject.toml" }, { upward = true, path = start })
        if #found > 0 then
          return vim.fs.dirname(found[1])
        end
        return vim.fn.getcwd()
      end

      vim.api.nvim_create_user_command("DapInitLaunch", function()
        local root = project_root()
        local cfg = {
          version = "0.2.0",
          configurations = {
            {
              type = "python",
              request = "launch",
              name = "Python: FastAPI",
              module = "uvicorn",
              args = { "app.main:app", "--reload", "--host", "0.0.0.0", "--port", "8000" },
              cwd = root,
              jinja = true,
              justMyCode = true,
            },
          },
        }
        vim.fn.mkdir(root .. "/.vscode", "p")
        local f = assert(io.open(root .. "/.vscode/launch.json", "w"))
        f:write(vim.fn.json_encode(cfg))
        f:close()
        vim.cmd("edit " .. root .. "/.vscode/launch.json")
      end, { desc = "Init .vscode/launch.json for FastAPI" })

      vim.keymap.set("n", "<leader>dL", "<cmd>DapInitLaunch<cr>", { desc = "DAP: Init launch.json" })
    end,
  },
}
