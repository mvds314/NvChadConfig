local config = require "plugins.configs.lspconfig"
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

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
lspconfig.jedi_language_server.setup {
  on_attach = function(client, bufnr)
    -- https://docs.astral.sh/ruff/integrations/#language-server-protocol-official
    -- https://docs.astral.sh/ruff/integrations/#vim-neovim
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
    -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    -- vim.keymap.set('n', '<space>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, bufopts)
    -- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
  end,
  capabilities = capabilities,
  filetypes = { "python" },
  init_options = {
    jediSettings = {
      autoImportModules = { "numpy", "pandas", "matplotlib" },
      caseInsensitiveCompletion = false,
    },
    markupKindPreferred = "markdown",
    completion = { disableSnippets = true, resolveEagerly = true },
    diagnostics = { enable = false },
    hover = { enable = false },
  },
}

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

    -- https://docs.astral.sh/ruff/integrations/#language-server-protocol-official
    -- https://docs.astral.sh/ruff/integrations/#vim-neovim
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "<space>f", function()
      vim.lsp.buf.format { async = true }
    end, bufopts)
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

--lspconfig.azure_pipelines_ls.setup {
--on_attach = on_attach,
--capabilities = capabilities,
--filetypes = { "yaml" },
--}

lspconfig.dockerls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  --note dockerfiles are detected as conf files if they don't have the extension
  filetypes = { "dockerfile", "conf" },
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
