local dap = require "dap"

-- Custom DAP adapter for ipdb
dap.adapters.ipdb = {
  type = "server",
  host = "127.0.0.1",
  port = 9000,
}

-- Attach config — does not launch, just connects
dap.configurations.python = dap.configurations.python or {}
table.insert(dap.configurations.python, {
  name = "Attach to ipdb (manual %run)",
  type = "ipdb",
  request = "launch", -- <-- important to say launch here!
  program = "${file}",
  -- request = "attach",
  justMyCode = false,
  cwd = vim.fn.getcwd(),
})
