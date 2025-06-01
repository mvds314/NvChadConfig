-- Stores the ipython terminal instance
local ipy_term = nil
-- Stores the preferred Python environment
local current_python_env = nil
-- Stores list with all Python environments
local python_envs = nil
-- Helpers for blinking text to be sent to the terminal
local blink = require "util.blink"
local helpers = require "util.helpers"

-- TODO:
-- Add blinking when sending lines to the terminal
-- Consider to add switching environment logic to Telescope
-- Put finding environments in a subprocess to avoid blocking Neovim
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

local function find_python_envs_on_linux()
  local envs = {}
  -- Linux/MacOS
  local find_cmd =
    [[find -L /usr/bin /usr/local/bin ~/.pyenv/versions ~/.conda/envs ~/anaconda3/envs -type f -name python 2>/dev/null; which python]]
  local linux_handle = io.popen(find_cmd)
  if linux_handle then
    for line in linux_handle:lines() do
      table.insert(envs, line)
    end
    linux_handle:close()
  end
  return envs
end

local function find_python_envs_on_windows()
  local envs = {}
  -- Only check common install locations, avoid recursive search for speed
  -- Add all miniconda3 folders
  local candidates = {
    os.getenv "USERPROFILE" .. "\\AppData\\Local\\miniconda3",
  }
  -- Add all miniconda3 envs folders
  local miniconda_envs = os.getenv "USERPROFILE" .. "\\AppData\\Local\\miniconda3\\envs"
  local envs_handle = io.popen('dir /b /ad "' .. miniconda_envs .. '" 2>nul')
  if envs_handle then
    for folder in envs_handle:lines() do
      table.insert(candidates, miniconda_envs .. "\\" .. folder)
    end
    envs_handle:close()
  end
  -- Add all C:\Software\WPy64* folders
  local wpy_handle = io.popen 'dir /b /ad "C:\\Software\\WPy64*" 2>nul'
  if wpy_handle then
    for folder in wpy_handle:lines() do
      local wpy_python_handle = io.popen('dir /b /ad "C:\\Software\\' .. folder .. '\\python*" 2>nul')
      if wpy_python_handle then
        for subfolder in wpy_python_handle:lines() do
          table.insert(candidates, "C:\\Software\\" .. folder .. "\\" .. subfolder)
        end
        wpy_python_handle:close()
      end
      local envs_dir = "C:\\Software\\" .. folder .. "\\envs"
      -- Add all subfolders of the environments folder
      envs_handle = io.popen('dir /b /ad "' .. envs_dir .. '" 2>nul')
      if envs_handle then
        for subenv in envs_handle:lines() do
          table.insert(candidates, envs_dir .. "\\" .. subenv .. "\\Scripts")
        end
        envs_handle:close()
      end
    end
    wpy_handle:close()
  end
  -- Process candidate folders
  for _, dir in ipairs(candidates) do
    local handle = io.popen('dir /b "' .. dir .. '\\python.exe" 2>nul')
    if handle then
      for line in handle:lines() do
        table.insert(envs, dir .. "\\" .. line)
      end
      handle:close()
    end
  end
  -- Also add python from PATH
  local handle = io.popen "where python 2>nul"
  if handle then
    for line in handle:lines() do
      table.insert(envs, line)
    end
    handle:close()
  end
  return envs
end

local function find_python_envs()
  local envs = {}
  ---@diagnostic disable-next-line: undefined-field
  local is_windows = vim.loop.os_uname().version:match "Windows"
  if is_windows then
    return find_python_envs_on_windows()
  else
    return find_python_envs_on_linux()
  end
end

-- TODO test this one
local function pick_python_env_async()
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local conf = require("telescope.config").values

  local search_cmd =
    [[which -a python python3 2>/dev/null; find -L ~/.pyenv/versions ~/.conda/envs ~/anaconda3/envs -type f -name python 2>/dev/null]]
  vim.system({ "bash", "-c", search_cmd }, { text = true }, function(obj)
    if obj.code == 0 and obj.stdout then
      local envs = {}
      for line in obj.stdout:gmatch "[^\r\n]+" do
        table.insert(envs, line)
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
    else
      vim.notify("Failed to find Python environments", vim.log.levels.ERROR)
    end
  end)
end

local function pick_python_env()
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local conf = require("telescope.config").values
  -- Find python executables in common locations
  if not python_envs then
    python_envs = find_python_envs()
  end
  pickers
    .new({}, {
      prompt_title = "Select Python Environment",
      finder = finders.new_table { results = python_envs },
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

-------------------------------- Set up commands --------------------------------

vim.api.nvim_create_user_command("PickPythonEnv", pick_python_env, {})
vim.api.nvim_create_user_command("ClearPytonEnvs", function()
  python_envs = nil
end, {})
vim.api.nvim_create_user_command("PickPythonEnvAsync", pick_python_env_async, {})

------------------------------ Load the toggleterm plugin ------------------------------
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
      start_in_insert = false, -- Otherwis F9 might bring you to insert mode if the the first thing you do is send line to an empty terminal
      insert_mappings = true, -- whether or not the open mapping applies in insert mode
      persist_size = true,
      direction = "float", -- | vertical | tab | float
    }
    vim.api.nvim_create_user_command("RunIpyFile", function()
      run_python_file_in_ipython_terminal()
      -- Or use the logic with blink entire file
      -- blink.entire_file(50)
      -- vim.defer_fn(run_python_file_in_ipython_terminal, 60)
    end, { nargs = 0, desc = "Run current Python file in IPython terminal" })
    vim.api.nvim_create_user_command("ToggleIPythonTerm", function()
      create_or_get_ipython_terminal(nil)
    end, { nargs = 0, desc = "Toggle IPython terminal" })
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
        blink.current_line(50)
        vim.cmd("ToggleTermSendCurrentLine " .. vim.v.count1)
        -- Ensure you stay in normal mode
        vim.schedule(function()
          vim.cmd "stopinsert"
        end)
        helpers.move_to_next_non_empty_line()
        -- Or use a short easy version
        -- vim.cmd "normal! j"
        -- while vim.fn.getline("."):match "^%s*$" do
        --   vim.cmd "normal! j"
        -- end
      end,
      desc = "Send current line to terminal <count> with <count><F9> and move to next non-empty line",
      expr = false,
    },
    {
      "<F9>",
      mode = "v",
      function()
        -- TODO adjust this one so that only the selection blinks
        local start_pos = vim.fn.getpos "v"
        local end_pos = vim.fn.getpos "."
        -- Ensure start is before end
        if start_pos[2] > end_pos[2] or (start_pos[2] == end_pos[2] and start_pos[3] > end_pos[3]) then
          start_pos, end_pos = end_pos, start_pos
        end
        blink.selection(50, start_pos[2] - 1, end_pos[2])
        vim.cmd("ToggleTermSendVisualSelection " .. vim.v.count1)
      end,
      desc = "Send visual selection to terminal <count> and go back to normal mode",
      expr = false,
    },
  },
  cmd = {
    "ToggleTerm",
    "ToggleIPythonTerm",
    "RunIpyFile",
  },
}
