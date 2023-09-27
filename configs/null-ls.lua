local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require "null-ls"
local cspell = require "cspell"

local cspellconfig = {
  -- The CSpell configuration file can take a few different names this option
  -- lets you specify which name you would like to use when creating a new
  -- config file from within the `Add word to cspell json file` action.
  --
  -- See the currently supported files in https://github.com/davidmh/cspell.nvim/blob/main/lua/cspell/helpers.lua
  config_file_preferred_name = "cspell.json",

  --- A way to define your own logic to find the CSpell configuration file.
  ---@params cwd The same current working directory defined in the source,
  --             defaulting to vim.loop.cwd()
  ---@return string|nil The path of the json file
  find_json = function(cwd) end,

  ---@param cspell string The contents of the CSpell config file
  ---@return table
  encode_json = function(cspell_str) end,

  ---@param cspell table A lua table with the CSpell config values
  ---@return string
  encode_json = function(cspell_tbl) end,

  --- Callback after a successful execution of a code action.
  ---@param cspell_config_file_path string|nil
  ---@param params GeneratorParams
  ---@action_name 'use_suggestion'|'add_to_json'|'add_to_dictionary'
  on_success = function(cspell_config_file_path, params, action_name)
    -- For example, you can format the cspell config file after you add a word
    if action_name == "add_to_json" then
      os.execute(
        string.format(
          "cat %s | jq -S '.words |= sort' | tee %s > /dev/null",
          cspell_config_file_path,
          cspell_config_file_path
        )
      )
    end

    -- Note: The cspell_config_file_path param could be nil for the
    -- 'use_suggestion' action
  end,
}

local opts = {
  sources = {
    null_ls.builtins.formatting.black.with { extra_args = { "--line-length", 99 } },
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.fixjson,
    null_ls.builtins.formatting.yamlfix,
    null_ls.builtins.formatting.mdformat,
    null_ls.builtins.diagnostics.vint,
    -- cspell.diagnostics.with { config = cspellconfig },
    -- cspell.code_actions.with { config = cspellconfig },
    -- null_ls.builtins.formatting.prettierd,
    -- null_ls.builtins.diagnostics.textidote,
    -- null_ls.builtins.diagnostics.mypy,
    -- null_ls.builtins.diagnostics.ruff.with({ extra_args = { "--ignore","E501" } }),
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
