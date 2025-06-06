local dap = require "dap"

-- Custom DAP adapter for ipdb
dap.adapters.ipdb = {
  type = "server",
  host = "127.0.0.1",
  port = 9000,
}

-- Attach config — does not launch, just connects
table.insert(dap.configurations.python, {
  name = "Attach to ipdb (manual %run)",
  type = "ipdb",
  request = "attach",
  justMyCode = false,
})
