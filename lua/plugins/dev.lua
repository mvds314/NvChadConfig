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
    -- config = function()
    --   require("togglepy").setup { host = "localhost", port = 9000 }
    --   -- require "togglepy.repl"
    -- end,
    --  TODO: define opts and keymaps here
    -- opts = {
    --   git = {
    --     enable = true,
    --   },
    --   view = {
    --     side = "left",
    --   },
    -- },
    -- keys = {
    --   {
    --     "<leader>ga",
    --     mode = "n",
    --     function()
    --       local api = require "nvim-tree.api"
    --       local node = api.tree.get_node_under_cursor()
    --       local gs = node.git_status.file
    --       -- If the current node is a directory get children status
    --       if gs == nil then
    --         gs = (node.git_status.dir.direct ~= nil and node.git_status.dir.direct[1])
    --           or (node.git_status.dir.indirect ~= nil and node.git_status.dir.indirect[1])
    --       end
    --       -- If the file is untracked, unstaged or partially staged, we stage it
    --       if gs == "??" or gs == "MM" or gs == "AM" or gs == " M" then
    --         vim.cmd("silent !git add " .. node.absolute_path)
    --       -- If the file is staged, we unstage
    --       elseif gs == "M " or gs == "A " then
    --         vim.cmd("silent !git restore --staged " .. node.absolute_path)
    --       end
    --       api.tree.reload()
    --     end,
    --     desc = "Stage/unstage file",
    --   },
    -- },
  })
end
-- Auto-generate helptags when saving a doc file
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = dir .. "/doc/*.txt",
  command = "helptags " .. dir .. "/doc",
})

return M
