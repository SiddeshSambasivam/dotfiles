-- Completion menu that opens as you type. Items come from the file's
-- language server first, then file paths, snippets and words already in
-- open buffers, so a language with no server still gets word completion.
--
-- Enter accepts the highlighted item, Up/Down or Ctrl-n/Ctrl-p move,
-- Ctrl-e hides the menu, Ctrl-Space opens it, Ctrl-k toggles the parameter hint.
return {
  {
    'saghen/blink.cmp',
    -- A release tag, so lazy downloads the prebuilt matcher library
    -- rather than compiling it.
    version = '1.*',
    event = 'InsertEnter',
    opts = {
      keymap = { preset = 'enter' },
      -- Like VS Code: the highlighted item's type and docs open beside the
      -- menu, and typing ( shows the parameters of the call.
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      signature = { enabled = true },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
  },
}
