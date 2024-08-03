-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls" }
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

-- configuring single server, example: typescript
-- lspconfig.tsserver.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }

-------------------------------------- CUSTOM LSPs ------------------------------------------
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

------------------------------------- Python LSPs -------------------------------------------

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
  on_attach = function(_, bufnr)
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
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
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
    -- disable some capabilities https://github.com/astral-sh/ruff-lsp/issues/78
    -- client.server_capabilities.documentFormattingProvider = false

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
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "<leader>fm", function()
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
      format = { args = { "--line-length", "99" } },
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

-------------------------------------- Lua LSPs -------------------------------------------

lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "lua" },
}

-------------------------------------- Other LSPs -------------------------------------------

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

lspconfig.bashls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "sh" },
}

-- TOML lsp
-- Doesn't seem to work for the TOML files I have
-- https://taplo.tamasfe.dev/
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#taplo
-- lspconfig.taplo.setup {
--   on_attach = function(client, bufnr)
--     -- run manually with :lua print(vim.lsp.buf.format())
--     if client.supports_method "textDocument/formatting" then
--       vim.api.nvim_clear_autocmds {
--         group = augroup,
--         buffer = bufnr,
--       }
--       -- https://github.com/nvimtools/none-ls.nvim/wiki/Formatting-on-save
--       vim.api.nvim_create_autocmd("BufWritePre", {
--         group = augroup,
--         buffer = bufnr,
--         callback = function()
--           vim.lsp.buf.format { async = false, timeout_ms = 10000 }
--         end,
--       })
--     end
--
--     -- Enable completion triggered by <c-x><c-o>
--     vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
--
--     -- Mappings.
--     -- See `:help vim.lsp.*` for documentation on any of the below functions
--     local bufopts = { noremap = true, silent = true, buffer = bufnr }
--     vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
--     vim.keymap.set("n", "<leader>fm", function()
--       vim.lsp.buf.format { async = true }
--     end, bufopts)
--   end,
--   capabilities = capabilities,
--   filetypes = { "toml" },
-- }

-- Add additional grammar checking for markdown with grammarly
-- https://github.com/znck/grammarly
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#grammarly

-- add a grammar checker for developers
-- harper-ls
lspconfig.harper_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {
    "markdown",
    "rust",
    "typescript",
    "typescriptreact",
    "javascript",
    "python",
    "go",
    "c",
    "cpp",
    "ruby",
    "swift",
    "csharp",
    "toml",
    "lua",
  },
}

-- https://github.com/elijah-potter/harper
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#harper_ls
-- claims to improve on grammarly, particularly on privacy issues
-- Can be installed with Mason

-- deprecated
-- lspconfig.pkgbuild_language_server.setup {
-- on_attach = on_attach,
-- capabilities = capabilities,
-- filetypes = { "PKGBUILD" },
-- }

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

-- try digestif?
-- It can be installed with Mason
-- https://github.com/astoff/digestif
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#digestif

-- try vale ls?
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#vale_ls
-- Can be installed with Mason
-- https://vale.sh/docs/topics/actions/

-- Check this one out?
-- https://valentjn.github.io/ltex/
-- lspconfig.ltex.setup {
-- on_attach = on_attach,
-- capabilities = capabilities,
-- filetypes = { "tex" },
-- settings = { texlab = { diagnostics = { ignoredPatterns = { "Overfull \\[hv]box", "Unused label" } } } },
-- }
