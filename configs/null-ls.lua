local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require "null-ls"

local opts = {
  sources = {
    null_ls.builtins.formatting.black.with { extra_args = { "--line-length", 99 } },
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.fixjson,
    null_ls.builtins.formatting.yamlfix,
    null_ls.builtins.formatting.mdformat,
    null_ls.builtins.diagnostics.vint,
    -- null_ls.builtins.formatting.prettierd,
    --null_ls.builtins.diagnostics.textidote,
    --null_ls.builtins.diagnostics.mypy,
    --null_ls.builtins.diagnostics.ruff.with({ extra_args = { "--ignore","E501" } }),
  },
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds {
        group = augroup,
        buffer = bufnr,
      }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format { bufnr = bufnr }
        end,
      })
    end
  end,
}
return opts
