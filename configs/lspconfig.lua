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
-- lspconfig.jedi_language_server.setup {
--   on_attach = on_attach,
--  capabilities = capabilities,
--  filetypes = { "python" },
--}

-- https://github.com/astral-sh/ruff-lsp/issues/177
lspconfig.ruff_lsp.setup {
  on_attach = function(client, bufnr)
    -- run manually with :lua print(vim.lsp.buf.format())
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds {
        group = augroup,
        buffer = bufnr,
      }
      -- https://github.com/nvimtools/none-ls.nvim/wiki/Formatting-on-save
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format { async = false, timeout_ms = 10000 }
        end,
      })
    end
  end,
  capabilities = capabilities,
  filetypes = { "python" },
  -- https://github.com/astral-sh/ruff-lsp/issues/177
  init_options = {
    settings = {
      -- Any extra CLI arguments for `ruff` go here.
      args = {},
      -- Any Linter args go here .
      lint = { args = { "--line-length", "99" } },
      -- ANY  Format args go here.
      fromat = { args = { "--line-length", "99" } },
    },
  },
}

-- https://jdhao.github.io/2023/07/22/neovim-pylsp-setup/
-- lspconfig.pylsp.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   filetypes = { "python" },
--   settings = {
--     pylsp = {
--       -- configurationSources = { "flake8" },
--       plugins = {
--         -- formatters
--         black = { enabled = false, line_length = 99 },
--         autopep8 = { enabled = false },
--         yapf = { enabled = false },
--         --linters
--         pycodestyle = { enabled = false },
--         pydocstyle = { enabled = false },
--         pylint = { enabled = false },
--         flake8 = {
--           enabled = true,
--           ignore = { "E501", "W503", "E741", "E731", "C901" },
--           maxComplexity = 10,
--           maxLineLength = 99,
--         },
--         pyflakes = { enabled = false },
--         maccabe = { enabled = false, threshold = 20 },
--         -- completion
--         jedi_completion = { enabled = false },
--         -- jedi_hover = { enabled = true },
--         -- jedi_references = { enabled = true },
--         -- jedi_signature_help = { enabled = true },
--         -- jedi_symbols = { enabled = true },
--         -- mccabe = { enabled = false },
--         -- preload = { enabled = false },
--         -- rope_completion = { enabled = false },
--         -- rope_rename = { enabled = false },
--       },
--     },
--   },
-- }

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
