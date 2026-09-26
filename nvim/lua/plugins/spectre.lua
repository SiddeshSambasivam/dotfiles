-- Project-wide search and replace. Searches with ripgrep, replaces with sed.
return {
  {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = 'Spectre',
    keys = {
      -- VS Code's Cmd-Shift-h is taken by macOS (drag window to Space).
      { '<D-S-r>', function() require('spectre').toggle() end, desc = 'Search and replace' },
    },
    opts = {},
  },
}
