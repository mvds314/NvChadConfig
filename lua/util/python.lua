local M = {}
-- and set vim.g.python3_host_prog accordingly.
-- Windows-aware, avoids MSYS/MinGW/UCRT Python, and checks for 'pynvim'.

local function is_windows()
  return vim.fn.has "win32" == 1 or vim.fn.has "win64" == 1
end

-- Reject MSYS/MinGW Python (not suitable for Neovim provider)
local function looks_like_msys_python(p)
  if not p or p == "" then
    return false
  end
  local lower = p:lower()
  return lower:find "\\msys64\\"
    or lower:find "/msys64/"
    or lower:find "\\mingw64\\"
    or lower:find "/mingw64/"
    or lower:find "\\ucrt64\\"
    or lower:find "/ucrt64/"
end

-- Try to resolve an executable name to a full path on PATH
-- Uses exepath (portable), falling back to a simple heuristic.
local function resolve_on_path(name)
  local p = vim.fn.exepath(name)
  if p and p ~= "" then
    return p
  end
  return nil
end

-- Run `python -c "import pynvim; print(1)"` to verify pynvim presence.
local function python_has_pynvim(python)
  local cmd = { python, "-c", "import pynvim; print(1)" }
  local ok, out, code
  if vim.system then
    local res = vim.system(cmd, { text = true }):wait()
    code = res.code
    out = res.stdout or ""
    ok = (code == 0) and out:match "1"
  else
    -- Neovim < 0.10 fallback
    local result = vim.fn.systemlist(cmd)
    local exit_code = vim.v.shell_error
    out = table.concat(result or {}, "\n")
    ok = (exit_code == 0) and out:match "1"
  end
  return ok and true or false
end

-- Main autodetect routine
local function autodetect_python_host()
  local candidates = {}

  -- 1) Prefer commands the user would run in *this terminal*
  table.insert(candidates, resolve_on_path "python")
  table.insert(candidates, resolve_on_path "python3")

  -- 2) De-duplicate and filter nils
  local uniq = {}
  local seen = {}
  for _, p in ipairs(candidates) do
    if p and p ~= "" and not seen[p] then
      table.insert(uniq, p)
      seen[p] = true
    end
  end

  -- 3) On Windows, avoid MSYS/MinGW/UCRT Python; WinPython is fine
  if is_windows() then
    local filtered = {}
    for _, p in ipairs(uniq) do
      if not looks_like_msys_python(p) then
        table.insert(filtered, p)
      end
    end
    uniq = filtered
  end

  -- 4) Probe each candidate for pynvim
  for _, py in ipairs(uniq) do
    if python_has_pynvim(py) then
      return py
    end
  end

  -- 5) As a last resort on Windows, try common official/WinPython locations
  if is_windows() then
    local fallback_dirs = {
      -- Official python.org default locations by version (edit if needed)
      os.getenv "LOCALAPPDATA" and (os.getenv "LOCALAPPDATA" .. "\\Programs\\Python\\Python312\\python.exe") or nil,
      os.getenv "LOCALAPPDATA" and (os.getenv "LOCALAPPDATA" .. "\\Programs\\Python\\Python311\\python.exe") or nil,
      -- Your WinPython paths (edit to what you actually use)
      "C:\\Software\\WPy64-31350\\python\\python.exe",
      "C:\\Software\\WPy64-312101\\python\\python.exe",
    }
    for _, py in ipairs(fallback_dirs) do
      if py and vim.fn.filereadable(py) == 1 and not looks_like_msys_python(py) then
        if python_has_pynvim(py) then
          return py
        end
      end
    end
  end

  return nil
end

M.autodetect_python_host = autodetect_python_host
return M
