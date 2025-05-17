vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

----------------------------------------- CUSTOM -----------------------------------------------------

-- Autoreload on buffer change
-- https://stackoverflow.com/questions/62100785/auto-reload-file-and-in-neovim-and-auto-reload-nerbtree
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = { "*" },
})

--Relative line numbers
vim.wo.relativenumber = true

--Use clipboard for copy/paste
vim.opt.clipboard = "unnamedplus"

--File format to unix
vim.opt.fileformat = "unix"
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*",
  callback = function()
    if vim.bo.modifiable then
      vim.bo.fileformat = "unix"
    end
  end,
})

-- Set max size of log files
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local log_path = vim.lsp.get_log_path()
    local max_bytes = 100 * 1024 -- 100 KB
    local stat = vim.loop.fs_stat(log_path)
    if stat and stat.size > max_bytes then
      local f = io.open(log_path, "w")
      if f then
        f:write "" -- Truncate the file
        f:close()
        vim.notify("LSP log truncated", vim.log.levels.INFO)
      end
    end
  end,
})
