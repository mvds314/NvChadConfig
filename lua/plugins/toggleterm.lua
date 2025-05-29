-- Stores the ipython terminal instance
local ipy_term = nil
-- Stores the preferred Python environment
local current_python_env = nil
-- TODO:
-- Add blinking when sending lines to the terminal
-- Consider to add switching environment logic to Telescope
-- Test logic for switching environments under Windows
-- Make logic for multiple ipython terminals
-- Create a mapping for debugging Python files with ipython
-- Create mappings for debug keys: next step, continue, etc.

local create_or_get_ipython_terminal = function(cmd)
  local Terminal = require("toggleterm.terminal").Terminal
  if not cmd then
    local python_env = current_python_env or "python"
    -- Ignore IPython warnings about running inside a virtual environment
    cmd = string.format('"%s" -W "ignore:.*interactiveshell.py:UserWarning" -m IPython', python_env)
  end
  if not ipy_term then
    ipy_term = Terminal:new {
      cmd = cmd,
      hidden = false, -- Register the terminal so it can be toggled
      direction = "float",
      close_on_exit = false,
      newline_chr = "\n", -- The character to use for newlines, set manually to avoid issues with adding extra newlines
      display_name = "IPython terminal",
    }
  end
  if not ipy_term:is_open() then
    ipy_term:toggle()
  end
  return ipy_term
end

local run_python_file_in_ipython_terminal = function()
  local file = vim.api.nvim_buf_get_name(0)
  -- Save the file before running it
  vim.cmd "wall"
  if file == "" then
    vim.notify("No file to run", vim.log.levels.ERROR)
    return
  end
  if vim.bo.filetype ~= "python" then
    vim.notify("This only works for Python files", vim.log.levels.WARN)
    return
  end
  -- Ignore IPython warnings about running inside a virtual environment
  local python_env = current_python_env or "python"
  local cmd = string.format('"%s" -W "ignore:.*interactiveshell.py:UserWarning" -m IPython', python_env)
  ipy_term = create_or_get_ipython_terminal(cmd)
  file = string.gsub(file, "[\r\n]+$", "")
  ipy_term:send(string.format("%%run %s", file), false)
end

local function pick_python_env()
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local conf = require("telescope.config").values

  -- Find python executables in common locations
  local envs = {}
  ---@diagnostic disable-next-line: undefined-field
  local is_windows = vim.loop.os_uname().version:match "Windows"
  local find_cmd
  if is_windows then
    -- Typical locations for Python on Windows
    find_cmd = [[where python]]
  else
    -- Linux/MacOS
    find_cmd =
      [[find -L /usr/bin /usr/local/bin ~/.pyenv/versions ~/.conda/envs ~/anaconda3/envs -type f -name python 2>/dev/null; which python]]
  end
  local handle = io.popen(find_cmd)
  if handle then
    for line in handle:lines() do
      table.insert(envs, line)
    end
    handle:close()
  end

  pickers
    .new({}, {
      prompt_title = "Select Python Environment",
      finder = finders.new_table { results = envs },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          current_python_env = selection[1]
          vim.notify("Selected Python: " .. current_python_env)
        end)
        return true
      end,
    })
    :find()
end

vim.api.nvim_create_user_command("PickPythonEnv", pick_python_env, {})

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
    vim.api.nvim_create_user_command("ToggleIPythonTerm", function()
      create_or_get_ipython_terminal(nil)
    end, {})
  end,
  keys = {
    { "<C-\\>", mode = { "i", "t", "n" }, "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
    {
      "<C-\\>",
      mode = "n",
      function()
        vim.cmd("ToggleTerm " .. vim.v.count1)
      end,
      desc = "Toggle terminal <count> with <count><C-\\>",
      expr = false,
    },
    {
      "<F5>",
      mode = { "n", "i", "v" },
      "<cmd>RunIpyFile<CR>",
      desc = "Run file in ipython",
    },
    {
      "<F9>",
      mode = "n",
      function()
        vim.cmd("ToggleTermSendCurrentLine " .. vim.v.count1)
      end,
      desc = "Send current line to terminal <count> with <count><F9>",
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
  cmd = {
    "ToggleTerm",
    "ToggleIPythonTerm",
    "RunIpyFile",
  },
}
