---
name: my-nvchad-config
description: >-
  Reference and troubleshooting guide for this user's personal NvChad-based Neovim
  configuration (repo mvds314/NvChadConfig, lives at ~/AppData/Local/nvim on Windows).
  Use this skill whenever the user is editing, extending, debugging, or asking how their
  Neovim / NvChad setup works — including adding or configuring plugins (lazy.nvim),
  LSP servers, formatters (conform/stylua/ruff), snippets, DAP/debugging, Telescope,
  Harpoon, toggleterm, Copilot/Avante/CopilotChat, MCP servers, the Python host
  detection logic, LaTeX authoring, or Windows-specific path issues. Also use it for
  Neovim GUI problems, especially the nvim-qt "Unknown font: Cascadia Code, Cascadia
  Mono, Consolas, Courier New, monospace" startup warning. Trigger even when the user
  only mentions one piece (e.g. "why does jedi not complete", "add a formatter",
  "my guifont warning"), and prefer this skill over generic Neovim advice because it
  encodes the specific conventions and gotchas of THIS config.
---

# my-nvchad-config

Personal knowledge base for **this user's** Neovim configuration: an
[NvChad v2.5](https://nvchad.com/) setup tuned for scientific Python, LaTeX, and
Lua/config editing. Primary OS is **Windows** (paths use `\`), with Linux as a
secondary target. Repo: `mvds314/NvChadConfig`; on disk at
`C:\Users\<user>\AppData\Local\nvim`.

Use this to answer "how does my setup work?" and to make changes that respect its
conventions instead of generic NvChad defaults. For the nvim-qt font warning, read
`references/nvim-qt-font-warning.md` — it has the full root-cause analysis.

## Architecture map

```
init.lua              Entry point: bootstraps lazy.nvim, loads plugins, options, mappings,
                      sets base46 cache, guicursor, guifont, Avante sign_defines,
                      and the Python-host guidance fallback.
ginit.vim             GUI-only (nvim-qt/gvim) settings: window maximize RPC, guifont,
                      highlight-on-yank. NOTE: only nvim-qt/gvim source this — Neovide,
                      goneovim, fvim, firenvim and vscode-neovim do NOT.
lua/chadrc.lua        NvChad theme/UI config + Mason package list.
lua/options.lua       Vim options (extends nvchad.options).
lua/mappings.lua      Key mappings (extends nvchad.mappings).
lua/autocmds.lua      Autocommands (extends nvchad.autocmds).
lua/plugins/          Plugin specs, auto-imported via { import = "plugins" }:
  init.lua              Core plugins (LSP, treesitter, navigation, UI, flash).
  ai.lua               Copilot, CopilotChat, Avante.
  debug.lua            nvim-dap + dap-python + dapui.
  dev.lua              Local dev plugins (togglepy.nvim, myplugin.nvim) + WinPython discovery.
  luasnip.lua          Snippet configuration.
  surround.lua         Surround plugin.
  telescope.lua        Telescope + extensions.
  toggleterm.lua       Terminal integration.
lua/configs/          Config modules required by plugin specs:
  lspconfig.lua        LSP server setup (Python: jedi + ruff; html/css/json/yaml/...).
  conform.lua          Formatter config (stylua, prettierd, ruff, bibtex-tidy...).
  lazy.lua             lazy.nvim loader options.
  latex.lua            LaTeX spell-file auto-download on tex FileType.
  null-ls.lua          null-ls/none-ls sources.
  codelldb.lua         DAP adapter for codelldb (Rust/C++).
lua/util/             Internal utilities:
  python.lua           Auto-detects a usable Python host (avoids MSYS/MinGW on Windows).
  blink.lua            Visual "blink" helper for Lua run-line mappings.
  helpers.lua          Misc helpers.
mcp-hub/servers.json  MCP server config for mcphub.nvim.
spell/                LaTeX/English spell files.
```

## Lua style (StyLua — `.stylua.toml`)

- indent: **2 spaces**; column width **120**; line endings **Unix**.
- quotes: `AutoPreferDouble`; call parentheses: `None` (omit parens on lone
  string/table args, e.g. `require "nvchad.mappings"`).
- Format with `stylua lua/` (stylua on PATH or via Mason).
- Lint via `luacheck` or `lua-language-server`; `.luarc.json` declares the `vim` global.

## Key conventions

**Plugin specs**
- Everything lazy-loads (`defaults = { lazy = true }` in `configs/lazy.lua`).
- Prefer `opts = {}`; use `config = function()` only when `opts` is insufficient.
- File-type-specific plugins gate loading with `ft = { ... }`.
- New plugins go in `lua/plugins/` (existing thematic file or a new one) — they're
  auto-imported, so no manual registration is needed.

**LSP (`configs/lspconfig.lua`)**
- Simple servers (html, cssls, jsonls, yamlls, …) just get listed in the `servers`
  table — no extra config.
- Python uses **jedi-language-server** for completion/navigation and **ruff** (via
  null-ls/conform) for linting/formatting. Do **not** add pyright/basedpyright unless
  you first remove jedi — they conflict.
- Neovim ≥ 0.11 uses `vim.lsp.enable(servers)`; older uses `lspconfig[lsp].setup {}`.

**Formatting (conform.nvim)**
- Format-on-save is on (`BufWritePre`, 5s timeout, LSP fallback).
- LaTeX formatting is intentionally **disabled** (latexindent issues). Don't re-enable
  without testing.

**Python host (`util/python.lua`)**
- Single source of truth for `vim.g.python3_host_prog`. Filters out MSYS/MinGW/UCRT
  Python on Windows and probes candidates for `pynvim`. Fallback paths point to
  WinPython under `C:\Software\WPy64*`. Edit the fallback list *there*, not in `init.lua`.

**Windows patterns**
- In Lua string literals use `\\` for Windows paths, or build with `os.getenv` + `..`.
- WinPython envs are discovered dynamically in `lua/plugins/dev.lua` via `io.popen`.
- `ginit.vim` handles GUI-specific settings (font, maximize).

**Mappings**
- `<leader>` is `Space`. NvChad base mappings load first via
  `require "nvchad.mappings"`, then custom mappings.
- File-type-specific mappings (e.g. `<F5>` to source a Lua file) live inside `FileType`
  autocommands, not at top level.
- DAP mappings use `<leader>d*`; Harpoon uses `<leader>q*` and `<leader>1`–`4`.

**MCP integration**
- `mcp-hub/servers.json` configures servers for `mcphub.nvim`. `neovim` and `mcphub`
  native servers are enabled; a `time` server is wired via `uvx`. Add new servers there.

**Local plugin development**
- `lua/plugins/dev.lua` loads local checkouts of `togglepy.nvim` and `myplugin.nvim`
  from `~/Repos/` when present. Set `local_dev = false` to force the published GitHub version.

## Making changes safely

- Match StyLua style; run `stylua lua/` after edits.
- Keep GUI-only settings in `ginit.vim`, but remember most GUIs ignore it — put
  font/anything cross-GUI in `init.lua` (`vim.opt.guifont`, read by all GUIs, ignored
  by the terminal).
- Validate by loading Neovim headlessly:
  `nvim --headless -c "lua print(vim.o.guifont)" -c "qa!"` or check `:checkhealth`.
- Don't introduce pyright, re-enable LaTeX formatting, or hard-code the Python host in
  `init.lua` — these are deliberate decisions.

## Known issues / troubleshooting

- **nvim-qt "Unknown font: Cascadia Code, Cascadia Mono, Consolas, Courier New,
  monospace" at startup** → see `references/nvim-qt-font-warning.md`. Short version:
  it's a Neovim 0.12 default `guifont` (a comma fallback list) that nvim-qt can't
  parse. Cosmetic; not fixable from config in nvim-qt. Maintained GUIs (Neovide) don't
  show it.
