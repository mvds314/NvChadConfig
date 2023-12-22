local config = require "plugins.configs.lspconfig"

local on_attach = config.on_attach
local capabilities = config.capabilities

local lspconfig = require "lspconfig"

-- lspconfig.pyright.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   filetypes = { "python" },
--   -- https://github.com/microsoft/pyright/blob/main/docs/settings.md
--   settings = {
--     python = {
--       analysis = {
--         diagnosticSeverityOverrides = {
--           reportUnusedVariable = false,
--           reportMissingImports = true,
--           reportUndefinedVariable = "none",
--         },
--         typeCheckingMode = "off",
--       },
--     },
--   },
-- }

-- https://jdhao.github.io/2023/07/22/neovim-pylsp-setup/
lspconfig.pylsp.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "python" },
  settings = {
    pylsp = {
      -- configurationSources = { "black" },
      plugins = {
        -- formatters
        black = { enabled = false, line_length = 99 },
        autopep8 = { enabled = false },
        yapf = { enabled = false },
        --linters
        pycodestyle = { enabled = false },
        pydocstyle = { enabled = false },
        pylint = { enabled = false },
        flake8 = { enabled = true, ignore = { "E501", "W503", "E741", "E731" } },
        pyflakes = { enabled = false },
        -- completion
        jedi_completion = { enabled = true },
        -- jedi_hover = { enabled = true },
        -- jedi_references = { enabled = true },
        -- jedi_signature_help = { enabled = true },
        -- jedi_symbols = { enabled = true },
        -- mccabe = { enabled = false },
        -- preload = { enabled = false },
        -- rope_completion = { enabled = false },
        -- rope_rename = { enabled = false },
      },
    },
    --     python = {
    --       analysis = {
    --         diagnosticSeverityOverrides = {
    --           reportUnusedVariable = false,
    --           reportMissingImports = true,
    --           reportUndefinedVariable = "none",
    --         },
    --         typeCheckingMode = "off",
    --       },
    --     },
  },
}

lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "lua" },
}

lspconfig.jsonls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "json" },
}

lspconfig.yamlls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "yaml" },
}

lspconfig.marksman.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "markdown" },
}

lspconfig.vimls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "vim" },
}

lspconfig.texlab.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "tex" },
  settings = { texlab = { diagnostics = { ignoredPatterns = { "Overfull \\[hv]box", "Unused label" } } } },
}

-- lspconfig.ltex.setup {
-- on_attach = on_attach,
-- capabilities = capabilities,
-- filetypes = { "tex" },
-- settings = { texlab = { diagnostics = { ignoredPatterns = { "Overfull \\[hv]box", "Unused label" } } } },
-- }
