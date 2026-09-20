return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    -- Loading is deferred until one of these keys is pressed.
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<CR>', desc = 'Find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<CR>', desc = 'Grep' },
      { '<leader>fb', '<cmd>Telescope buffers<CR>', desc = 'Buffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<CR>', desc = 'Help' },
    },
    opts = {},
  },
}
