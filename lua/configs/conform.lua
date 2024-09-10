local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    toml = { "taplo" },
    json = { "prettierd" },
    yaml = { "prettierd" },
    markdown = { "prettierd" },
    tex = { "latexindent" }, -- Maybe try llf instead
    bib = { "bibtex-tidy" },
    -- Other stuff supported by the formatters above
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    graphql = { "prettierd" },
    css = { "prettierd" },
    html = { "prettierd" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
