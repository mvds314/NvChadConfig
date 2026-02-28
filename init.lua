vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- Make cursos a vertical line in command mode
vim.opt.guicursor = "n-v:block,i-c:ver25,r-cr:hor20,o:hor50"

-- ASCII fallbacks (safe everywhere)
vim.fn.sign_define("AvanteInputPromptSign", { text = ">", texthl = "Question", numhl = "" })
vim.fn.sign_define("AvanteInputContinueSign", { text = ".", texthl = "NonText", numhl = "" })
vim.fn.sign_define("AvanteInputSubmitSign", { text = "+", texthl = "String", numhl = "" })

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
require "autocmds"

-- Python host setup
-- TODO: consider making part of TogglePy.nvim
local py = require("util.python").autodetect_python_host()
if py then
  vim.g.python3_host_prog = py
  -- Optional: notify the chosen interpreter once (quiet if you prefer)
  -- vim.schedule(function()
  --   vim.notify(("Python host set to: %s"):format(py), vim.log.levels.INFO, { title = "Neovim Python" })
  -- end)
else
  -- Not found or pynvim missing -> give actionable guidance
  vim.schedule(function()
    vim.notify("Neovim could not auto-detect a usable Python host.", vim.log.levels.WARN, { title = "Neovim Python" })
  end)
end

local enable_providers = {
  "python3_provider",
  "node_provider",
  -- and so on
}
for _, plugin in pairs(enable_providers) do
  vim.g["loaded_" .. plugin] = nil
  vim.cmd("runtime " .. plugin)
end

vim.schedule(function()
  require "mappings"
end)
