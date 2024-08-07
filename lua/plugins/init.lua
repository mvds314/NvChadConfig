return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
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
          enable = true,                -- false will disable the whole extension
          disable = { "tex", "latex" }, -- list of language that will be disabled
          use_languagetree = true,
        },
        -- If you need to change the installation directory of the parsers (see -> Advanced Setup)
        -- parser_install_dir = os.getenv "HOME" .. "/.config/nvim/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!
        indent = { enable = true },
      }
    end,
  },
  ----------------------------- Telescope -----------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzy-native.nvim",
      "SalOrak/whaler",
      "nvim-telescope/telescope-frecency.nvim",
    },
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
          auto_cwd = true,            -- Whether to automatically change current working directory. By default is `true`
        }
      elseif is_linux then
        conf.extensions.whaler = {
          directories = { "~/Repos" },
          oneoff_directories = { "~/.config/nvim" },
          file_explorer = "nvimtree",
          auto_file_explorer = false, -- Whether to automatically open file explorer. By default is `true`
          auto_cwd = true,            -- Whether to automatically change current working directory. By default is `true`
        }
      end
      vim.keymap.set("n", "<leader>fd", require("telescope").extensions.whaler.whaler)
      vim.keymap.set("n", "<leader>fr", require("telescope").extensions.frecency.frecency)
      return conf
    end,
  },
  -- TODO: Test this plugin
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
  -------------------------------- REPLS --------------------------------
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
  {
    "marromlam/kitty-repl.nvim",
    ft = "python",
    lazy = false,
    config = function(_, _)
      require("kitty-repl").setup()
      -- nvim_set_keymap('n', '<leader>;r', ':KittyREPLRun<cr>', {})
      -- nvim_set_keymap('x', '<leader>;s', ':KittyREPLSend<cr>', {})
      -- nvim_set_keymap('n', '<leader>;s', ':KittyREPLSend<cr>', {})
      -- nvim_set_keymap('n', '<leader>;c', ':KittyREPLClear<cr>', {})
      -- nvim_set_keymap('n', '<leader>;k', ':KittyREPLKill<cr>', {})
      -- nvim_set_keymap('n', '<leader>;l', ':KittyREPLRunAgain<cr>', {})
      -- nvim_set_keymap('n', '<leader>;w', ':KittyREPLStart<cr>', {})
    end,
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
  { "epheien/termdbg" },
  {
    "lervag/vimtex",
    ft = "tex",
    -- event = "VeryLazy",
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
  { "psliwka/vim-smoothie", lazy = false },
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
  {
    "ThePrimeagen/harpoon",
    cmd = "Harpoon",
  },
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
    lazy = false,
    -- cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- Required
      "nvim-telescope/telescope.nvim", -- Optional
      "sindrets/diffview.nvim",        -- Optional
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
  {
    "mfussenegger/nvim-dap",
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "LiadOz/nvim-dap-repl-highlights", "nvim-neotest/nvim-nio" },
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
    -- "jose-elias-alvarez/null-ls.nvim",
    "nvimtools/none-ls.nvim",
    ft = { "python", "lua", "tex", "json", "yaml", "yml", "markdown", "vimscript", "dockerfile", "sh" },
    dependencies = { "nvimtools/none-ls-extras.nvim", "ThePrimeagen/refactoring.nvim" },
    opts = function()
      return require "configs.null-ls"
    end,
  },
  {
    "ThePrimeagen/refactoring.nvim",
    ft = "python",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup()
    end,
  },
  -- {
  --   "averms/black-nvim",
  --   ft = { "python" },
  --   config = function()
  --     vim.g.black_linelength = 99
  --   end,
  -- },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- "pyright",
        -- "python-lsp-server",
        "jedi-language-server",
        -- "black",
        -- "ruff",
        "ruff-lsp",
        -- "flake8",
        -- "pylint",
        "debugpy",
        "lua-language-server",
        "stylua",
        "texlab",
        -- "ltex-ls",
        "latexindent",
        "codespell",
        "harper-ls",
        -- "vale", -- vale.init not found
        "proselint",
        "json-lsp",
        -- "fixjson",
        --"jsonlint",
        "marksman",
        -- "mdformat",
        "prettierd",
        -- "luasnip",
        "vim-language-server",
        "vint",
        "yaml-language-server",
        -- "yamlfix",
        "taplo", -- TOML LSP: https://taplo.tamasfe.dev/
        "dockerfile-language-server",
        --"azure-pipelines-language-server",
        "hadolint",
        "bash-language-server",
        "shfmt",
      },
    },
  },
  {
    "rafamadriz/friendly-snippets",
    enabled = false,
  },
  {
    "hrsh7th/nvim-cmp", -- https://github.com/NvChad/NvChad/discussions/2193
    opts = {
      completion = {
        autocomplete = false,
      },
    },
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
