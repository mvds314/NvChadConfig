# CSV Viewer Design

## Goal

Visually align columns when viewing CSV and TSV files in Neovim without
rewriting the underlying files.

## Design

Add `hat0uma/csvview.nvim` to the existing lazy.nvim plugin specifications.
Load it only for `csv` and `tsv` filetypes and use the plugin defaults. The
plugin provides buffer-local visual alignment and can be enabled with
`:CsvViewEnable`.

## Validation

Confirm the plugin spec is valid Lua and that lazy.nvim can load the plugin
for CSV/TSV buffers without changing behavior for other filetypes.
