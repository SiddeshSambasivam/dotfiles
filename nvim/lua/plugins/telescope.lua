-- Fuzzy finder. live_grep shells out to ripgrep, which home.nix installs.
return {
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = 'Telescope',
    keys = {
      -- Cmd-p and Cmd-Shift-f are VS Code's quick open and search.
      { '<D-p>', '<cmd>Telescope find_files<CR>', desc = 'Find files' },
      { '<D-S-f>', '<cmd>Telescope live_grep<CR>', desc = 'Grep' },
      { '<D-e>', '<cmd>Telescope buffers<CR>', desc = 'Open buffers' },
    },
  },
}
