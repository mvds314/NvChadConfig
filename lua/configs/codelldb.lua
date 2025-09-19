local dap = require "dap"

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    -- Note Mason automatically adds codelldb to your PATH
    command = vim.fn.exepath "codelldb",
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
