return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = function()
        os.execute "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release"
      end,
    },
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
      "fzy_native",
      "whaler",
      "symbols",
      "texsuite",
      "git_diffs",
      "file_browser",
      -- "telescope_insert_path",
    }
    conf.extensions.fzy_native = { override_generic_sorter = true, override_file_sorter = true }
    -- TODO: this doesn't seem to work properly as bot .git and .gitignore are ignored -> test this in Linux
    -- conf.defaults.file_ignore_patterns = { "^.git/*" }
    -- conf.defaults.file_ignore_patterns = { "%.git/" }
    -- conf.defaults.file_ignore_patterns = { "^.git\\*" }
    -- conf.defaults.file_ignore_patterns = { "^.git\\*" }
    -- conf.defaults.preview.filesize_limit = 10 -- 10 MB limit for previewing
    -- conf.defaults.hidden = true
    if is_windows then
      conf.extensions.whaler = {
        directories = {
          os.getenv "USERPROFILE" .. "\\Repos",
          vim.fs.joinpath(vim.fn.stdpath "data", "lazy"),
        },
        oneoff_directories = {
          vim.fn.stdpath "config",
          os.getenv "USERPROFILE",
        },
        file_explorer = "nvimtree",
        auto_file_explorer = false, -- Whether to automatically open file explorer. By default is `true`
        auto_cwd = true, -- Whether to automatically change current working directory. By default is `true`
      }
    elseif is_linux then
      conf.extensions.whaler = {
        directories = { "~/Repos", vim.fs.joinpath(vim.fn.stdpath "data", "lazy") },
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
  keys = {
    { "<leader>fd", mode = "n", "<cmd>Telescope whaler<CR>", desc = "Whaler" },
    { "<leader>fr", mode = "n", "<cmd>Telescope resume<CR>", desc = "Resume last search" },
    { "<leader>fs", mode = "n", "<cmd>Telescope symbols<CR>", desc = "Find symbol" },
    { "<leader>fh", mode = "n", "<cmd>Telescope help_tags<CR>", desc = "Find help tags" },
  },
}
