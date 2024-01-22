local M = {}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = { "<cmd> DapToggleBreakpoint <CR>" },
  },
}

M.dap_python = {
  plugin = true,
  n = {
    ["<leader>dpr"] = {
      function()
        require("dap-python").test_method()
      end,
    },
  },
}

M.nvim_lsp = {
  n = {
    ["]g"] = { "<cmd>lua vim.diagnostic.goto_next()<CR>" },
    ["[g"] = { "<cmd>lua vim.diagnostic.goto_prev()<CR>" },
  },
}

M.aerial = {
  n = {
    ["<leader>a"] = { "<cmd>AerialToggle!<CR>" },
  },
}

M.copilot = {
  i = {
    ["<C-l>"] = {
      function()
        vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
      end,
      "Copilot Accept",
      { replace_keycodes = true, nowait = true, silent = true, expr = true, noremap = true },
    },
  },
}

M.harpoon = {
  n = {
    ["<leader>ha"] = {
      function()
        require("harpoon.mark").add_file()
      end,
      "󱡁 Harpoon Add file",
    },
    ["<leader>ta"] = { "<CMD>Telescope harpoon marks<CR>", "󱡀 Toggle quick menu" },
    ["<leader>hb"] = {
      function()
        require("harpoon.ui").toggle_quick_menu()
      end,
      "󱠿 Harpoon Menu",
    },
    ["<leader>1"] = {
      function()
        require("harpoon.ui").nav_file(1)
      end,
      "󱪼 Navigate to file 1",
    },
    ["<leader>2"] = {
      function()
        require("harpoon.ui").nav_file(2)
      end,
      "󱪽 Navigate to file 2",
    },
    ["<leader>3"] = {
      function()
        require("harpoon.ui").nav_file(3)
      end,
      "󱪾 Navigate to file 3",
    },
    ["<leader>4"] = {
      function()
        require("harpoon.ui").nav_file(4)
      end,
      "󱪿 Navigate to file 4",
    },
  },
}

M.nvim_tree = {
  n = {
    ["<leader>ga"] = {
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
      "󱈜 Stage/unstage file",
    },
  },
}

M.neogit = {
  n = {
    ["<leader>gs"] = { "<cmd>Neogit<CR>", "󱈜 Neogit status" },
    -- ["<leader>gc"] = { "<cmd>Neogit commit<CR>", "󱈜 Neogit commit" },
    -- ["<leader>gp"] = { "<cmd>Neogit push<CR>", "󱈜 Neogit push" },
    -- ["<leader>gl"] = { "<cmd>Neogit pull<CR>", "󱈜 Neogit pull" },
    -- ["<leader>gb"] = { "<cmd>Neogit branch<CR>", "󱈜 Neogit branch" },
    -- ["<leader>gd"] = { "<cmd>Neogit diff<CR>", "󱈜 Neogit diff" },
    -- ["<leader>gD"] = { "<cmd>Neogit diff<CR>", "󱈜 Neogit diff" },
    -- ["<leader>gC"] = { "<cmd>Neogit commit --amend<CR>", "󱈜 Neogit commit --amend" },
    -- ["<leader>gR"] = { "<cmd>Neogit reset<CR>", "󱈜 Neogit reset" },
    -- ["<leader>gS"] = { "<cmd>Neogit stash<CR>", "󱈜 Neogit stash" },
    -- ["<leader>gP"] = { "<cmd>Neogit pull --rebase<CR>", "󱈜 Neogit pull --rebase" },
    -- ["<leader>gB"] = { "<cmd>Neogit branch -d<CR>", "󱈜 Neogit branch -d" },
    -- ["<leader>gA"] = { "<cmd>Neogit add --all<CR>", "󱈜 Neogit add --all" },
  },
}

return M
