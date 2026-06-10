return {
  --------------------------------- LSP type stuff -----------------------------------------------------
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
      require "configs.lspconfig"
      -- Toggle load mappings on loading plugin?
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    -- opts = {},
    config = function(_, _)
      -- The main branch (nvim-treesitter rewrite for Nvim 0.11+) uses a new API.
      -- Highlight and indent are now built-in Neovim features; setup() only configures
      -- the install dir and auto-installs parsers.
      require("nvim-treesitter").setup {}

      -- Auto-install parsers when opening a buffer whose language is not yet installed.
      -- Note: get_lang() always returns something (falls back to the filetype name), so we
      -- must verify the language is actually known to nvim-treesitter before installing.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if lang and not pcall(vim.treesitter.language.inspect, lang) then
            if require("nvim-treesitter.parsers")[lang] then
              require("nvim-treesitter").install { lang }
            end
          end
        end,
      })

      -- Disable treesitter for very large files to avoid slowdowns.
      vim.api.nvim_create_autocmd("BufReadPre", {
        callback = function(args)
          local max_filesize = 1000 * 1024 -- 1000 KB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
          if ok and stats and stats.size > max_filesize then
            vim.treesitter.stop(args.buf)
          end
        end,
      })

      -- Ensure parsers are pre-installed for common languages.
      require("nvim-treesitter").install {
        "c",
        "html",
        "css",
        "bash",
        "python",
        "json",
        "lua",
        "vim",
        "vimdoc",
        "yaml",
        "rust",
      }
      -- Enable highlight and indent via built-in Neovim API.
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup {
        select = {
          lookahead = true,
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "V",
          },
        },
        move = {
          set_jumps = true,
        },
      }

      -- Select textobjects
      for _, mode in ipairs { "x", "o" } do
        vim.keymap.set(mode, "af", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
        end, { desc = "around function" })
        vim.keymap.set(mode, "if", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
        end, { desc = "inside function" })
        vim.keymap.set(mode, "ac", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
        end, { desc = "around class" })
        vim.keymap.set(mode, "ic", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
        end, { desc = "inside class" })
        vim.keymap.set(mode, "aa", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
        end, { desc = "around argument" })
        vim.keymap.set(mode, "ia", function()
          require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
        end, { desc = "inside argument" })
      end

      -- Move to next/prev function
      vim.keymap.set({ "n", "x", "o" }, "]m", function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
      end, { desc = "Next function start" })
      vim.keymap.set({ "n", "x", "o" }, "]M", function()
        require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
      end, { desc = "Next function end" })
      vim.keymap.set({ "n", "x", "o" }, "[m", function()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
      end, { desc = "Prev function start" })
      vim.keymap.set({ "n", "x", "o" }, "[M", function()
        require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
      end, { desc = "Prev function end" })

      -- Swap parameters
      vim.keymap.set("n", "<leader>sp", function()
        require("nvim-treesitter-textobjects.swap").swap_next "@parameter.inner"
      end, { desc = "Swap param next" })
      vim.keymap.set("n", "<leader>sP", function()
        require("nvim-treesitter-textobjects.swap").swap_previous "@parameter.inner"
      end, { desc = "Swap param prev" })
    end,
  },
  {
    "andymass/vim-matchup",
    lazy = false, -- load at startup
    init = function()
      -- Ensure mappings are created and % is overridden
      vim.g.matchup_mappings_enabled = 1
      vim.g.matchup_override_vim = 1
    end,
    config = function()
      -- vim-matchup treesitter integration is enabled via global vars (not nvim-treesitter.configs)
      vim.g.matchup_treesitter_enabled = 1
      -- optional UX/perf
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_timeout = 200
      vim.g.matchup_matchparen_nomode = "i"
      -- Disable for telescope buffers (no treesitter parser for those filetypes)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "TelescopePrompt", "TelescopeResults", "TelescopePreview" },
        callback = function()
          vim.b.matchup_matchparen_enabled = 0
          vim.b.matchup_treesitter_enabled = 0
        end,
      })
    end,
  },
  ----------------------------- Navigation -----------------------------
  -- { "psliwka/vim-smoothie", event = "BufEnter" },
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
      { "<leader>fj", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
      { "<leader>ft", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "<leader>fS", mode = { "n" },           function() require("flash").toggle() end,     desc = "Toggle Flash Search" },
      -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      -- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
    "gbprod/substitute.nvim",
    opts = {},
    -- stylua: ignore
    keys = {
      { "s",  mode = "n", function() require("substitute").operator() end, desc = "Substitute" },
      { "ss", mode = "n", function() require("substitute").line() end,     desc = "Substitute Line" },
      { "S",  mode = "n", function() require("substitute").eol() end,      desc = "Substitute EOL" },
      { "s",  mode = "x", function() require("substitute").visual() end,   desc = "Substitute Visual" },
    },
  },
  {
    "ThePrimeagen/harpoon",
    cmd = "Harpoon",
  },
  {
    "stevearc/aerial.nvim",
    ft = { "python", "lua", "tex", "rust" },
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
  -- Deprecated in favor of togglepy.nvim
  -- {
  --   "Vigemus/iron.nvim",
  --   ft = "python",
  --   config = function(_, _)
  --     local iron = require "iron.core"
  --     iron.setup {
  --       config = {
  --         --  should_map_plug = false,
  --         repl_definition = {
  --           python = {
  --             command = "ipython",
  --             format = function(lines)
  --               -- Automatically enable autoreload
  --               table.insert(lines, 1, "%load_ext autoreload")
  --               table.insert(lines, 2, "%autoreload 2")
  --               return lines
  --             end,
  --           },
  --           -- python = {command = { "ipython" }},
  --           -- sh = {command = { "zsh" }}
  --         },
  --         close_winow_on_exit = true,
  --         -- Setup with repl in new buffline tab
  --         -- scratch_repl = false,
  --         -- buflisted = true,
  --         -- repl_open_cmd = "tabnew",
  --         -- Setup with repl on the side
  --         scratch_repl = true,
  --         buflisted = false,
  --         repl_open_cmd = "belowright vertical 120 split",
  --         -- Other configs
  --         -- repl_open_cmd = "belowright vertical 120 split",
  --         -- repl_open_cmd = "new",
  --         -- repl_open_cmd = require("iron.view").split.vertical.botright(0.5),
  --         -- repl_open_cmd = "vsplit enew win",
  --         -- repl_open_cmd = function()
  --         --   vim.cmd "vsplit" -- Create a vertical split
  --         --   vim.cmd "enew"   -- Open a new empty buffer in the split
  --         --   vim.cmd "wincmd l" -- Move to the right split
  --         --   vim.cmd "enew"   -- Open another new empty buffer in the right split
  --         -- end,
  --       },
  --       keymaps = {
  --         send_motion = "<space>sc",
  --         visual_send = "<space>sc",
  --         send_file = "<space>sf",
  --         send_line = "<space>sl",
  --         send_until_cursor = "<space>su",
  --         send_mark = "<space>sm",
  --         mark_motion = "<space>mc",
  --         mark_visual = "<space>mc",
  --         remove_mark = "<space>md",
  --         cr = "<space>s<cr>",
  --         interrupt = "<space>s<space>",
  --         exit = "<space>sq",
  --         clear = "<space>cl",
  --       },
  --       ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
  --     }
  --   end,
  -- },
  -- Alternative REPLs
  --https://github.com/Olical/conjure
  --https://github.com/hanschen/vim-ipython-cell
  --nvim-terminal
  --neoterm
  --nvim ipy
  --nvim python repl
  ---------------------------------------- LateX ----------------------------------------
  {
    "lervag/vimtex",
    -- Lazy loading breaks inverse search: https://github.com/lervag/vimtex/issues/2763
    lazy = false,
    config = function()
      require "configs.latex"
      -- Leave syntax highlighting to treesitter
      vim.g.vimtex_syntax_enabled = 0
      local is_windows = vim.fn.has "win64" == 1 or vim.fn.has "win32" == 1 or vim.fn.has "win16" == 1
      local is_linux = vim.fn.has "unix" == 1
      if is_windows then
        -- vim.g.vimtex_compiler_progname = "nvr"
        -- vim.g.vimtex_view_method = "nvr"
        vim.g.vimtex_view_general_viewer = "SumatraPDF"
        -- vim.g.vimtex_view_general_view = os.getenv "USERPROFILE" .. "\\AppData\\Local\\SumatraPDF\\SumatraPDF.exe"
        vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
      elseif is_linux then
        vim.g.vimtex_view_general_viewer = "zathura"
      end
    end,
  },
  -- {
  --   "f3fora/nvim-texlabconfig",
  -- config = function()
  --   local config = {
  --     cache_activate = true,
  --     cache_filetypes = { "tex", "bib" },
  --     cache_root = vim.fn.stdpath "cache",
  --     reverse_search_start_cmd = function()
  --       return true
  --     end,
  --     reverse_search_edit_cmd = vim.cmd.edit,
  --     reverse_search_end_cmd = function()
  --       return true
  --     end,
  --     file_permission_mode = 438,
  --   }
  --   require("texlabconfig").setup(config)
  -- end,
  -- ft = { "tex", "bib" }, -- Lazy-load on filetype
  -- build = "go build",
  -- build = 'go build -o ~/.bin/' if e.g. ~/.bin/ is in $PATH
  -- },
  ------------------------------ Source control ---------------------------------------
  {
    "NeogitOrg/neogit",
    -- lazy = false,
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- Required
      "nvim-telescope/telescope.nvim", -- Optional
      "sindrets/diffview.nvim",        -- Optional
      -- "ibhagwan/fzf-lua", -- optional
    },
    config = true,
    opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>gs", mode = 'n', "<cmd>Neogit<CR>",        desc = "Neogit status" },
      { "<leader>gc", mode = 'n', "<cmd>Neogit commit<CR>", desc = "Neogit commit" },
      { "<leader>gp", mode = 'n', "<cmd>Neogit push<CR>",   desc = "Neogit push" },
      { "<leader>gl", mode = 'n', "<cmd>Neogit pull<CR>",   desc = "Neogit pull" },
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
    config = function()
      -- Set keymap to open
      vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { noremap = true, silent = true })
      -- Keymaps for LazyGit buffer only
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "lazygit",
        callback = function(args)
          local buf = args.buf
          local opts = { buffer = buf, noremap = true, silent = true }
          -- close buffer with 'q'
          vim.keymap.set("n", "q", "<cmd>close<CR>", opts)
          -- Remap Esc to work properly in lazygit buffer
          vim.keymap.set({ "i", "n", "t" }, "<Esc>", "<Esc>", opts)
        end,
      })
    end,
  },
  ----------------------------------- Programming stuff -----------------------------------
  -- TODO: get more out of this plugin
  {
    "nvim-neotest/neotest",
    ft = "python",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "rouge8/neotest-rust",
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
            python = "python",
            -- python = "~/mypython/bin/python",
          },
          require "neotest-rust" {
            args = { "--nocapture" }, -- show test output
          },
        },
      }
    end,
    keys = {
      { "<leader>tn", mode = "n", "<cmd>lua require('neotest').run.run()<CR>",        desc = "Run nearest test" },
      {
        "<leader>tf",
        mode = "n",
        "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>",
        desc = "Run all tests in file",
      },
      { "<leader>to", mode = "n", "<cmd>lua require('neotest').output.open()<CR>",    desc = "Open test output" },
      { "<leader>ts", mode = "n", "<cmd>lua require('neotest').summary.toggle()<CR>", desc = "View test summary" },
    },
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
  -- Cargo.toml enhancements
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup()
    end,
  },
  ---------------------------------------------- Completion ----------------------------------
  -- {
  --   "rafamadriz/friendly-snippets",
  --   enabled = false,
  -- },
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
  -- {
  --   "neovim/nvim-lspconfig",
  --   config = function()
  --     require "configs.lspconfig"
  --   end,
  -- },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },

  --------------------------------- Markdown rendering ---------------------------------------------------
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
}
