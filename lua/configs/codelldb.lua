local dap = require "dap"

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = "C:/Users/ROB6027/AppData/Local/nvim-data/mason/packages/codelldb/extension/adapter/codelldb.exe",
    args = { "--port", "${port}" },
  },
}
dap.configurations.rust = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
    end,
    cwd = vim.fn.getcwd(),
    stopOnEntry = false,
  },
}
