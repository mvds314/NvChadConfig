--TODO: do more with debugging
return {
  { "epheien/termdbg", cmd = "TermDebug" },
  {
    "mfussenegger/nvim-dap",
    config = function()
      require "configs.codelldb"
    end,
  },
  {
    "mfussenegger/nvim-dap",
  },
  {
    "rcarriga/nvim-dap-ui",
    ft = { "python", "rust" },
    dependencies = {
      "mfussenegger/nvim-dap",
      "LiadOz/nvim-dap-repl-highlights",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      local dapuihl = require "nvim-dap-repl-highlights"
      local nvimtscf = require "nvim-treesitter.configs"
      -- default config for dapui is to not show the elements
      dapui.setup { layouts = { { elements = {}, size = 40, position = "left" } } }
      dapuihl.setup()
      -- require "configs.ipdab"
      nvimtscf.setup {
        highlight = { enable = true },
        ensure_installed = { "dap_repl" },
      }
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
        vim.notify("DAP UI opened", vim.log.levels.INFO, { title = "DAP" })
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
        vim.notify("DAP UI closed before termination", vim.log.levels.INFO, { title = "DAP" })
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
        vim.notify("DAP UI closed before exiting", vim.log.levels.INFO, { title = "DAP" })
      end
      dap.listeners.after.disconnect["dapui_config"] = function()
        dapui.close()
        vim.notify("DAP UI closed after disconnecting", vim.log.levels.INFO, { title = "DAP" })
      end
    end,
  },
  -- {
  --   "mfussenegger/nvim-dap-python",
  --   ft = "python",
  --   dependencies = {
  --     "mfussenegger/nvim-dap",
  --     "rcarriga/nvim-dap-ui",
  --   },
  --   config = function(_, _)
  --     -- local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
  --     local path = "python"
  --     require("dap-python").setup(path)
  --     -- require "configs.ipdab"
  --   end,
  -- },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    -- ft = "python",
    config = function(_, _)
      require("nvim-dap-virtual-text").setup {}
    end,
  },
}
