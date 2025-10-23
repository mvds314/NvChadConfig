vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function(args)
    local buf = args.buf
    -- Add the spell checking only for latex files
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en_us", "nl" }
  end,
})
