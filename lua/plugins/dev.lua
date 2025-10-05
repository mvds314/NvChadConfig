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
if dir_exists(dir) then
  table.insert(M, {
    dir = dir,
    lazy = false,
    enable = false,
    dependencies = {
      "mfussenegger/nvim-dap", -- DAP core
    },
    config = function()
      require("togglepy").setup { host = "localhost", port = 9001 }
    end,
  })
end

return M
