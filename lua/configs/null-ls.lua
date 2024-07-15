local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require "null-ls"

local opts = {
  sources = {
    -- Python
    -- null_ls.builtins.formatting.black.with { extra_args = { "--line-length", 99 } },
    -- require("none-ls.formatting.ruff"),--.with { extra_args = { "--line-length", 99 } }, -- for some reason this does not work
    -- null_ls.builtins.diagnostics.pylint,
    -- null_ls.builtins.diagnostics.flake8,
    -- null_ls.builtins.diagnostics.mypy,
    -- null_ls.builtins.diagnostics.ruff.with {
    -- extra_args = { "--ignore", "E501", "--ignore", "E741", "--ignore", "E731", "--ignore", "E402" },
    -- },
    -- null_ls.builtins.code_actions.refactoring.with { filetypes = { "python" } },
    -- Formatters: Lua, json, yaml, md
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettierd.with {
      filetypes = { "json", "yaml", "markdown" },
    },
    -- null_ls.builtins.formatting.yamlfix,
    -- null_ls.builtins.formatting.mdformat,
    -- Spelling
    null_ls.builtins.diagnostics.codespell,
    -- null_ls.builtins.formatting.codespell,
    -- Vim script
    null_ls.builtins.diagnostics.vint,
    null_ls.builtins.diagnostics.hadolint.with {
      filetypes = { "dockerfile" },
    },
    -- Bash
    null_ls.builtins.formatting.shfmt.with { filetypes = { "sh" } },
    -- LaTeX
    -- null_ls.builtins.formatting.latexindent,
    -- other spell checkers I tried
    -- null_ls.builtins.diagnostics.vale,
    null_ls.builtins.diagnostics.proselint.with { filetypes = { "markdown", "tex" } },
    null_ls.builtins.code_actions.proselint.with { filetypes = { "markdown", "tex" } },
    -- chktex does not work well when using \input{myfile.tex}
    -- null_ls.builtins.diagnostics.chktex,
    -- null_ls.builtins.diagnostics.textidote,
  },
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
}
return opts
