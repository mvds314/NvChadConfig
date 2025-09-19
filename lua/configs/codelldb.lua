local dap = require "dap"

-------------------------------- Debugger configuration --------------------------------
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    -- Note Mason automatically adds codelldb to your PATH
    command = vim.fn.exepath "codelldb",
    args = { "--port", "${port}" },
  },
  initialize_timeout_sec = 20, -- Wait up to 20 seconds for the adapter to start
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

-------------------------------- Set up commands and mappings --------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(args)
    local buf = args.buf
    local opts = { buffer = buf, noremap = true, silent = true }
    vim.keymap.set(
      { "n", "i", "v" },
      "<F5>",
      "<cmd> DapContinue <CR>",
      vim.tbl_extend("force", opts, { desc = "Run/Continue" })
    )
    vim.keymap.set("n", "<F10>", "<cmd> DapStepOver <CR>", vim.tbl_extend("force", opts, { desc = "Step over" }))
    vim.keymap.set("n", "<F11>", "<cmd> DapStepInto <CR>", vim.tbl_extend("force", opts, { desc = "Step into" }))
    vim.keymap.set("n", "<S-F11>", "<cmd> DapStepOut <CR>", vim.tbl_extend("force", opts, { desc = "Step out/return" }))
  end,
})
