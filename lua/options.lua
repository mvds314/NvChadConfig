require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- Autoreload on buffer change
-- https://stackoverflow.com/questions/62100785/auto-reload-file-and-in-neovim-and-auto-reload-nerbtree
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = { "*" },
})

--Relative line numbers
vim.wo.relativenumber = true

--Use clipboard for copy/paste
vim.opt.clipboard = "unnamedplus"

--File format to unix
vim.opt.fileformat = "unix"
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*",
  callback = function()
    if vim.bo.modifiable then
      local old_format = vim.bo.fileformat
      if old_format ~= "unix" then
        vim.bo.fileformat = "unix"
        vim.notify("File format converted from " .. old_format .. " to unix", vim.log.levels.INFO)
      end
    end
  end,
})

-- Set max size of lsp log files
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local log_path = vim.lsp.get_log_path()
    local max_bytes = 100 * 1024 -- 100 KB
    local stat = vim.uv.fs_stat(log_path)
    if stat and stat.size > max_bytes then
      local f = io.open(log_path, "w")
      if f then
        f:write "" -- Truncate the file
        f:close()
        vim.notify("LSP log truncated", vim.log.levels.INFO)
      end
    end
  end,
})
