local ipy_term = nil

local run_python_file_in_ipython_terminal = function()
  local file = vim.api.nvim_buf_get_name(0)
  -- Save the file before running it
  vim.cmd "wall"
  -- local tt = require "toggleterm"
  local Terminal = require("toggleterm.terminal").Terminal
  if file == "" then
    vim.notify("No file to run", vim.log.levels.ERROR)
    return
  end
  if vim.bo.filetype ~= "python" then
    vim.notify("This only works for Python files", vim.log.levels.WARN)
    return
  end
  local dir = vim.fn.fnamemodify(file, ":h")
  -- Ignore IPython warnings about running inside a virtual environment
  local cmd = string.format(
    'python -W "ignore:.*interactiveshell.py:UserWarning" -m IPython -i -c "import os; os.chdir(r\'%s\');"',
    dir
  )
  if not ipy_term then
    ipy_term = Terminal:new {
      cmd = cmd,
      hidden = false, -- Register the terminal so it can be toggled
      direction = "float",
      close_on_exit = false,
      count = 1,
      newline_chr = "\n", -- The character to use for newlines, set manually to avoid issues with adding extra newlines
      display_name = "IPython terminal",
    }
  end

  if not ipy_term:is_open() then
    ipy_term:toggle()
  end
  file = string.gsub(file, "[\r\n]+$", "")
  ipy_term:send(string.format("%%run %s", file), false)
end

return {
  "akinsho/toggleterm.nvim",
  lazy = true,
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
    vim.api.nvim_create_user_command("RunIpyFile", run_python_file_in_ipython_terminal, {})
  end,
  keys = {
    { "<C-\\>", mode = { "n", "i", "t" }, "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
    {
      "<F5>",
      mode = { "n", "i", "v" },
      "<cmd>RunIpyFile<CR>",
      desc = "Run file in ipython",
    },
    -- This will allow you to use, for example, 2<F9> in normal or visual mode to send to terminal 2. If no count is given, it defaults to terminal 1.
    {
      "<F9>",
      mode = "n",
      function()
        vim.cmd("ToggleTermSendCurrentLine " .. vim.v.count1)
      end,
      desc = "Send current line to terminal <count>",
      expr = false,
    },
    {
      "<F9>",
      mode = "v",
      function()
        vim.cmd("ToggleTermSendVisualSelection " .. vim.v.count1)
      end,
      desc = "Send visual selection to terminal <count>",
      expr = false,
    },
  },
}
