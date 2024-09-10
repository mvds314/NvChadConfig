-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "onedark",
}

M.mason.pkgs = {
  -- "pyright",
  -- "python-lsp-server",
  "jedi-language-server",
  -- "black",
  -- "ruff",
  "ruff-lsp",
  -- "flake8",
  -- "pylint",
  "debugpy",
  "lua-language-server",
  "stylua",
  "texlab",
  -- "ltex-ls",
  "latexindent",
  "codespell",
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
