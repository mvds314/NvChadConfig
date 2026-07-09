-- Some logic to autmatically download the spell files if not present
local sep = package.config:sub(1, 1)
local spell_dir = vim.fn.stdpath "config" .. sep .. "spell"
local files = {
  "en.utf-8.spl",
  "en.utf-8.sug",
  "nl.utf-8.spl",
  "nl.utf-8.sug",
}

local base_url = "https://ftp.nluug.nl/pub/vim/runtime/spell/"

-- Function to download a file using curl
local function download_file(filename)
  local url = base_url .. filename
  local output_path = vim.fn.fnamemodify(spell_dir, ":p") .. filename
  -- Use double quotes: single quotes are not treated as quoting on Windows (cmd.exe)
  local cmd = string.format('curl -fLo "%s" --create-dirs "%s"', output_path, url)
  vim.notify(cmd, vim.log.levels.DEBUG)
  vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to download spell file: " .. filename, vim.log.levels.ERROR)
  end
end

local files_downloaded = false

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    -- Download spell files if not already done
    if not files_downloaded then
      -- Ensure spell directory exists
      if vim.fn.isdirectory(spell_dir) == 0 then
        vim.fn.mkdir(spell_dir, "p")
      end

      -- Check and download missing files
      for _, file in ipairs(files) do
        local path = spell_dir .. "/" .. file
        if vim.fn.filereadable(path) == 0 then
          vim.notify("Downloading missing spell file: " .. file)
          download_file(file)
        end
      end
      files_downloaded = true
    end
    -- Add the spell checking only for latex files
    vim.opt_local.spell = true
    vim.opt_local.spelllang = {
      "en_us",
      "nl",
    }
  end,
})
