local is_windows = vim.loop.os_uname().version:match "Windows"
return {
  {
    dir = is_windows and (os.getenv "USERPROFILE" .. "/Repos/myplugin.nvim")
      or (os.getenv "HOME" .. "/Repos/myplugin.nvim"),
  },
}
