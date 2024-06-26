require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")


---------------------------- CUSTOM MAPPINGS -------------------------------------------

-- TODO: process dap mappings

local M = {}

M.dap = {
	plugin = true,
	n = {
		["<leader>db"] = { "<cmd> DapToggleBreakpoint <CR>" },
		["<F5>"] = { "<cmd> DapContinue <CR>" },
		["<F10>"] = { "<cmd> DapStepOver <CR>" },
		["<F11>"] = { "<cmd> DapStepInto <CR>" },
		["<F12>"] = { "<cmd> DapStepOut <CR>" },
		["<leader>dc"] = { "<cmd> DapContinue <CR>" },
		["<leader>dn"] = { "<cmd> DapStepOver <CR>" },
		["<leader>ds"] = { "<cmd> DapStepInto <CR>" },
		["<leader>dr"] = { "<cmd> DapToggleReple <CR>" },
		["<leader>dq"] = { "<cmd> DapTerminate <CR>" },
		["<leader>dh"] = {
			function()
				require("dap.ui.widgets").hover()
			end,
		},
		["<leader>dh"] = {
			function()
				require("dap.ui.widgets").preview()
			end,
		},
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

map("n", "]g", "<cmd>lua vim.diagnostic.goto_next()<CR>", { desc = "Go to next diagnostics" } )
map("n", "[g", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { desc = "Go to previous diagnostics" } )

map("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Aereal Toggle" } )

M.copilot = {
	i = {
		["<C-e>"] = {
			function()
				vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
			end,
			"Copilot Accept",
			{ replace_keycodes = true, nowait = true, silent = true, expr = true, noremap = true },
		},
	},
}

map("i", "<C-e>", function() vim.fn.feedkeys(vim.fn["copilot#Accept"](), "") end, { desc = "Copilot Accept" } )

-- Harpoon
map("n", "<leader>ha", function() require("harpoon.mark").add_file() end, { desc = "Harpoon Add file" } )
map("n", "<leader>ta", "<CMD>Telescope harpoon marks<CR>", { desc = "Toggle quick menu" })
map("n", "<leader>hb", function() require("harpoon.ui").toggle_quick_menu() end, { desc = "Harpoon Menu" } )
map("n", "<leader>1", function() require("harpoon.ui").nav_file(1) end, { desc = "Navigate to file 1" } )
map("n", "<leader>2", function() require("harpoon.ui").nav_file(2) end, { desc = "Navigate to file 2" } )
map("n", "<leader>3", function() require("harpoon.ui").nav_file(3) end, { desc = "Navigate to file 3" } )
map("n", "<leader>4", function() require("harpoon.ui").nav_file(4) end, { desc = "Navigate to file 4" } )

-- GIT related
map("n", "<leader>ga", function()
				local api = require("nvim-tree.api")
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
