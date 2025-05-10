return {
  {
    dir = function()
      local is_windows = vim.loop.os_uname().version:match "Windows"
      local retval = is_windows and (os.getenv "USERPROFILE" .. "/Repos/myplugin.nvim")
        or (os.getenv "HOME" .. "/Repos/myplugin.nvim")
      return retval
    end,
    config = function()
      print "Running config"
    end,
    lazy = false,
  },
}
