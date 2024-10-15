-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "onedark",
}
-- Set terminal colors to onedark manually
vim.cmd [[
  if has("nvim")
    let g:terminal_color_0 = '#282c34'
    let g:terminal_color_1 = '#e06c75'
    let g:terminal_color_2 = '#98c379'
    let g:terminal_color_3 = '#e5c07b'
    let g:terminal_color_4 = '#61afef'
    let g:terminal_color_5 = '#c678dd'
    let g:terminal_color_6 = '#56b6c2'
    let g:terminal_color_7 = '#dcdfe4'
    let g:terminal_color_8 = '#5a6374'
    let g:terminal_color_9 = '#e06c75'
    let g:terminal_color_10 = '#98c379'
    let g:terminal_color_11 = '#e5c07b'
    let g:terminal_color_12 = '#61afef'
    let g:terminal_color_13 = '#c678dd'
    let g:terminal_color_14 = '#56b6c2'
    let g:terminal_color_15 = '#dcdfe4'
  endif
]]

M.mason.pkgs = {
  -- "pyright",
  -- "python-lsp-server",
  "jedi-language-server",
  -- "black",
  "ruff",
  -- "flake8",
  -- "pylint",
  "debugpy",
  "lua-language-server",
  "stylua",
  "texlab",
  -- "ltex-ls",
  "latexindent",
  -- "codespell",
  "harper-ls",
  -- "vale", -- vale.init not found
  "proselint",
  "json-lsp",
  -- "fixjson",
  --"jsonlint",
  "marksman",
  -- "mdformat",
  "prettierd",
  -- "luasnip",
  "vim-language-server",
  "vint",
  "yaml-language-server",
  -- "yamlfix",
  -- "taplo", -- TOML LSP: https://taplo.tamasfe.dev/
  -- "dprint", -- formatting for several languages including TOML
  "dockerfile-language-server",
  --"azure-pipelines-language-server",
  "hadolint",
  "bash-language-server",
  "shfmt",
}

-- hl_override = {
-- 	Comment = { italic = true },
-- 	["@comment"] = { italic = true },
-- },

return M
