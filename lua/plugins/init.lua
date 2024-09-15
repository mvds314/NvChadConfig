return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
    ft = { "toml" },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
      -- Toggle load mappings on loading plugin?
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    -- opts = {    },
    config = function(_, _)
      -- https://www.reddit.com/r/neovim/comments/xqogsu/turning_off_treesitter_and_lsp_for_specific_files/
      -- dofile(vim.g.base46_cache .. "syntax")
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "html", "css", "bash", "python", "json", "lua", "vim", "yaml" },
        autoinstall = true,
        highlight = {
          enable = true, -- false will disable the whole extension
          disable = { "tex", "latex" }, -- list of language that will be disabled
          use_languagetree = true,
        },
        -- If you need to change the installation directory of the parsers (see -> Advanced Setup)
        -- parser_install_dir = os.getenv "HOME" .. "/.config/nvim/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!
        indent = { enable = true },
      }
    end,
  },
  ----------------------------- Navigation -----------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzy-native.nvim",
      "SalOrak/whaler",
      "nvim-telescope/telescope-frecency.nvim",
    },
    cmd = { "Telescope", "Telescope whaler" },
    opts = function()
      -- Retrieve NvChad default configuration
      local conf = require "nvchad.configs.telescope"
      local is_windows = vim.fn.has "win64" == 1 or vim.fn.has "win32" == 1 or vim.fn.has "win16" == 1
      local is_linux = vim.fn.has "unix" == 1
      -- And edit it as described here: https://nvchad.com/docs/config/plugins
      conf.extensions_list = { "themes", "terms", "fzy_native", "whaler", "frecency" }
      conf.extensions.fzy_native = { override_generic_sorter = true, override_file_sorter = true }
      if is_windows then
        conf.extensions.whaler = {
          directories = { "C:\\Users\\ROB6027\\Repos" },
          oneoff_directories = { "C:\\Users\\ROB6027\\AppData\\Local\\nvim" },
          file_explorer = "nvimtree",
          auto_file_explorer = false, -- Whether to automatically open file explorer. By default is `true`
          auto_cwd = true, -- Whether to automatically change current working directory. By default is `true`
        }
      elseif is_linux then
        conf.extensions.whaler = {
          directories = { "~/Repos" },
          oneoff_directories = { "~/.config/nvim" },
          file_explorer = "nvimtree",
          auto_file_explorer = false, -- Whether to automatically open file explorer. By default is `true`
          auto_cwd = true, -- Whether to automatically change current working directory. By default is `true`
        }
      end
      return conf
    end,
  },
  -- TODO: Test this plugin
  -- TODO: what alternatives to fzf can we configure in telescope
  {
    "prochri/telescope-all-recent.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "kkharji/sqlite.lua",
      -- Optional, if using telescope for vim.ui.select
      -- "stevearc/dressing.nvim",
    },
    opts = {
      -- Your config goes here
    },
  },
  { "psliwka/vim-smoothie", event = "BufEnter" },
  -- TODO: test this plugin
  -- NOTE: this plugin has conflicting key mappings with substitute.nvim
  -- Maybe event better, load flash.nvim on first use!
  {
    "folke/flash.nvim",
    event = "BufEnter",
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  -- TODO: test this plugin, this plugin does not work, is it because it is lazy loading?
  -- NOTE: this plugin has conflicting key mappings with flash.nvim
  {
    "gbprod/substitute.nvim",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    config = function()
      require("substitute").setup {}
      vim.keymap.set("n", "s", require("substitute").operator, { noremap = true })
      vim.keymap.set("n", "ss", require("substitute").line, { noremap = true })
      vim.keymap.set("n", "S", require("substitute").eol, { noremap = true })
      vim.keymap.set("x", "s", require("substitute").visual, { noremap = true })
    end,
  },
  {
    "ThePrimeagen/harpoon",
    cmd = "Harpoon",
  },
  {
    "stevearc/aerial.nvim",
    ft = "python",
    config = function(_, _)
      local aerial = require "aerial"
      aerial.setup {
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
      }
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "antosha417/nvim-lsp-file-operations" },
    opts = {
      git = {
        enable = true,
      },
      renderer = {
        highlight_git = true,
        icons = {
          show = {
            git = true,
          },
        },
      },
      view = {
        side = "left",
      },
    },
  },
  --TODO: test this plulgin
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    config = function()
      require("oil").setup {
        -- Your configuration comes here
      }
    end,
    opts = {},
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },
  -------------------------------- REPLS --------------------------------
  --TODO: get more out of Iron.nvim
  {
    "Vigemus/iron.nvim",
    ft = "python",
    config = function(_, _)
      local iron = require "iron.core"
      iron.setup {
        config = {
          --  should_map_plug = false,
          scratch_repl = true,
          repl_definition = {
            python = require("iron.fts.python").ipython,
            -- python = {command = { "ipython" }},
            -- sh = {command = { "zsh" }}
          },
          close_winow_on_exit = true,
          repl_open_cmd = "belowright vertical 120 split",
          -- repl_open_cmd = "topleft vertical 120 split",
          buflisted = false,
        },
        keymaps = {
          send_motion = "<space>sc",
          visual_send = "<space>sc",
          send_file = "<space>sf",
          send_line = "<space>sl",
          send_until_cursor = "<space>su",
          send_mark = "<space>sm",
          mark_motion = "<space>mc",
          mark_visual = "<space>mc",
          remove_mark = "<space>md",
          cr = "<space>s<cr>",
          interrupt = "<space>s<space>",
          exit = "<space>sq",
          clear = "<space>cl",
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      }
    end,
  },
  ---------------------------------------- LateX ----------------------------------------
  -- TODO: make inverse search work?
  {
    "lervag/vimtex",
    ft = "tex",
    -- event = "VeryLazy",
    -- Lazy loading breaks inverse search: https://github.com/lervag/vimtex/issues/2763
    lazy = false,
    config = function()
      local is_windows = vim.fn.has "win64" == 1 or vim.fn.has "win32" == 1 or vim.fn.has "win16" == 1
      local is_linux = vim.fn.has "unix" == 1
      if is_windows then
        -- vim.g.vimtex_compiler_progname = "nvr"
        -- vim.g.vimtex_view_method = "nvr"
        vim.g.vimtex_view_general_viewer = "SumatraPDF"
        -- vim.g.vimtex_view_general_view = "C:/Users/ROB6027/AppData/Local/SumatraPDF/SumatraPDF.exe"
        vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
      elseif is_linux then
        vim.g.vimtex_view_general_viewer = "zathura"
      end
    end,
  },
  ------------------------------ Source control ---------------------------------------
  {
    "NeogitOrg/neogit",
    -- lazy = false,
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required
      "nvim-telescope/telescope.nvim", -- Optional
      "sindrets/diffview.nvim", -- Optional
      -- "ibhagwan/fzf-lua", -- optional
    },
    config = true,
    opts = {},
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
    },
  },
  ---------------------------------- Debugging -------------------------------------------
  --TODO: do more with debugging
  { "epheien/termdbg" },
  {
    "mfussenegger/nvim-dap",
  },
  {
    "rcarriga/nvim-dap-ui",
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
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function(_, _)
      -- local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      local path = "python"
      require("dap-python").setup(path)
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    -- ft = "python",
    config = function(_, _)
      require("nvim-dap-virtual-text").setup {}
    end,
  },
  ----------------------------------- Programming stuff -----------------------------------
  -- TODO: make this one work under windows
  {
    "nvim-neotest/neotest",
    ft = "python",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
    },
    config = function(_, _)
      require("neotest").setup {
        adapters = {
          require "neotest-python" {
            dap = {
              justMyCode = false,
              -- console = "integratedTerminal",
            },
            args = { "--log-level", "DEBUG" }, --, "--quiet" },
            runner = "pytest",
            -- python = "~/mypython/bin/python",
          },
        },
      }
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    ft = { "tex", "markdown", "dockerfile", "sh" },
    -- dependencies = { "nvimtools/none-ls-extras.nvim", "ThePrimeagen/refactoring.nvim" },
    opts = function()
      return require "configs.null-ls"
    end,
  },
  -- This one is a bit buggy, e.g., it reformats code in a weird way.
  -- {
  --   "ThePrimeagen/refactoring.nvim",
  --   ft = "python",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   config = function()
  --     require("refactoring").setup()
  --   end,
  -- },
  ---------------------------------------------- Completion ----------------------------------
  {
    "rafamadriz/friendly-snippets",
    enabled = false,
  },
  {
    "github/copilot.vim",
    cmd = { "CopilotChat" },
    event = "BufEnter",
    -- https://github.com/NvChad/NvChad/issues/2020
    config = function()
      -- Mapping tab is already used by NvChad
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ""
      -- The mapping is set to other key, see custom/lua/mappings
      -- or run <leader>ch to see copilot mapping section
    end,
  },
  -- {
  --   "zbirenbaum/copilot.lua",
  --   cmd = "Copilot",
  --   event = "InsertEnter",
  --   config = function()
  --     require("copilot").setup {}
  --   end,
  -- },
  -- TODO: configure this plugin for MS Windows
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      -- { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    -- opts = {
    -- debug = true, -- Enable debugging
    -- See Configuration section for rest
    -- },
    config = function()
      require("CopilotChat").setup {
        debug = true, -- Enable debugging
        -- See Configuration section for rest
      }
    end,
    cmd = {
      "CopilotChat",
      "CopilotChatLoad",
      "CopilotChatToggle",
      "CopilotChatOpen",
      "CopilotChatExplain",
      "CopilotChatReview",
      "CopilotChatFix",
      "CopilotChatOptimize",
      "CopilotChatDocs",
      "CopilotChatTests",
      "CopilotChatFixDiagnostic",
      "CopilotChatCommit",
      "CopilotChatCommitStaged",
    },
  },
  -- TODO: get more out of this plugin, maybe integrate copilot completions into it?
  {
    "hrsh7th/nvim-cmp", -- https://github.com/NvChad/NvChad/discussions/2193
    dependencies = { "rcarriga/cmp-dap" },
    opts = function()
      local conf = require "nvchad.configs.cmp"
      conf.completion = {
        autocomplete = false,
      }
      conf.enabled = function()
        return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or require("cmp_dap").is_dap_buffer()
      end
      require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = {
          { name = "dap" },
        },
      })
      return conf
    end,
  },
  {
    "equalsraf/neovim-gui-shim", --https://github.com/equalsraf/neovim-qt#why-are-the-gui-commands-missing
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
