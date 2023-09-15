local plugins = {
  {
    "Vigemus/iron.nvim",
    ft = "python",
    config = function(_, opts)
      local iron = require "iron.core"
      iron.setup {
        config = {
          --  should_map_plug = false,
          --  scratch_repl = true,
          repl_definition = {
            python = {
              command = { "ipython" },
              -- format = require("iron.fts.common").bracketed_paste,
            },
            --      sh = {command = { "zsh" }}
          },
          repl_open_cmd = "topleft vertical 100 split",
        },
        --  keymaps = {send_motion = "ctr",},
      }
    end,
  },
  { "epheien/termdbg" },
  { "lervag/vimtex", ft = "tex", event = "VeryLazy" },
  { "psliwka/vim-smoothie", lazy = false },
  {
    "github/copilot.vim",
    -- https://github.com/NvChad/NvChad/issues/2020
    lazy = false,
    config = function()
      -- Mapping tab is already used by NvChad
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ""
      -- The mapping is set to other key, see custom/lua/mappings
      -- or run <leader>ch to see copilot mapping section
    end,
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      -- "nvim-telescope/telescope.nvim", -- optional
      "sindrets/diffview.nvim", -- optional
      -- "ibhagwan/fzf-lua",              -- optional
    },
    config = true,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "LiadOz/nvim-dap-repl-highlights" },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      local dapuihl = require "nvim-dap-repl-highlights"
      local nvimtscf = require "nvim-treesitter.configs"
      dapui.setup()
      dapuihl.setup()
      nvimtscf.setup {
        highlight = { enable = true },
        ensure_installed = { "dap_repl" },
      }
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "mfussenegger/nvim-dap",
    config = function(_, opts)
      require("core.utils").load_mappings "dap"
    end,
  },
  -- {
  --   "MunifTanjim/prettier.nvim",
  --   ft = { "json", "yaml", "markdown" },
  --   config = function(_, opts)
  --     require("prettier").setup {
  --       bin = "prettierd",
  --       filetypes = {
  --         "css",
  --         "graphql",
  --         "html",
  --         "javascript",
  --         "javascriptreact",
  --         "json",
  --         "less",
  --         "markdown",
  --         "scss",
  --         "typescript",
  --         "typescriptreact",
  --         "yaml",
  --       },
  --     }
  --   end,
  -- },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function(_, opts)
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(path)
      require("core.utils").load_mappings "dap_python"
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    ft = { "python", "lua", "tex", "json", "yaml", "yml", "markdown", "vimscript" },
    opts = function()
      return require "custom.configs.null-ls"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "pyright",
        "black",
        "debugpy",
        "lua-language-server",
        "stylua",
        "texlab",
        -- "ltex-ls",
        "latexindent",
        "json-lsp",
        "fixjson",
        --"jsonlint",
        "marksman",
        "mdformat",
        -- "prettierd",
        "vim-language-server",
        "vint",
        "yaml-language-server",
        "yamlfix",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "html", "css", "bash", "python", "latex", "json", "lua", "vim", "yaml" },
    },
    config = function(_, opts)
      -- https://www.reddit.com/r/neovim/comments/xqogsu/turning_off_treesitter_and_lsp_for_specific_files/
      dofile(vim.g.base46_cache .. "syntax")
      require("nvim-treesitter.configs").setup {
        highlight = {
          enable = true, -- false will disable the whole extension
          disable = { "tex", "latex" }, -- list of language that will be disabled
          use_languagetree = true,
        },
        indent = { enable = true },
      }
    end,
  },
  {
    "hrsh7th/nvim-cmp", -- https://github.com/NvChad/NvChad/discussions/2193
    opts = {
      completion = {
        autocomplete = false,
      },
    },
  },
}
return plugins
