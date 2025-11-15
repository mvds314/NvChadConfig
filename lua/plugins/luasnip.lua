local ls = require "luasnip"
local s = ls.snippet
local t = ls.text_node
-- local i = ls.insert_node

-- Register snippets
ls.add_snippets("python", {
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
  s("ifmain", {
    t {
      "if __name__ == '__main__':",
      "    ",
    },
  }),
  s("ipdab", {
    t {
      "import ipdab",
      "",
      "ipdab.set_trace()",
    },
  }),
  s("pdb", {
    t {
      "import pdb",
      "",
      "pdb.set_trace()",
    },
  }),
  s("ipdbp", {
    t {
      "import ipdb",
      "",
      "ipdb.set_trace()",
    },
  }),
})

-- TODO: Add more snippets as needed

return {}
