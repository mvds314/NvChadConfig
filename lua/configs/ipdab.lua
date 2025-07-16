local dap = require "dap"

-- Custom DAP adapter for ipdb
dap.adapters.ipdb = {
  type = "server",
  host = "127.0.0.1",
  port = 9000,
}

-- dap.listeners.after.event_initialized["ipdb_mappings"] = function()
--   -- Example: set a mapping for DAP continue
--   vim.api.nvim_set_keymap("n", "<F10>", '<cmd>lua require"dap".continue()<CR>', { noremap = true, silent = true })
--   -- Add more mappings as needed
-- end
--
-- dap.listeners.after.event_terminated["ipdb_mappings"] = function()
--   -- Remove mappings when debugging ends
--   vim.api.nvim_del_keymap("n", "<F10>")
-- end

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
