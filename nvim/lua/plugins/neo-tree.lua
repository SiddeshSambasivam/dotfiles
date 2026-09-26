-- File explorer in a sidebar.
return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    lazy = false, -- neo-tree defers its own loading
    keys = {
      { '<D-b>', '<cmd>Neotree toggle<CR>', desc = 'File explorer' }, -- VS Code's sidebar toggle
    },
  },
}
