return {
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {
      surrounds = {
        -- Custom "bold" surround: wraps text in ** ** (Markdown bold).
        -- Bound to "*" since "b" is a reserved default alias for ")".
        ["*"] = {
          add = { "**", "**" },
        },
      },
    },
  },
}
