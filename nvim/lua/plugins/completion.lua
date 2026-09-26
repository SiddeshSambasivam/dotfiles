-- Completion menu that opens as you type. Items come from the file's
-- language server first, then file paths, snippets and words already in
-- open buffers, so a language with no server still gets word completion.
--
-- Enter accepts the highlighted item, Up/Down or Ctrl-n/Ctrl-p move,
-- Ctrl-e hides the menu, Ctrl-Space opens it or shows the docs.
return {
  {
    'saghen/blink.cmp',
    -- A release tag, so lazy downloads the prebuilt matcher library
    -- rather than compiling it.
    version = '1.*',
    event = 'InsertEnter',
    opts = {
      keymap = { preset = 'enter' },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
  },
}
