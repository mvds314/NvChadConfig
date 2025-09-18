require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls" }
-- read :h vim.lsp.config for changing options of lsp servers
local lspconfig = require "lspconfig"
-- local lspconfig = vim.lsp.config
local nvlsp = require "nvchad.configs.lspconfig"

if vim.version().minor >= 11 then
  vim.lsp.enable(servers)
else
  for _, lsp in ipairs(servers) do
    if vim.lsp.config(lsp) then
      vim.lsp.config(lsp).setup {
        on_attach = nvlsp.on_attach,
        capabilities = nvlsp.capabilities,
      }
    end
  end
end

-------------------------------------- CUSTOM LSPs ------------------------------------------
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

------------------------------------- Python LSPs -------------------------------------------
local function python_on_attach(_, bufnr)
  -- https://docs.astral.sh/ruff/integrations/#language-server-protocol-official
  -- https://docs.astral.sh/ruff/integrations/#vim-neovim
  -- Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

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

-- vim.lsp.config.basedpyright.setup {
--   on_attach = python_on_attach,
--   capabilities = nvlsp.capabilities,
--   filetypes = { "python" },
--   settings = {
--     basedpyright = {
--       analysis = {
--         autoSearchPaths = true,
--         diagnosticMode = "openFilesOnly",
--         useLibraryCodeForTypes = true,
--       },
--     },
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
--   single_file_support = true,
-- }

-- vim.lsp.config.pyright.setup {
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
-- vim.lsp.config.pylyzer.setup {
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

vim.lsp.config("jedi_language_server", {
  on_attach = python_on_attach,
  capabilities = nvlsp.capabilities,
  filetypes = { "python" },
  init_options = {
    jediSettings = {
      autoImportModules = { "numpy", "scipy", "pandas", "matplotlib", "seaborn", "statsmodels" },
      caseInsensitiveCompletion = true,
    },
    markupKindPreferred = "markdown",
    completion = { disableSnippets = true, resolveEagerly = false },
    diagnostics = { enable = false },
    hover = { enable = true },
  },
})
vim.lsp.enable "jedi_language_server"

-- https://github.com/astral-sh/ruff-lsp/issues/177
vim.lsp.config("ruff", {
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
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

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
})
vim.lsp.enable "ruff"

-------------------------------------- Lua LSPs -------------------------------------------

vim.lsp.config("lua_ls", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = { "lua/?.lua", "lua/?/init.lua" },
      },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})
vim.lsp.enable "lua_ls"

--------------------------------------- Rust -------------------------------------------

vim.lsp.config("rust_analyzer", {
  on_attach = function(_, bufnr)
    -- Mappings.
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
  end,
  capabilities = vim.tbl_extend("force", nvlsp.capabilities, {
    offsetEncoding = { "utf-8" },
  }),
  filetypes = { "rust" },
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      checkOnSave = {
        enable = true,
        command = "clippy", -- use clippy diagnostics
      },
      procMacro = {
        enable = true,
      },
      diagnostics = {
        enable = true,
      },
      inlayHints = {
        lifetimeElisionHints = { enable = "always" },
        bindingModeHints = { enable = true },
        closingBraceHints = { enable = true },
        closureReturnTypeHints = { enable = "always" },
        parameterHints = { enable = true },
        typeHints = { enable = true },
      },
    },
  },
})
vim.lsp.enable "rust_analyzer"

-------------------------------------- Other LSPs -------------------------------------------

vim.lsp.config("jsonls", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  filetypes = { "json" },
})
vim.lsp.enable "jsonls"

vim.lsp.config("yamlls", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  filetypes = { "yaml" },
})
vim.lsp.enable "yamlls"

vim.lsp.config("marksman", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  filetypes = { "markdown" },
})
vim.lsp.enable "marksman"

