# Plan: load local copilot.lua checkout in NvChad config (until upstream fix merges)

## Goal
Use `~/Repos/copilot.lua` (branch `fix/windows-msys-sysname`, fixes MinGW/MSYS2 sysname detection)
instead of the published zbirenbaum/copilot.lua, following the existing local-dev pattern in
`lua/plugins/dev.lua`, so Copilot works again on MSYS2 UCRT64 nvim.

## Scope / files
Status: [x] dev.lua block, [x] copilot-instructions.md, [x] verification, [x] outside-repo `doc/tags`
exclude.
- [x] `lua/plugins/dev.lua`: add, after the togglepy `if/else` and before the autocmds, with its own flag:
  ```lua
  -- Temporary: local copilot.lua checkout with the MinGW/MSYS Windows-detection fix
  -- (mvds314/copilot.lua branch fix/windows-msys-sysname). Remove once released upstream.
  local copilot_local = true
  local copilot_dir = (is_windows and os.getenv "USERPROFILE" or os.getenv "HOME") .. "/Repos/copilot.lua"
  if copilot_local and dir_exists(copilot_dir) then
    table.insert(M, { "zbirenbaum/copilot.lua", dir = copilot_dir })
  end
  ```
  lazy.nvim merges this fragment with the full spec in `lua/plugins/ai.lua` (same name `copilot.lua`);
  only `dir` is overridden, opts/config/event/dependencies/build stay in ai.lua. (Architect verified
  in lazy `core/meta.lua` `_rebuild`.)
- [x] `.github/copilot-instructions.md`: mention the temporary copilot.lua checkout + `copilot_local` flag
  in "Local plugin development" and the dev.lua line of the architecture tree.
- [x] Outside the repo: add `doc/tags` to `~/Repos/copilot.lua/.git/info/exclude` (lazy runs helptags
  in local plugins; keep the PR branch clean).

## Non-goals (unchanged)
- No change to ai.lua; no other plugins.

## Verification (pass/fail)
- Headless with the real config on **MSYS2 UCRT64 nvim**:
  `require("lazy.core.config").plugins["copilot.lua"].dir` == `<USERPROFILE>/Repos/copilot.lua`;
  after loading, `copilot.client.startup_error == nil` and a `copilot` LSP client attaches.
- Edge: with `copilot_local = false` (or missing dir) the published plugin path is used.
- `stylua --check` on dev.lua.

## Risks
- lazy omits local (`dir`) plugins from `lazy-lock.json`: the next `:Lazy update/sync/install` drops
  the `copilot.lua` entry. Do NOT commit that lock change; restore it when the block is removed.
- `:Lazy clean`/`:Lazy sync` will delete the published clone in `nvim-data/lazy/copilot.lua`
  (harmless; re-cloned after reverting).
- `:Lazy update` won't update the checkout (intended); `build = ":Copilot auth"` won't auto-run.
- Remove the block once the upstream PR is merged and released.

## Outcome
Implemented exactly as planned. Deviations: none.

Verification (all pass):
- [x] Headless real-config load on MSYS2 UCRT64 nvim 0.12.6: plugin dir =
  `C:/Users/ROB6027/Repos/copilot.lua`, module loaded from the checkout, copilot client initialized
  with no `startup_error` and attached to the buffer.
- [x] Edge: `copilot_local = false` or missing dir → no override.
- [x] stylua PASS, luacheck PASS (0 new warnings), smoke PASS on MSYS2 and official nvim.
- Note: stylua reports a pre-existing, unrelated diff in `lua/chadrc.lua` (not touched).

Open: block removal is pending the upstream release.
