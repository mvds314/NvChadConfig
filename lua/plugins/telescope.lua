return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = function()
        os.execute "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release"
      end,
    },
    -- "nvim-telescope/telescope-fzy-native.nvim",
    -- Test ui-select by using `:lua vim.ui.select({ "a", "b"}, { prompt = "Pick" }, function() end)`
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-telescope/telescope-symbols.nvim",
    "paopaol/telescope-git-diffs.nvim", --TODO: test this plugin
    "nvim-telescope/telescope-file-browser.nvim",
    "SalOrak/whaler",
    -- "kiyoon/telescope-insert-path.nvim", --TODO: Nice idea, but plugin does not work and is not well maintained
    "cagve/telescope-texsuite",
  },
  -- TODO: Test these plugins:
  -- https://github.com/cagve/telescope-texsuite -> for LaTeX, test it further
  -- https://github.com/xiyaowong/telescope-emoji.nvim
  -- neoclip
  -- cmd = { "Telescope", "Telescope whaler" },
  lazy = "VeryLazy",
  opts = function()
    -- Retrieve NvChad default configuration
    local conf = require "nvchad.configs.telescope"
    local is_windows = vim.fn.has "win64" == 1 or vim.fn.has "win32" == 1 or vim.fn.has "win16" == 1
    local is_linux = vim.fn.has "unix" == 1
    -- And edit it as described here: https://nvchad.com/docs/config/plugins
    conf.extensions_list = {
      "themes",
      "terms",
      -- "fzy_native",
      "fzf",
      "whaler",
      "symbols",
      "texsuite",
      "git_diffs",
      "file_browser",
      "ui-select",
      -- "telescope_insert_path",
    }
    -- conf.extensions.fzy_native = { override_generic_sorter = true, override_file_sorter = true }
    conf.extensions.fzf =
      { override_generic_sorter = true, override_file_sorter = true, fuzzy = true, case_mode = "smart_case" }
    conf.extensions["ui-select"] = require("telescope.themes").get_dropdown {}
    -- TODO: this doesn't seem to work properly as bot .git and .gitignore are ignored -> test this in Linux
    -- conf.defaults.file_ignore_patterns = { "^.git/*" }
    -- conf.defaults.file_ignore_patterns = { "%.git/" }
    -- conf.defaults.file_ignore_patterns = { "^.git\\*" }
    -- conf.defaults.file_ignore_patterns = { "^.git\\*" }
    -- conf.defaults.preview.filesize_limit = 10 -- 10 MB limit for previewing
    -- conf.defaults.hidden = true
    -- Add custom mappings to ensure <C-q> only sends selected items to quickfix
    conf.defaults = conf.defaults or {}
    conf.defaults.mappings = conf.defaults.mappings or {}
    conf.defaults.mappings.i = conf.defaults.mappings.i or {}
    conf.defaults.mappings.n = conf.defaults.mappings.n or {}
    -- Send to quickfix list mappings
    local actions = require "telescope.actions"
    conf.defaults.mappings.i["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist
    conf.defaults.mappings.n["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist
    -- Move through results with Alt-j/k
    conf.defaults.mappings.i["<A-j>"] = actions.move_selection_next
    conf.defaults.mappings.i["<A-k>"] = actions.move_selection_previous
    -- Configure whaler extension
    if is_windows then
      conf.extensions.whaler = {
        directories = {
          os.getenv "USERPROFILE" .. "\\Repos",
          vim.fs.joinpath(vim.fn.stdpath "data", "lazy"),
        },
        oneoff_directories = {
          vim.fn.stdpath "config",
          os.getenv "USERPROFILE",
          os.getenv "USERPROFILE" .. "\\AppData\\Local\\clink",
        },
        file_explorer = "nvimtree",
        auto_file_explorer = false, -- Whether to automatically open file explorer. By default is `true`
        auto_cwd = true, -- Whether to automatically change current working directory. By default is `true`
      }
    elseif is_linux then
      local directories = { "~/Repos", "~/WSLRepos", vim.fs.joinpath(vim.fn.stdpath "data", "lazy") }
      local existing_directories = {}
      for _, folder in ipairs(directories) do
        local expanded_folder = vim.fn.expand(folder)
        if vim.loop.fs_stat(expanded_folder) then
          table.insert(existing_directories, folder)
        end
      end
      conf.extensions.whaler = {
        directories = existing_directories,
        oneoff_directories = {
          vim.fn.stdpath "config",
        },
        file_explorer = "nvimtree",
        auto_file_explorer = false, -- Whether to automatically open file explorer. By default is `true`
        auto_cwd = true, -- Whether to automatically change current working directory. By default is `true`
      }
    end
    return conf
  end,
  config = function(_, opts)
    -- Load manually, otherwise ui-select does not work properly
    require("telescope").setup(opts)
    local ok, telescope = pcall(require, "telescope")
    if not ok then
      return
    end
    -- Ensure ui-select actually overrides vim.ui.select / vim.ui.input
    local conf = require "nvchad.configs.telescope"
    for _, ext in ipairs(conf.extensions_list) do
      if conf.extensions[ext] then
        pcall(telescope.load_extension, ext)
      end
    end
  end,
  keys = {
    { "<leader>fd", mode = "n", "<cmd>Telescope whaler<CR>", desc = "Whaler" },
    { "<leader>fr", mode = "n", "<cmd>Telescope resume<CR>", desc = "Resume last search" },
    { "<leader>fs", mode = "n", "<cmd>Telescope symbols<CR>", desc = "Find symbol" },
    { "<leader>fh", mode = "n", "<cmd>Telescope help_tags<CR>", desc = "Find help tags" },
    {
      "<leader>ff",
      mode = "n",
      function() -- <-- add this one
        require("telescope.builtin").find_files {
          find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
        }
      end,
      desc = "Find Files (fd, fast)",
    },
  },
}
