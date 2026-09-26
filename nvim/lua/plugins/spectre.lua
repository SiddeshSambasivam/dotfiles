-- Project-wide search and replace. Searches with ripgrep, replaces with sed.
return {
  {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = 'Spectre',
    keys = {
      { '<leader>S', function() require('spectre').toggle() end, desc = 'Search and replace' },
    },
    opts = {},
  },
}
