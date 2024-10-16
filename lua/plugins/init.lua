return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform", -- See this file for options set
    ft = {
      "toml",
      "lua",
      "json",
      "yaml",
      "markdown",
      -- "tex",
      "bib",
      "javascript",
      "typescript",
      "graphql",
      "css",
      "html",
    },
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
    -- opts = {},
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
    },
    -- TODO: Test these plugins:
    -- https://github.com/cagve/telescope-texsuite
    -- https://github.com/jackMort/ChatGPT.nvim
    -- https://github.com/paopaol/telescope-git-diffs.nvim
    -- https://github.com/xiyaowong/telescope-emoji.nvim
    -- neoclip
    -- cmd = { "Telescope", "Telescope whaler" },
    lazy = "VeryLazy",
    opts = function()
      -- Retrieve NvChad default configuration
      local conf = require "nvchad.configs.telescope"
      local is_windows = vim.fn.has "win64" == 1 or vim.fn.has "win32" == 1 or vim.fn.has "win16" == 1
      local is_linux = vim.fn.has "unix" == 1
      -- And edit it as described here: https://nvchad.com/docs/config/plugins
      conf.extensions_list = { "themes", "terms", "fzy_native", "whaler" }
      conf.extensions.fzy_native = { override_generic_sorter = true, override_file_sorter = true }
      -- TODO: this doesn't seem to work properly as bot .git and .gitignore are ignored -> test this in Linux
      -- conf.defaults.file_ignore_patterns = { "^.git/*" }
      -- conf.defaults.file_ignore_patterns = { "%.git/" }
      -- conf.defaults.file_ignore_patterns = { "^.git\\*" }
      -- conf.defaults.hidden = true
      if is_windows then
        conf.extensions.whaler = {
          directories = { os.getenv "USERPROFILE" .. "\\Repos" },
          oneoff_directories = { os.getenv "LOCALAPPDATA" .. "\\nvim" },
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
    keys = {
      { "<leader>fd", mode = "n", "<cmd>Telescope whaler<CR>", desc = "Whaler" },
      { "<leader>fr", mode = "n", "<cmd>Telescope resume<CR>", desc = "Resume last search" },
    },
  },
  { "psliwka/vim-smoothie", event = "BufEnter" },
  {
    -- See here for an instructional video: https://www.youtube.com/watch?v=eJ3XV-3uoug
    "folke/flash.nvim",
    config = function()
      vim.cmd [[
      highlight FlashLabel guifg=#e06c75 guibg=#282c34
      highlight FlashMatch guifg=#98c379 guibg=#282c34
      highlight FlashCurrent guifg=#61afef guibg=#282c34
      ]]
    end,
    -- stylua: ignore
    keys = {
      { "<leader>fs", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "<leader>ft", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      -- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
    "gbprod/substitute.nvim",
    -- stylua: ignore
    keys = {
      { "s", mode = "n", function() require("substitute").operator() end, desc = "Substitute" },
      { "ss", mode = "n", function() require("substitute").line() end, desc = "Substitute Line" },
      { "S", mode = "n", function() require("substitute").eol() end, desc = "Substitute EOL" },
      { "s", mode = "x", function() require("substitute").visual() end, desc = "Substitute Visual" },
    },
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
    keys = {
      {
        "<leader>ga",
        mode = "n",
        function()
          local api = require "nvim-tree.api"
          local node = api.tree.get_node_under_cursor()
          local gs = node.git_status.file
          -- If the current node is a directory get children status
          if gs == nil then
            gs = (node.git_status.dir.direct ~= nil and node.git_status.dir.direct[1])
              or (node.git_status.dir.indirect ~= nil and node.git_status.dir.indirect[1])
          end
          -- If the file is untracked, unstaged or partially staged, we stage it
          if gs == "??" or gs == "MM" or gs == "AM" or gs == " M" then
            vim.cmd("silent !git add " .. node.absolute_path)
          -- If the file is staged, we unstage
          elseif gs == "M " or gs == "A " then
            vim.cmd("silent !git restore --staged " .. node.absolute_path)
          end
          api.tree.reload()
        end,
        desc = "Stage/unstage file",
      },
    },
  },
  --TODO: Preview doesn't work because of bug https://github.com/stevearc/oil.nvim/issues/435
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    config = function()
      require("oil").setup {
        -- Your configuration comes here
      }
    end,
    -- lazy = false, -- I don't know how to lazy load this plugin properly!
    cmd = "Oil", -- With this, the plugin lazy loads, but this breaks `nvim .`
    opts = { view_options = { show_hidden = true } },
    keys = {
      { "-", mode = "n", "<cmd>Oil<CR>", desc = "Open parent directory oil" },
    },
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
    -- stylua: ignore
    keys={
      { "<leader>fs", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "<leader>tS", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "<leader>gs", mode = 'n', "<cmd>Neogit<CR>", desc = "Neogit status" },
      { "<leader>gc", mode = 'n', "<cmd>Neogit commit<CR>", desc = "Neogit commit" },
      { "<leader>gp", mode = 'n', "<cmd>Neogit push<CR>", desc = "Neogit push" },
      { "<leader>gl", mode = 'n', "<cmd>Neogit pull<CR>", desc = "Neogit pull" },
      { "<leader>gb", mode = 'n', "<cmd>Neogit branch<CR>", desc = "Neogit branch" },
    },
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
    dependencies = { "nvimtools/none-ls-extras.nvim" },
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
  -- {
  --   "rafamadriz/friendly-snippets",
  --   enabled = false,
  -- },
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
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      -- { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- https://github.com/CopilotC-Nvim/CopilotChat.nvim/issues/375
      allow_insecure = true, -- Allow insecure connections fixes curl problems
      -- debug = true, -- Enable debugging
    },
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
    -- stylua: ignore
    keys = {
      { "<leader>ccq", mode = "n", function()
        local input = vim.fn.input "Quick Chat: "
        if input ~= "" then
          require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
        end
      end, desc = "CopilotChat - Quick chat" },
      { "<leader>cch", mode = "n", function()
        local actions = require "CopilotChat.actions"
        require("CopilotChat.integrations.telescope").pick(actions.help_actions())
      end, desc = "CopilotChat - Help actions" },
      { "<leader>ccp", mode = "n", function()
        local actions = require "CopilotChat.actions"
        require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
      end, desc = "CopilotChat - Prompt actions" },
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
