# Parquet Viewer Design

## Goal

Preview and query Parquet files directly inside Neovim without changing the
underlying files or adding a system-specific DuckDB installation step to the
configuration.

## Design

Add `kyytox/data-explorer.nvim` to the lazy.nvim plugin specifications. Load it
when either of its user commands is invoked, and use its default configuration.
The existing Telescope installation satisfies the plugin dependency.

DuckDB remains an external prerequisite and must be installed separately with
the `duckdb` executable available on `PATH`. The plugin exposes:

- `:DataExplorer` to find and explore supported data files.
- `:DataExplorerFile` to open a specific data file.

## Validation

Confirm the plugin specification is valid Lua and that the repository change
is committed and pushed without modifying unrelated configuration.
