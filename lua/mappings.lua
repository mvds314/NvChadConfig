require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

---------------------------- CUSTOM MAPPINGS -------------------------------------------

---------------------------------- DAP -------------------------------------------------
map("n", "<leader>db", "<cmd> DapToggleBreakpoint <CR>", { desc = "Toggle breakpoint" })
map("n", "<F5>", "<cmd> DapContinue <CR>", { desc = "Continue" })
map("n", "<F10>", "<cmd> DapStepOver <CR>", { desc = "Step over" })
map("n", "<F11>", "<cmd> DapStepInto <CR>", { desc = "Step into" })
map("n", "<F12>", "<cmd> DapStepOut <CR>", { desc = "Step out" })
map("n", "<leader>dc", "<cmd> DapContinue <CR>", { desc = "Continue" })
map("n", "<leader>dn", "<cmd> DapStepOver <CR>", { desc = "Step over" })
map("n", "<leader>ds", "<cmd> DapStepInto <CR>", { desc = "Step into" })
map("n", "<leader>dr", "<cmd> DapToggleReple <CR>", { desc = "Toggle Repl" })
map("n", "<leader>dq", "<cmd> DapTerminate <CR>", { desc = "Terminate" })
map("n", "<leader>dh", function()
  require("dap.ui.widgets").hover()
end, { desc = "Hover" })
map("n", "<leader>dh", function()
  require("dap.ui.widgets").preview()
end, { desc = "Preview" })

-- Python specific mappings
map("n", "<leader>dpr", "<cmd>lua require('dap-python').test_method()<CR>", { desc = "Test method" })

------------------------------------------- LSP diagnostics -------------------------------------------------
map("n", "]g", "<cmd>lua vim.diagnostic.goto_next()<CR>", { desc = "Go to next diagnostics" })
map("n", "[g", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { desc = "Go to previous diagnostics" })

------------------------------------------- Neotest -------------------------------------------------
map("n", "<leader>tn", "<cmd>lua require('neotest').run.run()<CR>", { desc = "Run nearest test" })
map("n", "<leader>tf", "<cmd>lua require('neotest').run.run()<CR>", { desc = "Run all tests in file" })
map("n", "<leader>to", "<cmd>lua require('neotest').output.open()<CR>", { desc = "Open test output" })
map("n", "<leader>ts", "<cmd>lua require('neotest').summary.toggle()<CR>", { desc = "View test summary" })

------------------------------------------- Aerial -------------------------------------------------
map("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Aereal Toggle" })

------------------------------------------- Copilot -------------------------------------------------
map("i", "<C-e>", function()
  vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
end, { desc = "Copilot Accept" })

------------------------------------------- Harpoon -------------------------------------------------
map("n", "<leader>qa", function()
  require("harpoon.mark").add_file()
end, { desc = "Harpoon Add file to quick menu" })
map("n", "<leader>ta", "<CMD>Telescope harpoon marks<CR>", { desc = "Toggle quick menu" })
map("n", "<leader>qm", function()
  require("harpoon.ui").toggle_quick_menu()
end, { desc = "Harpoon Quick menu Menu" })
map("n", "<leader>1", function()
  require("harpoon.ui").nav_file(1)
end, { desc = "Navigate to file 1" })
map("n", "<leader>2", function()
  require("harpoon.ui").nav_file(2)
end, { desc = "Navigate to file 2" })
map("n", "<leader>3", function()
  require("harpoon.ui").nav_file(3)
end, { desc = "Navigate to file 3" })
map("n", "<leader>4", function()
  require("harpoon.ui").nav_file(4)
end, { desc = "Navigate to file 4" })

------------------------------------------- GIT related -------------------------------------------------
map("n", "<leader>ga", function()
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
end, { desc = "Stage/unstage file" })

map("n", "<leader>gs", "<cmd>Neogit<CR>", { desc = "Neogit status" })
map("n", "<leader>gc", "<cmd>Neogit commit<CR>", { desc = "Neogit commit" })
map("n", "<leader>gp", "<cmd>Neogit push<CR>", { desc = "Neogit push" })
map("n", "<leader>gl", "<cmd>Neogit pull<CR>", { desc = "Neogit pull" })
map("n", "<leader>gb", "<cmd>Neogit branch<CR>", { desc = "Neogit branch" })
map("n", "<leader>gd", "<cmd>Neogit diff<CR>", { desc = "Neogit diff" })
