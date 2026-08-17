-- Based on NvChad's github_light theme, adjusted for stronger foreground/background separation.

local M = {}

M.base_30 = {
  white = "#1f2328",
  darker_black = "#f1f4f8",
  black = "#ffffff", -- nvim bg
  black2 = "#e7ebf0",
  one_bg = "#e2e8ef",
  one_bg2 = "#d8e0e8", -- StatusBar (filename)
  one_bg3 = "#c3ceda",
  grey = "#8c959f", -- Line numbers
  grey_fg = "#6e7781",
  grey_fg2 = "#57606a",
  light_grey = "#3d444d",
  red = "#a0111f", -- StatusBar (username)
  baby_pink = "#bf3989",
  pink = "#953800",
  line = "#d8e0e8", -- for lines like vertsplit
  green = "#1a7f37",
  vibrant_green = "#116329",
  nord_blue = "#0969da", -- Mode indicator
  blue = "#0550ae",
  yellow = "#9a6700",
  sun = "#b58407",
  purple = "#8250df",
  dark_purple = "#6639ba",
  teal = "#1b7f83",
  orange = "#bc4c00",
  cyan = "#116880",
  statusline_bg = "#e7ebf0",
  lightbg = "#d8e0e8",
  pmenu_bg = "#6639ba",
  folder_bg = "#57606a",
}

M.base_16 = {
  base00 = "#ffffff", -- Default bg
  base01 = "#e7ebf0", -- Lighter bg (status bar, line number, folding mks)
  base02 = "#d8e0e8", -- Selection bg
  base03 = "#8c959f", -- Comments, invisibles, line hl
  base04 = "#6e7781", -- Dark fg (status bars)
  base05 = "#1f2328", -- Default fg (caret, delimiters, operators)
  base06 = "#24292f", -- Light fg (not often used)
  base07 = "#0f1419", -- Light bg (not often used)
  base08 = "#6639ba", -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  base09 = "#953800", -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
  base0A = "#9a6700", -- Classes, Markup Bold, Search Text Background
  base0B = "#116329", -- Strings, Inherited Class, Markup Code, Diff Inserted
  base0C = "#1b7f83", -- Support, regex, escape chars
  base0D = "#0550ae", -- Function, methods, headings
  base0E = "#a0111f", -- Keywords
  base0F = "#024c88", -- Deprecated, open/close embedded tags
}

M.type = "light"

M.polish_hl = {
  treesitter = {
    ["@punctuation.bracket"] = { fg = M.base_30.blue },
    ["@variable.member.key"] = { fg = M.base_30.white },
    ["@constructor"] = { fg = M.base_30.vibrant_green },
    ["@operator"] = { fg = M.base_30.orange },
  },

  syntax = {
    Constant = { fg = M.base_16.base07 },
    Tag = { fg = M.base_30.vibrant_green },
  },
}

M = require("base46").override_theme(M, "github_light_high_contrast")

return M
