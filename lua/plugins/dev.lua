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
    build = ":helptags " .. dir .. "/doc",
    dependencies = {
      "mfussenegger/nvim-dap", -- DAP core
      "akinsho/toggleterm.nvim",
    },
    opts = {
      host = "localhost",
      port = 9000,
    },
    keys = {
      { "<C-w>h", "<C-\\><C-n><C-w>h", mode = "t", noremap = true, desc = "Go to left window" },
      { "<C-w>j", "<C-\\><C-n><C-w>j", mode = "t", noremap = true, desc = "Go to lower window" },
      { "<C-w>k", "<C-\\><C-n><C-w>k", mode = "t", noremap = true, desc = "Go to upper window" },
      { "<C-w>l", "<C-\\><C-n><C-w>l", mode = "t", noremap = true, desc = "Go to right window" },
    },
  })
end
-- Auto-generate helptags when saving a doc file
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = dir .. "/doc/*.txt",
  command = "helptags " .. dir .. "/doc",
})

return M
