return {
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {
      surrounds = {
        -- Custom "bold" surround: wraps text in ** ** (Markdown bold)
        ["b"] = {
          add = { "**", "**" },
        },
      },
    },
  },
}
