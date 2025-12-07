return {
  -- Not so useful
  -- { "epheien/termdbg", cmd = "TermDebug" },
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
      dapui.setup()
      dapuihl.setup()
      nvimtscf.setup {
        highlight = { enable = true },
        ensure_installed = { "dap_repl" },
      }
      dap.listeners.after.event_initialized["default_dapui_config"] = function()
        local config = dap.session().config
        if config.name ~= "Attach to ipdab (manual %run)" then
          dapui.open()
        end
      end
      dap.listeners.before.event_terminated["default_dapui_config"] = dapui.close
      dap.listeners.before.event_exited["default_dapui_config"] = dapui.close
      dap.listeners.after.disconnect["default_dapui_config"] = dapui.close
    end,
  },
  -- Deprecated in favor of togglepy.nvim
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
