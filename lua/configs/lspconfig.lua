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
-- lspconfig.ts_ls.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }

-------------------------------------- CUSTOM LSPs ------------------------------------------
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

------------------------------------- Python LSPs -------------------------------------------
local function python_on_attach(_, bufnr)
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
end

-- lspconfig.pyright.setup {
--   on_attach = python_on_attach,
--   capabilities = nvlsp.capabilities,
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

-- Configure Pylyzer
-- lspconfig.pylyzer.setup {
--   on_attach = python_on_attach,
--   -- Add any specific configuration options for Pylyzer here
--   capabilities = nvlsp.capabilities,
--   filetypes = { "python" },
--   settings = {
--     python = {
--       checkOnType = false,
--       diagnostics = false,
--       inlayHints = false,
--       smartCompletion = true,
--     },
--   },
--   single_file_support = true,
--   command = {
--     "pylyzer",
--     "--server",
--     "--disable diagnostics codeLens hover inlayHint semanticTokens signatureHelp documentLink ",
--   },
-- }

-- lspconfig.jedi_language_server.setup {
--   on_attach = function(_, bufnr)
--     -- https://docs.astral.sh/ruff/integrations/#language-server-protocol-official
--     -- https://docs.astral.sh/ruff/integrations/#vim-neovim
--     -- Enable completion triggered by <c-x><c-o>
--     vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
--
--     -- Mappings.
--     -- See `:help vim.lsp.*` for documentation on any of the below functions
--     local bufopts = { noremap = true, silent = true, buffer = bufnr }
--     -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
--     vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
--     vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
--     vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
--     vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
--     -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
--     -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
--     -- vim.keymap.set('n', '<space>wl', function()
--     --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
--     -- end, bufopts)
--     -- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
--     vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
--     vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
--   end,
--   capabilities = nvlsp.capabilities,
--   filetypes = { "python" },
--   init_options = {
--     jediSettings = {
--       autoImportModules = { "numpy", "pandas", "matplotlib" },
--       caseInsensitiveCompletion = false,
--     },
--     markupKindPreferred = "markdown",
--     completion = { disableSnippets = true, resolveEagerly = true },
--     diagnostics = { enable = false },
--     hover = { enable = false },
--   },
-- }

-- https://github.com/astral-sh/ruff-lsp/issues/177
lspconfig.ruff.setup {
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
  capabilities = nvlsp.capabilities,
  filetypes = { "python" },
  init_options = {
    settings = {
      -- https://docs.astral.sh/ruff/editors/setup/#neovim
      lineLength = 99,
    },
  },
}

-------------------------------------- Lua LSPs -------------------------------------------

lspconfig.lua_ls.setup {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  filetypes = { "lua" },
}

-------------------------------------- Other LSPs -------------------------------------------

lspconfig.jsonls.setup {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  filetypes = { "json" },
}

lspconfig.yamlls.setup {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  filetypes = { "yaml" },
}

lspconfig.marksman.setup {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  filetypes = { "markdown" },
}

lspconfig.bashls.setup {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  filetypes = { "sh" },
}

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- formatter for several filetypes, consider moving to this one for json, markdown, yaml and others
-- lspconfig.dprint.setup {
-- on_attach = nvlsp.on_attach,
-- capabilities = nvlsp.capabilities,
-- filetypes = { "toml" },
-- }

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
--   capabilities = nvlsp.capabilities,
--   filetypes = { "toml" },
-- }

-- Add additional grammar checking for markdown with grammarly
-- https://github.com/znck/grammarly
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#grammarly

-- Add a grammar checker for developers
-- harper-ls
lspconfig.harper_ls.setup {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
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
-- on_attach = nvlsp.on_attach,
-- capabilities = nvlsp.capabilities,
-- filetypes = { "PKGBUILD" },
-- }

--lspconfig.azure_pipelines_ls.setup {
--on_attach = nvlsp.on_attach,
--capabilities = nvlsp.capabilities,
--filetypes = { "yaml" },
--}

lspconfig.dockerls.setup {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  --note dockerfiles are detected as conf files if they don't have the extension
  filetypes = { "dockerfile", "conf" },
}

lspconfig.vimls.setup {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  filetypes = { "vim" },
}

-- TODO: make inverse search work?
lspconfig.texlab.setup {
  on_attach = function(client, bufnr)
    -- Call the default on_attach function
    nvlsp.on_attach(client, bufnr)
    -- Add custom keymaps
    local bufopts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lb", "<cmd>TexlabBuild<CR>", bufopts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lf", "<cmd>TexlabForward<CR>", bufopts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>fm", "<cmd>!latexindent % -l 99 -w<CR><cmd>edit!<CR>", bufopts)
  end,
  capabilities = nvlsp.capabilities,
  filetypes = { "tex" },
  settings = {
    texlab = {
      chktex = { onOpenAndSave = true, onEdit = true },
      bibtexFormatter = "texlab",
      latexFormatter = "latexindent",
      formatterLineLength = 99,
      diagnostics = {
        ignoredPatterns = { "Overfull \\[hv]box", "Unused label", "Use either `` or '' as an alternative to" },
      },
      build = { timeout = 3000, forwardSearchAfter = false, onSave = true },
      forwardSearch = {
        executable = "SumatraPDF.exe",
        args = { "-reuse-instance", "%p", "-forward-search", "%f", "%l" },
      },
    },
  },
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
-- on_attach = nvlsp.on_attach,
-- capabilities = nvlsp.capabilities,
-- filetypes = { "tex" },
-- settings = { texlab = { diagnostics = { ignoredPatterns = { "Overfull \\[hv]box", "Unused label" } } } },
-- }
