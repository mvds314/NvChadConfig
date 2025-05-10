local is_windows = vim.loop.os_uname().version:match "Windows"
local dir
if is_windows then
  dir = os.getenv "USERPROFILE" .. "/Repos/myplugin.nvim"
else
  dir = os.getenv "HOME" .. "/Repos/myplugin.nvim"
end
return {
  {
    dir = dir,
    config = function()
      print "Running config"
    end,
    lazy = false,
  },
}
