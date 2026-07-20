# nvim-qt "Unknown font" startup warning

## Symptom

Starting Neovim through **nvim-qt** (`c:\Software\nvim-win64_0.12.4\bin\nvim-qt.exe`)
shows this in `:messages` at startup:

```
Unknown font: Cascadia Code, Cascadia Mono, Consolas, Courier New, monospace
```

The font that actually renders is correct (FiraCode Nerd Font Mono, from nvim-qt's
saved setting). The message is cosmetic noise.

## Root cause (verified)

Two independent facts combine:

1. **Neovim 0.12 ships a default `guifont`** value — a CSS-style fallback list:
   `Cascadia Code,Cascadia Mono,Consolas,Courier New,monospace`. Older Neovim left
   `guifont` empty. Confirmed with `nvim --clean --headless` → the default is that
   comma list even with zero config/plugins.

2. **nvim-qt does not support comma-separated `guifont` fallback lists.** It reads the
   whole string as a single font family, can't find a font literally named
   `"Cascadia Code, Cascadia Mono, Consolas, Courier New, monospace"`, and emits
   `Unknown font: ...`. (This is why installing the individual fonts does NOT help —
   the fonts are all installed; the comma-list *format* is the problem.)

nvim-qt processes/validates this default **at UI-attach, before the user's config
loads**, then applies the real font (FiraCode) from its saved QSettings a moment later.

## What does NOT fix it (each tested by instrumenting nvim-qt)

- Setting `vim.opt.guifont` in `init.lua` — the warning fires *before* config runs. Even
  with `guifont` = FiraCode confirmed set before `UIEnter`, the warning still appeared.
- Setting `guifont` in `ginit.vim` — same reason, and `ginit.vim` is sourced even later.
- The commonly-cited `nvim-qt -- --cmd "set guifont=..."` launch workaround — did **not**
  take effect in this bundled nvim-qt (guifont still showed the default at init start),
  and triggered stuck/errored windows.
- Installing Cascadia / more Nerd Font variants — irrelevant; format is the issue.

## Verification notes (how it was confirmed)

- `nvim --clean` shows the comma-list default → it's a Neovim default, not the config.
- Instrumented run: a minimal `-u <probe>.lua` that logged `guifont` at config start,
  `UIEnter`, and via an `OptionSet guifont` autocmd. Sequence observed:
  `START guifont=[comma list]` → `UIEnter guifont=[comma list]` →
  `OptionSet OLD=[comma list] NEW=[FiraCode Nerd Font Mono:h11]` (nvim-qt applying its
  saved font) → warning `Unknown font: <comma list>` present in `:messages`.
- With `guifont` set to FiraCode at the top of the probe (before UIEnter): START and
  UIEnter both showed FiraCode, yet the `Unknown font: <comma list>` warning STILL
  appeared — proving nvim-qt validates the compiled default independently of the option.
- nvim-qt's saved font lives in the Windows registry:
  `HKCU\Software\nvim-qt\nvim-qt\Gui\Font = FiraCode Nerd Font Mono:h11`.

## Conclusion & options

In this nvim-qt build the warning **cannot be removed from Neovim config**. It's an
nvim-qt limitation vs. Neovim 0.12's new default, and nvim-qt is effectively unmaintained.

Options, in order of least-to-most invasive:

1. **Ignore it** — cosmetic; the correct font (FiraCode) is applied. In normal startup
   it's a single line in `:messages` with no hit-enter prompt.
2. **Switch GUI to Neovide** (or goneovim) — actively maintained, understands the
   comma fallback list, so no warning. Neovide reads `init.lua` (not `ginit.vim`), so the
   `vim.opt.guifont = "FiraCode Nerd Font Mono:h11"` line in `init.lua` already makes it
   render correctly there.
3. **Suppress the message** in config — possible but hacky (e.g. clearing messages after
   startup), and it would hide other startup messages too. Not recommended.

## Config state

`init.lua` sets a single-family guifont for all GUIs (and future-proofs a Neovide switch):

```lua
vim.opt.guifont = "FiraCode Nerd Font Mono:h11"
```

This is correct config hygiene but, per above, does **not** suppress nvim-qt's warning.
`ginit.vim` also sets the same font for nvim-qt (redundant but harmless).

## Upstream references

- Neovim PR that added the default guifont: neovim/neovim (search "default guifont").
- nvim-qt issue tracker: https://github.com/equalsraf/neovim-qt/issues
- Related goneovim report: https://github.com/akiyosi/goneovim/issues/630
