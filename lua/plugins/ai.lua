return {
  {
    "zbirenbaum/copilot.lua",
    -- Optional: NES support (multi-line, diff-based suggestions) requires Copilot LSP:
    dependencies = { "copilotlsp-nvim/copilot-lsp" }, -- required for NES
    cmd = { "Copilot", "CopilotChat", "AvanteAsk" },
    event = "InsertEnter", -- lazy load when you start typing
    priority = 1000, -- make sure to load before other plugins (e.g. avante)
    build = ":Copilot auth", -- will prompt login on first install
    opts = {
      -- Keep ghost-text off if you prefer nvim-cmp (see section 3), or enable here:
      suggestion = {
        enabled = true, -- set to false if you’ll use copilot-cmp
        auto_trigger = true,
        -- Don’t bind <Tab> (NvChad uses it). We’ll map our own keys in config below.
        keymap = {
          accept = "<C-e>",
          next = "<M-]>", -- similar to LazyVim defaults
          prev = "<M-[>",
        },
      },
      panel = { enabled = false }, -- minimal UI; enable if you want the side panel
      -- TODO: enable NES, but fix it with an appropriate keymap that works well without conflicts
      -- NES requires copilot-lsp; disable both together if Mullvad tracker blocking causes issues
      nes = {
        enabled = false,
        auto_trigger = false,
        keymap = {
          accept_and_goto = "<C-a>",
          dismiss = "<C-q>",
          accept = false,
        },
      },
      -- Suppress error notifications from blocked endpoints (e.g. workspace embeddings
      -- blocked by Mullvad tracker DNS filter). Errors still go to the log file.
      logger = {
        print_log_level = vim.log.levels.OFF,
      },
      filetypes = {
        markdown = true,
        help = true,
        lua = true,
        latex = true,
        python = true,
        rust = true,
        -- add/override per your workflow
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
      -- Your own insert-mode mappings (no Tab conflicts with NvChad):
      local map = vim.keymap.set
      -- Accept by word / line (optional, handy when ghost text is enabled)
      map("i", "<C-l>", function()
        local ok, s = pcall(require, "copilot.suggestion")
        if ok and s.is_visible() then
          s.accept_line()
        end
      end, { desc = "Copilot: accept line" })
      map("i", "<C-k>", function()
        local ok, s = pcall(require, "copilot.suggestion")
        if ok and s.is_visible() then
          s.accept_word() -- Accept the next word after accepting the line
        end
      end, { desc = "Copilot: accept word" })
      -- Manually request a Next Edit Suggestion (nes.auto_trigger is false).
      map({ "n", "i" }, "<C-s>", function()
        local ok, nes = pcall(require, "copilot-lsp.nes")
        if ok then
          nes.request_nes "copilot"
        end
      end, { desc = "Copilot NES: request suggestion" })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      "nvim-lua/plenary.nvim", -- for curl, log wrapper
      "telescope.nvim",
    },
    -- Only on MacOS or Linux
    build = vim.fn.has "unix" == 1 and "make tiktoken" or nil,
    opts = {
      -- https://github.com/CopilotC-Nvim/CopilotChat.nvim/issues/375
      allow_insecure = true, -- Allow insecure connections fixes curl problems
      auto_select_tools = true,
      -- model = "claude-opus-4.6", -- default model, can be overridden per question
      -- model = "gpt-5.3-codex",
      model = "gpt-5.4-mini",
      -- model = "gemini-3.1-pro-preview",
      -- debug = true, -- Enable debugging
      output = {
        -- TODO: this does not seem to work yet -> fix it
        qflist = true, -- <-- enables quickfix integration
      },
      prompts = {
        -- Example prompts
        Yarrr = {
          prompt = "Explain the buffer pirate style.",
          system_prompt = "You are fascinated by pirates, so please respond in pirate speak.",
          mapping = "<leader>ccx",
          description = "pirate buffer explainer",
        },
      },
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
      "CopilotChatModels",
    },
    keys = {
      {
        "<leader>ccq",
        mode = "n",
        function()
          -- Ask the question
          local input = vim.fn.input "Quick Chat: "
          if input ~= "" then
            require("CopilotChat").ask(input, {
              -- model = "gpt-4.1",
              -- model = "gpt-4o",
              -- model = "gpt-5.2",
              -- model = "claude-opus-4.6"
              -- use the default model, as selected by running :CopilotChatModels
              model = require("CopilotChat.config")["model"],
              tools = { "@copilot" },
              -- sticky = { "#buffer", "#buffers", "#gitdiff:staged", "#diagnostics:current" },
              sticky = { "#buffer:visible", "#gitdiff:staged", "#diagnostics:current" },
              -- TODO: this does not seem to work yet -> fix it
              output = {
                qflist = true, -- enable quickfix integration for this question
              },
              -- resources = all_buffers_content,
              -- sticky = all_buffers_content,
            })
          end
        end,
        desc = "CopilotChat - Quick chat",
      },
      {
        "<leader>cch",
        mode = "n",
        function()
          require("CopilotChat").select_prompt {
            prompt_type = "help",
          }
        end,
        desc = "CopilotChat - Help actions",
      },
      {
        "<leader>cch",
        mode = "v",
        function()
          -- Escape visual mode to ensure '< and '> marks are set
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
          require("CopilotChat").select_prompt {
            prompt_type = "help",
          }
        end,
        desc = "CopilotChat - Help actions",
      },
      {
        "<leader>ccp",
        mode = { "n", "v" },
        function()
          require("CopilotChat").select_prompt()
        end,
        desc = "CopilotChat - Prompt actions",
      },
    },
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "MCPHub",
    -- build = "npm install -g mcp-hub@latest",
    config = function()
      require("mcphub").setup {
        -- See here for the configuration options: https://ravitemer.github.io/mcphub.nvim/configuration.html
        use_bundled_binary = false,
        config = vim.fn.stdpath "config" .. "/mcp-hub/servers.json",
        extensions = {
          copilotchat = {
            enabled = true,
            convert_tools_to_functions = true, -- `@python-refactor__...`
            convert_resources_to_functions = true, -- expose resources too
            add_mcp_prefix = false,
          },
        },
      }
    end,
  },
  {
    "yetone/avante.nvim",
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = vim.fn.has "win32" ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    cmd = "AvanteAsk",
    priority = 900, -- make sure to load after copilot and copilotchat
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@diagnostic disable-next-line: undefined-doc-name
    ---@type avante.Config
    opts = {
      -- add any opts here
      -- this file can contain specific instructions for your project
      instructions_file = "avante.md",
      -- for example
      provider = "copilot",
      -- input = {
      -- provider = "nui", -- default if you omit this
      -- conceal = true, -- <-- disable conceal to remove the error
      -- },
      input = { provider = "dressing", conceal = true },
      -- select = { provider = "dressing" },
      -- input = { provider = "native", conceal = false },
      providers = {
        copilot = {
          -- __inherited_from = "openai",
          -- model = "gpt-4o",
          -- model = "claude-opus-4.8",
          -- model = "claude-sonnet-4.6",
          -- model = "claude-haiku-4.5",
          -- model = "gpt-5.5",
          -- model = "gpt-5.4-mini",
          model = "gpt-5.3-codex",
          timeout = 30000,
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 20480,
          },
        },
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-20250514",
          timeout = 30000, -- Timeout in milliseconds
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 20480,
          },
        },
        moonshot = {
          endpoint = "https://api.moonshot.ai/v1",
          model = "kimi-k2-0711-preview",
          timeout = 30000, -- Timeout in milliseconds
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 32768,
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      -- "stevearc/dressing.nvim", -- for input provider dressing
      -- "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
      {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
        opts = {
          input = { insert_only = false },
          -- Avoid routing selects through Telescope; use Dressing's builtin
          select = { backend = { "builtin" } },
        },
      },
    },
  },
  -- Unfortunately, sidekick seems unusable due to this but https://github.com/folke/sidekick.nvim/issues/258
  {
    "folke/sidekick.nvim",
    lazy = false,
    -- cmd = "Sidekick",
    keys = {
      {
        "<C-/>",
        function()
          require("sidekick.cli").toggle()
        end,
        mode = { "n", "x" },
        desc = "Sidekick toggle CLI",
      },
    },
    opts = {
      cli = {
        copilot = { cmd = { "gh copilot", "--alt-screen" } },
      },
      nes = { enabled = false },
    },
    config = function(_, opts)
      require("sidekick").setup(opts)
      -- Keymaps for SideKick buffer only
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "sidekick_terminal",
        callback = function(args)
          local buf = args.buf
          local kmopts = { buffer = buf, noremap = true, silent = true }
          -- In terminal mode: Esc exits to normal mode
          vim.keymap.set({ "t" }, "<Esc>", "<C-\\><C-N>", kmopts)
          -- In normal mode: Esc sends escape to the terminal (cancels copilot CLI response)
          vim.keymap.set({ "n" }, "<Esc>", function()
            vim.api.nvim_chan_send(vim.b.terminal_job_id, "\27")
          end, kmopts)
        end,
      })
    end,
  },
}
