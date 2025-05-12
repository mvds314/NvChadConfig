local is_windows = vim.loop.os_uname().version:match "Windows"
local dir
if is_windows then
  dir = os.getenv "USERPROFILE" .. "/Repos/myplugin.nvim"
else
  dir = os.getenv "HOME" .. "/Repos/myplugin.nvim"
end
local function dir_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == "directory"
end
if dir_exists(dir) then
  return {
    {
      dir = dir,
      enable = false,
      config = function()
        print "Running config"
      end,
      lazy = false,
    },
  }
else
  return {}
end
