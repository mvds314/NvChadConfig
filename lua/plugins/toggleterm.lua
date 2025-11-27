------------------------------ Load the toggleterm plugin ------------------------------
return {
  "akinsho/toggleterm.nvim",
  lazy = true,
  opts = {
    size = 80,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = false,
    insert_mappings = true,
    persist_size = true,
    direction = "float", -- Default direction for terminals
    on_open = function(term)
      -- Only run this logic the first time
      if not term._initialized then
        term._initialized = true -- Mark the terminal as initialized
        vim.api.nvim_chan_send(term.job_id, "cd " .. vim.fn.getcwd() .. "\r\n")
      end
    end,
  },
  keys = {
    { "<C-\\>", mode = { "i", "t", "n" }, "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
    {
      "<C-\\>",
      mode = "n",
      function()
        vim.cmd("ToggleTerm " .. vim.v.count1)
      end,
      desc = "Toggle terminal <count> with <count><C-\\>",
      expr = false,
    },
  },
  cmd = "ToggleTerm",
}
