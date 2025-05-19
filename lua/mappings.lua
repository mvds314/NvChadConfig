require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
-- map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Additional way to enter normal mode
map("t", "<C-[>", "<C-\\><C-n>")

---------------------------- CUSTOM MAPPINGS -------------------------------------------

---------------------------- Lua language mappings -------------------------------------------
-- Blink the current line
local function blink_current_line(ms)
  local ns = vim.api.nvim_create_namespace "blink_line_ns"
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1

  -- Get the highlight color from Visual group
  local hl_group = "Visual"
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_group })
  if not ok or not hl.bg then
    return
  end

  local color = string.format("#%06x", hl.bg)

  -- Define temporary highlight group
  vim.api.nvim_set_hl(0, "BlinkLine", { bg = color })

  -- Place an extmark with the highlight
  local mark_id = vim.api.nvim_buf_set_extmark(0, ns, line, 0, {
    end_row = line + 1,
    hl_group = "BlinkLine",
    hl_eol = true,
  })

  -- Remove the highlight after a short delay
  vim.defer_fn(function()
    vim.api.nvim_buf_del_extmark(0, ns, mark_id)
  end, ms)
end

local function blink_entire_file(ms)
  local ns = vim.api.nvim_create_namespace "blink_file_ns"
  local buf = 0
  local lines = vim.api.nvim_buf_line_count(buf)

  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = "Visual" })
  if not ok or not hl.bg then
    return
  end
  local color = string.format("#%06x", hl.bg)

  vim.api.nvim_set_hl(0, "BlinkFile", { bg = color })

  local mark_id = vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
    end_row = lines,
    hl_group = "BlinkFile",
    hl_eol = true,
  })

  vim.defer_fn(function()
    vim.api.nvim_buf_del_extmark(buf, ns, mark_id)
  end, ms)
end

local function blink_selection(ms, start_line, end_line)
  local ns = vim.api.nvim_create_namespace "blink_selection_ns"
  local buf = 0

  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = "Visual" })
  if not ok or not hl.bg then
    return
  end
  local color = string.format("#%06x", hl.bg)

  vim.api.nvim_set_hl(0, "BlinkSelection", { bg = color })

  local mark_id = vim.api.nvim_buf_set_extmark(buf, ns, start_line, 0, {
    end_row = end_line,
    hl_group = "BlinkSelection",
    hl_eol = true,
  })

  vim.defer_fn(function()
    vim.api.nvim_buf_del_extmark(buf, ns, mark_id)
  end, ms)
end
map("n", "<leader>rf", function()
  blink_entire_file(80)
  vim.cmd "source %"
end, { desc = "Run lua file with Neovim's lua interpreter" })
map("n", "<leader>rl", function()
  blink_current_line(80)
  vim.cmd ".lua"
end, { desc = "Run current line in lua file with Neovim's lua interpreter" })
map("v", "<leader>rl", function()
  local start_pos = vim.fn.getpos "v"
  local end_pos = vim.fn.getpos "."
  -- Ensure start is before end
  if start_pos[2] > end_pos[2] or (start_pos[2] == end_pos[2] and start_pos[3] > end_pos[3]) then
    start_pos, end_pos = end_pos, start_pos
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  blink_selection(80, start_pos[2] - 1, end_pos[2])
  vim.cmd(string.format("%d,%dlua", start_pos[2], end_pos[2]))
end, { desc = "Run selected lines in lua file with Neovim's lua interpreter" })

-- Alternative way to run selected lines in lua without blinking
-- map("v", "<leader>x", ":'<,'>.lua<CR>", { desc = "Run selected lines in lua file with Neovim's lua interpreter" })

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

------------------------------------------- Quickfix -------------------------------------------------
map("n", "<leader>qf", "<cmd>cwindow<CR>", { desc = "Open/close quickfix" })
map("n", "<leader>]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
map("n", "<leader>[q", "<cmd>cprev<CR>", { desc = "Previous quickfix" })
