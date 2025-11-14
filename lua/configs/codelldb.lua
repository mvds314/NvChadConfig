local dap = require "dap"

------------------------------- Telescope pick process function --------------------------------
-- Note the picker runs async, so after calling it, one needs to wait for the global variable to be set
local selected_pid = nil

local pick_pid_async = function()
  if selected_pid then
    vim.notify("PID already selected: " .. tostring(selected_pid), vim.log.levels.ERROR)
  end
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local utils = require "dap.utils"
  local processes = utils.get_processes()
  local entries = {}
  for _, process in ipairs(processes) do
    table.insert(entries, { process.pid, process.name })
  end
  pickers
    .new({}, {
      prompt_title = "Select Process to Debug",
      finder = finders.new_table {
        results = entries,
        entry_maker = function(entry)
          return {
            value = entry,
            display = string.format("%d: %s", entry[1], entry[2]),
            ordinal = entry[1] .. " " .. entry[2],
          }
        end,
      },
      sorter = require("telescope.config").values.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          selected_pid = selection.value[1]
        end)
        return true
      end,
    })
    :find()
end

local pick_pid = function(callback, timeout)
  -- Initialize
  selected_pid = nil
  local async = require "plenary.async"
  local sleep = async.util.sleep
  timeout = timeout or 50000 -- Default timeout in milliseconds
  -- Run the picker asynchronously, and schedule the callback when done
  async.run(function()
    selected_pid = nil
    pick_pid_async()

    if callback then
      -- Wait for the user to select a PID
      local interval = 100 -- Check every 100ms
      local elapsed = 0

      while not selected_pid and elapsed < timeout do
        sleep(interval)
        elapsed = elapsed + interval
      end
    end
  end, function()
    if callback then
      vim.notify("Running callback after picking the following PID: " .. tostring(selected_pid), vim.log.levels.INFO)
      callback()
    else
      vim.notify("Picked the following PID: " .. tostring(selected_pid), vim.log.levels.INFO)
    end
  end)
end

-- Create a command to pick a PID
vim.api.nvim_create_user_command("PickPID", function()
  pick_pid()
end, { desc = "Find the PID of a running processes" })

-- Override debug continue for rust, start picker first
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust", -- Replace with the filetype or condition for your specific buffer
  callback = function(args)
    local buf = args.buf
    vim.keymap.set("n", "<leader>dc", function()
      pick_pid(function()
        dap.run(dap.configurations.rust[2])
      end)
    end, {
      buffer = buf,
      desc = "Custom <leader>dc for this buffer",
    })
  end,
})

-------------------------------- Debugger configuration --------------------------------
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    -- Note Mason automatically adds codelldb to your PATH
    command = vim.fn.exepath "codelldb",
    args = { "--port", "${port}" },
  },
  initialize_timeout_sec = 20, -- Wait up to 20 seconds for the adapter to start
}
dap.configurations.rust = {
  {
    name = "Launch rust file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fs.joinpath(vim.fn.getcwd(), "target", "debug"), "file")
    end,
    cwd = vim.fn.getcwd(),
    stopOnEntry = false,
  },
  {
    name = "Attach to rust process",
    type = "codelldb",
    request = "attach",
    -- pid = function()
    --   return tonumber(vim.fn.input "Enter PID: ")
    -- end,
    pid = function()
      if not selected_pid then
        return tonumber(vim.fn.input "Enter PID: ")
      else
        return tonumber(selected_pid)
      end
    end,
    cwd = vim.fn.getcwd(),
  },
}

-------------------------------- Set up commands and mappings for rust buffers --------------------------------

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(args)
    local buf = args.buf
    local opts = { buffer = buf, noremap = true, silent = true }
    vim.keymap.set(
      { "n", "i", "v" },
      "<F5>",
      "<cmd> DapContinue <CR>",
      vim.tbl_extend("force", opts, { desc = "Run/Continue" })
    )
    vim.keymap.set(
      "n",
      "<F8>",
      "<cmd> DapToggleBreakpoint <CR>",
      vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" })
    )
    vim.keymap.set(
      "n",
      "<F9>",
      ":lua require('dap').run_to_cursor()<CR>",
      vim.tbl_extend("force", opts, { desc = "Run to cursor" })
    )
    vim.keymap.set("n", "<F10>", "<cmd> DapStepOver <CR>", vim.tbl_extend("force", opts, { desc = "Step over" }))
    vim.keymap.set("n", "<F11>", "<cmd> DapStepInto <CR>", vim.tbl_extend("force", opts, { desc = "Step into" }))
    vim.keymap.set("n", "<S-F11>", "<cmd> DapStepOut <CR>", vim.tbl_extend("force", opts, { desc = "Step out/return" }))
  end,
})
