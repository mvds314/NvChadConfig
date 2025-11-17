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
      vim.notify("Toggling terminal and navigating to " .. vim.fn.getcwd(), vim.log.levels.INFO)
      vim.api.nvim_chan_send(term.job_id, "cd " .. vim.fn.getcwd() .. "\n")
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
