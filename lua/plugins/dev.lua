local M = {}

local is_windows = vim.loop.os_uname().version:match "Windows"

local function dir_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == "directory"
end

local dir
if is_windows then
  dir = os.getenv "USERPROFILE" .. "/Repos/myplugin.nvim"
else
  dir = os.getenv "HOME" .. "/Repos/myplugin.nvim"
end
if dir_exists(dir) then
  table.insert(M, { dir = dir, lazy = false, enable = false, config = function() end })
end

if is_windows then
  dir = os.getenv "USERPROFILE" .. "/Repos/togglepy.nvim"
else
  dir = os.getenv "HOME" .. "/Repos/togglepy.nvim"
end
local search_paths = {}
if is_windows then
  -- Add all WinPython environments located at C:\Software\WPy64* folders
  local wpy_handle = io.popen 'dir /b /ad "C:\\Software\\WPy64*" 2>nul'
  if wpy_handle then
    for folder in wpy_handle:lines() do
      local wpy_python_handle = io.popen('dir /b /ad "C:\\Software\\' .. folder .. '\\python*" 2>nul')
      if wpy_python_handle then
        for subfolder in wpy_python_handle:lines() do
          table.insert(search_paths, "C:\\Software\\" .. folder .. "\\" .. subfolder)
        end
        wpy_python_handle:close()
      end
      local envs_dir = "C:\\Software\\" .. folder .. "\\envs"
      -- Add all subfolders of the environments folder
      local envs_handle = io.popen('dir /b /ad "' .. envs_dir .. '" 2>nul')
      if envs_handle then
        for subenv in envs_handle:lines() do
          table.insert(search_paths, envs_dir .. "\\" .. subenv .. "\\Scripts")
        end
        envs_handle:close()
      end
    end
    wpy_handle:close()
  end
else
  search_paths = { "~/mypython/bin" }
end

local local_dev = false
if dir_exists(dir) and local_dev then
  table.insert(M, {
    dir = dir,
    -- lazy = false,
    ft = "python",
    enable = true,
    build = ":helptags " .. dir .. "/doc",
    dependencies = {
      "mfussenegger/nvim-dap", -- DAP core
      "akinsho/toggleterm.nvim",
    },
    opts = {
      ipdab = {
        host = "localhost",
        port = 9000,
      },
      repl = { search_paths = search_paths, add_miniconda = true, add_system_path = true },
      keys = {},
    },
    keys = {},
  })
else
  table.insert(M, {
    "mvds314/togglepy.nvim",
    -- lazy = false,
    ft = "python",
    enable = true,
    build = ":helptags " .. dir .. "/doc",
    dependencies = {
      "mfussenegger/nvim-dap", -- DAP core
      "akinsho/toggleterm.nvim",
    },
    opts = {
      ipdab = {
        host = "localhost",
        port = 9000,
      },
      repl = { search_paths = search_paths, add_miniconda = true, add_system_path = true },
      keys = {},
    },
    keys = {},
  })
end
-- Auto-generate helptags when saving a doc file
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = dir .. "/doc/*.txt",
  command = "helptags " .. dir .. "/doc",
})

return M
