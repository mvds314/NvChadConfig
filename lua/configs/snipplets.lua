local ls = require "luasnip"
local s = ls.snippet
local t = ls.text_node
-- local i = ls.insert_node
-- TODO: load these snippets somewhere

ls.snippets = {
  python = {
    s("debugpy", {
      t {
        "import debugpy",
        "",
        "debugpy.listen(('0.0.0.0', 5678))",
        "print('Waiting for debugger attach...')",
        "debugpy.wait_for_client()",
        "print('Debugger attached.')",
        "",
      },
    }),
  },
}
