require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
-- map("i", "jk", "<ESC>")

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
map("n", "<leader>dr", "<cmd> DapToggleRepl <CR>", { desc = "Toggle Repl" })
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

------------------------------------------- Aerial -------------------------------------------------
map("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Aereal Toggle" })

------------------------------------------- Copilot -------------------------------------------------
map("i", "<C-e>", function()
  local suggestion = vim.fn["copilot#Accept"]()
  -- suggestion = vim.fn.feedkeys(suggestion:gsub("\r\n", "\n"), "")
  -- suggestion = vim.api.nvim_replace_termcodes(suggestion, true, true, true) -- Properly handle termcodes
  vim.fn.feedkeys(suggestion, "n")
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
