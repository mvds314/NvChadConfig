# NvChad Neovim Config — Copilot Instructions

## Repository overview

This is a personal Neovim configuration built on top of [NvChad v2.5](https://nvchad.com/). It is optimized for scientific Python development, LaTeX authoring, and editing Lua/config files. The config targets both Windows (primary) and Linux.

## Architecture

```
init.lua              — Entry point: bootstraps lazy.nvim, loads plugins, options, mappings
lua/chadrc.lua        — NvChad theme/UI config + Mason package list
lua/options.lua       — Vim options (extends nvchad.options)
lua/mappings.lua      — Key mappings (extends nvchad.mappings)
lua/autocmds.lua      — Autocommands (extends nvchad.autocmds)
lua/plugins/          — Plugin specs imported by lazy.nvim
  init.lua            — Core plugins (LSP, treesitter, navigation, UI)
  ai.lua              — Copilot, CopilotChat, Avante
  debug.lua           — nvim-dap + dap-python + dapui
  dev.lua             — Local dev plugins (togglepy.nvim, myplugin.nvim)
  luasnip.lua         — Snippet configuration
  telescope.lua       — Telescope + extensions
  toggleterm.lua      — Terminal integration
lua/configs/          — Plugin configuration modules (required by plugin specs)
  lspconfig.lua       — LSP server setup (Python via jedi, ruff; + html/css/json/yaml/...)
  conform.lua         — Formatter config (stylua, prettierd, ruff, bibtex-tidy...)
  lazy.lua            — lazy.nvim loader options
  latex.lua           — LaTeX spell-file auto-download on tex FileType
  null-ls.lua         — null-ls/none-ls sources
  codelldb.lua        — DAP adapter for codelldb (Rust/C++)
lua/util/             — Internal utility modules
  python.lua          — Auto-detects a usable Python host (avoids MSYS/MinGW on Windows)
  blink.lua           — Visual "blink" helper used in Lua run-line mappings
  helpers.lua         — Miscellaneous helpers
mcp-hub/servers.json  — MCP server configuration for mcphub.nvim
```

## Lua style (enforced by StyLua)

Settings are in `.stylua.toml`:
- **indent**: 2 spaces
- **column width**: 120
- **line endings**: Unix
- **quotes**: `AutoPreferDouble`
- **call parentheses**: `None` (omit parens on lone string/table args)

Run the formatter: `stylua lua/` (requires `stylua` on PATH or via Mason).

Lint with `luacheck` or the `lua-language-server` (configured in `.luarc.json` — `vim` global is declared).

## Key conventions

### Plugin specs
- All plugins use lazy-loading (`defaults = { lazy = true }` in `configs/lazy.lua`).
- Plugin options go in `opts = {}` when possible; `config = function()` only when `opts` is insufficient.
- File-type-specific plugins use `ft = { ... }` to gate loading.
- New plugins belong in `lua/plugins/` — either an existing thematic file or a new one; they are auto-imported via `{ import = "plugins" }` in `init.lua`.

### LSP setup
- Simple servers (html, cssls, jsonls, yamlls, etc.) are listed in the `servers` table in `configs/lspconfig.lua` — no extra config needed.
- Python uses **jedi-language-server** for completion/navigation and **ruff** (via null-ls/conform) for linting/formatting. Do **not** add pyright/basedpyright without removing jedi to avoid conflicts.
- Neovim ≥ 0.11: uses `vim.lsp.enable(servers)`; older: `lspconfig[lsp].setup {}`.

### Formatting (conform.nvim)
- Format-on-save is enabled (`BufWritePre`) with a 5 s timeout and LSP fallback.
- LaTeX formatting is intentionally disabled (latexindent issues); do not re-enable without testing.

### Python host detection
`util/python.lua` is the single source of truth for `vim.g.python3_host_prog`. It filters out MSYS/MinGW/UCRT Python on Windows and probes candidates for `pynvim`. Fallback paths point to WinPython at `C:\Software\WPy64*`. Modify the fallback list there, not in `init.lua`.

### Windows-specific patterns
- Path separators: always use `\\` in Lua string literals for Windows paths, or build paths with `os.getenv` + `..`.
- WinPython environments are discovered dynamically in `lua/plugins/dev.lua` via `io.popen('dir ...')`.
- `ginit.vim` handles GUI-specific settings (font, etc.).

### Mappings
- `<leader>` is `Space`.
- NvChad base mappings are loaded via `require "nvchad.mappings"` at the top of `mappings.lua`; custom mappings follow.
- File-type-specific mappings (e.g., `<F5>` to source a Lua file) are registered inside `FileType` autocommands, not at the top level.
- DAP mappings use `<leader>d*`; Harpoon uses `<leader>q*` and `<leader>1`–`4`.

### MCP integration
`mcp-hub/servers.json` configures MCP servers for the `mcphub.nvim` plugin. Add new servers there. The `neovim` and `mcphub` native servers are enabled; a `time` server is wired via `uvx`.

### Local plugin development
`lua/plugins/dev.lua` loads local checkouts of `togglepy.nvim` and `myplugin.nvim` from `~/Repos/` when the directories exist. Set `local_dev = false` to force the published version from GitHub.
