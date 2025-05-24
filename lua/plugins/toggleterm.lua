local M = {}

local Terminal = require("toggleterm.terminal").Terminal
local ipy_term = nil

local run_ipython_file = function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file to run", vim.log.levels.ERROR)
    return
  end
  if vim.bo.filetype ~= "python" then
    vim.notify("This only works for Python files", vim.log.levels.WARN)
    return
  end
  local dir = vim.fn.fnamemodify(file, ":h")
  local cmd = string.format("ipython -i -c \"import os; os.chdir(r'%s')\"", dir)
  if not ipy_term then
    ipy_term = Terminal:new {
      cmd = cmd,
      hidden = true,
      direction = "float",
      close_on_exit = false,
      count = 99,
    }
  end

  if not ipy_term:is_open() then
    ipy_term:toggle()
  end

  file = string.gsub(file, "[\r\n]+$", "")
  ipy_term:send(string.format("%%run %s", file), false)
end

M[0] = {
  "akinsho/toggleterm.nvim",
  lazy = true,
  -- config = function(_, _)
  --   require("toggleterm").setup {
  --     size = 80,
  --     open_mapping = [[<c-\>]],
  --     hide_numbers = true, -- hide the number column in toggleterm buffers
  --     shade_terminals = true,
  --     shading_factor = 2, -- The degree by which to darken to terminal color
  --     start_in_insert = true,
  --     insert_mappings = true, -- whether or not the open mapping applies in insert mode
  --     persist_size = true,
  --     direction = "float", -- | vertical | tab | float
  --   }
  -- end,
  config = function(_, _)
    local toggleterm = require "toggleterm"
    toggleterm.setup {
      size = 80,
      open_mapping = [[<c-\>]],
      hide_numbers = true, -- hide the number column in toggleterm buffers
      shade_terminals = true,
      shading_factor = 2, -- The degree by which to darken to terminal color
      start_in_insert = true,
      insert_mappings = true, -- whether or not the open mapping applies in insert mode
      persist_size = true,
      direction = "float", -- | vertical | tab | float
    }
    vim.api.nvim_create_user_command("RunIpyFile", run_ipython_file, {})
  end,
  keys = {
    { "<C-\\>", mode = { "n", "i", "t" }, "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
    {
      "<F5>",
      mode = { "n", "i", "v" },
      "<cmd>RunIpyFile<CR>",
      desc = "Run file in ipython",
    },
    -- {
    --   "<F5>",
    --   mode = { "n", "i", "v" },
    --   function()
    --     local file = vim.api.nvim_buf_get_name(0)
    --     if file == "" then
    --       vim.notify("No file to run", vim.log.levels.ERROR)
    --       return
    --     end
    --     local ft = vim.bo.filetype
    --     if ft ~= "python" then
    --       vim.notify("This command only works for Python files", vim.log.levels.WARN)
    --       return
    --     end
    --     local dir = vim.fn.fnamemodify(file, ":h")
    --     local cmd = string.format("ipython -i -c \"import os; os.chdir(r'%s')\"", dir)
    --     local term = require("toggleterm.terminal").Terminal
    --     local ipy = term:new { cmd = cmd, count = 1, direction = "float", hidden = true }
    --     ipy:toggle()
    --     ipy:send(string.format("%%run %s\n", file))
    --     -- require("toggleterm").exec(cmd, 1, 80, "horizontal")
    --     -- cmd = string.format("%%run %s", file)
    --     -- ; exec(open(r'%s').read())"]], dir, fname)
    --     -- require("toggleterm").exec(cmd, 1, 80, "horizontal")
    --     -- term:send(string.format("%%run %s\n", file))
    --   end,
    --   desc = "Run file in ipython -i (cwd = file location)",
    -- },
    -- Add some keys to send lines to the terminal, use the ToggleTermSendCurrentLine and such for those
    { "<F9>", mode = "n", "<cmd>ToggleTermSendCurrentLine<CR>", desc = "Send current line to terminal" },
    {
      "<F9>",
      mode = "v",
      "<cmd>ToggleTermSendVisualSelection<CR>",
      desc = "Send visual selection to terminal",
    },
  },
}
return M
