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
    -- lazy = false,
    ft = "python",
    enable = true,
    -- TODO: fix this, and generate the docs automatically
    build = ":helptags " .. dir .. "/doc",
    dependencies = {
      "mfussenegger/nvim-dap", -- DAP core
      "akinsho/toggleterm.nvim",
    },
    -- config = function()
    --   require("togglepy").setup { host = "localhost", port = 9000 }
    --   -- require "togglepy.repl"
    -- end,
  })
end

return M
