return {
  -- TODO: copilot.vim is now replace by copilot.lua, remove this code later
  -- {
  --   "github/copilot.vim",
  --   lazy = "VeryLazy",
  --   cmd = { "CopilotChat" },
  --   event = "BufEnter",
  --   -- https://github.com/NvChad/NvChad/issues/2020
  --   config = function()
  --     -- Mapping tab is already used by NvChad
  --     vim.g.copilot_no_tab_map = true
  --     vim.g.copilot_assume_mapped = true
  --     vim.g.copilot_tab_fallback = ""
  --     -- The mapping is set to other key, see custom/lua/mappings
  --     -- or run <leader>ch to see copilot mapping section
  --     -- Disable Copilot on startup
  --     -- vim.schedule(function()
  --     --   vim.cmd "Copilot disable"
  --     -- end)
  --   end,
  -- },
  {
    "zbirenbaum/copilot.lua",
    -- Optional: NES support (multi-line, diff-based suggestions) requires Copilot LSP:
    -- dependencies = { "copilotlsp-nvim/copilot-lsp" }, -- enable later if you want NES
    cmd = { "Copilot", "CopilotChat" },
    event = "InsertEnter", -- lazy load when you start typing
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
      model = "claude-opus-4.6", -- default model, can be overridden per question
      -- model = "gpt-5.3-codex",
      -- model = "gemini-3.1-pro-preview",
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
      "CopilotChatModels",
    },
    keys = {
      {
        "<leader>ccq",
        mode = "n",
        function()
          -- Look at the the file functions.lua inside the copilotchat plugin for more details on how to use resources and sticky
          -- Get content of all buffers
          -- local buffers = vim.api.nvim_list_bufs()
          -- local all_buffers_content = {}
          -- for _, buf in ipairs(buffers) do
          --   if vim.api.nvim_buf_get_option(buf, "bufhidden") == "" then
          --     if not vim.api.nvim_buf_is_loaded(buf) then
          --       table.insert(all_buffers_content, "#file:" .. vim.api.nvim_buf_get_name(buf))
          --     else
          --       table.insert(all_buffers_content, "#buffer:" .. buf)
          --     end
          --   end
          -- end
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
              -- tools = { "@copilot" },
              -- sticky = { "#buffer", "#buffers", "#gitdiff:staged", "#diagnostics:current" },
              sticky = { "#buffer:visible", "#gitdiff:staged", "#diagnostics:current" },
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
          local actions = require "CopilotChat.actions"
          require("CopilotChat.integrations.telescope").pick(actions.help_actions())
        end,
        desc = "CopilotChat - Help actions",
      },
      {
        "<leader>ccp",
        mode = "n",
        function()
          local actions = require "CopilotChat.actions"
          require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
        end,
        desc = "CopilotChat - Prompt actions",
      },
    },
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "MCPHub",
    build = "npm install -g mcp-hub@latest",
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
}
