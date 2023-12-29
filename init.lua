vim.opt.relativenumber = true

-- Autoreload on buffer change
-- https://stackoverflow.com/questions/62100785/auto-reload-file-and-in-neovim-and-auto-reload-nerbtree
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = { "*" },
})
