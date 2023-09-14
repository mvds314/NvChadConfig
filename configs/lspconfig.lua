local config = require "plugins.configs.lspconfig"

local on_attach = config.on_attach
local capabilities = config.capabilities

local lspconfig = require "lspconfig"

lspconfig.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "python" },
  -- https://github.com/microsoft/pyright/blob/main/docs/settings.md
  settings = {python = {analysis={diagnosticSeverityOverrides = { reportUnusedVariable = false, reportMissingImports=true, reportUndefinedVariable="none"}}}},
}

lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "lua" },
}

lspconfig.texlab.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "tex" },
}