vim.lsp.config("bashls", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  filetypes = { "sh" },
})
vim.lsp.enable "bashls"

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- formatter for several filetypes, consider moving to this one for json, markdown, yaml and others
-- vim.lsp.config.dprint.setup {
-- on_attach = nvlsp.on_attach,
-- capabilities = nvlsp.capabilities,
-- filetypes = { "toml" },
-- }

-- TOML lsp
-- Doesn't seem to work for the TOML files I have
-- https://taplo.tamasfe.dev/
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#taplo
-- vim.lsp.config.taplo.setup {
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
-- vim.lsp.config.harper_ls.setup {
--   on_attach = nvlsp.on_attach,
--   capabilities = nvlsp.capabilities,
--   filetypes = {
--     "markdown",
--     "rust",
--     "typescript",
--     "typescriptreact",
--     "javascript",
--     "python",
--     "go",
--     "c",
--     "cpp",
--     "ruby",
--     "swift",
--     "csharp",
--     "toml",
--     "lua",
--   },
-- }

-- https://github.com/elijah-potter/harper
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#harper_ls
-- claims to improve on grammarly, particularly on privacy issues
-- Can be installed with Mason

-- deprecated
-- vim.lsp.config.pkgbuild_language_server.setup {
-- on_attach = nvlsp.on_attach,
-- capabilities = nvlsp.capabilities,
-- filetypes = { "PKGBUILD" },
-- }

--vim.lsp.config.azure_pipelines_ls.setup {
--on_attach = nvlsp.on_attach,
--capabilities = nvlsp.capabilities,
--filetypes = { "yaml" },
--}

vim.lsp.config("dockerls", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  --note dockerfiles are detected as conf files if they don't have the extension
  filetypes = { "dockerfile", "conf" },
})
vim.lsp.enable "dockerls"

vim.lsp.config("vimls", {
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  filetypes = { "vim" },
})
vim.lsp.enable "vimls"

-- TODO: make inverse search work?
vim.lsp.config("texlab", {
  on_attach = function(client, bufnr)
    -- Call the default on_attach function
    nvlsp.on_attach(client, bufnr)
    -- Add custom keymaps
    local bufopts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lb", "<cmd>TexlabBuild<CR>", bufopts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lf", "<cmd>TexlabForward<CR>", bufopts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>fm", "<cmd>!latexindent % -l 99 -w<CR><cmd>edit!<CR>", bufopts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>fm", "<cmd>!tex-fmt % -n<CR><cmd>edit!<CR>", bufopts)
  end,
  capabilities = nvlsp.capabilities,
  filetypes = { "tex" },
  settings = {
    texlab = {
      -- Enable detailed logging:
      logFile = "C:\\Users\\ROB6027\\AppData\\Local\\Temp\\texlab.log",
      logLevel = "trace",
      chktex = { onOpenAndSave = true, onEdit = true },
      bibtexFormatter = "texlab",
      -- latexFormatter = "latexindent",
      latexFormatter = "none",
      formatterLineLength = 99,
      diagnostics = {
        ignoredPatterns = { "Overfull \\[hv]box", "Unused label", "Use either `` or '' as an alternative to" },
      },
      build = {
        executable = "latexmk",
        args = { "-pdf", "-pdflatex=pdflatex", "-bibtex", "-interaction=nonstopmode", "-synctex=1" },
        timeout = 10000,
        forwardSearchAfter = false,
        onSave = true,
      },
      forwardSearch = {
        executable = "SumatraPDF.exe",
        args = { "-reuse-instance", "%p", "-forward-search", "%f", "%l" },
      },
    },
  },
})
vim.lsp.enable "texlab"

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
-- vim.lsp.config.ltex.setup {
-- on_attach = nvlsp.on_attach,
-- capabilities = nvlsp.capabilities,
-- filetypes = { "tex" },
-- settings = { texlab = { diagnostics = { ignoredPatterns = { "Overfull \\[hv]box", "Unused label" } } } },
-- }
