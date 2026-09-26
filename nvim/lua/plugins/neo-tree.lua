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
    opts = {
      default_component_configs = {
        -- Names stay the normal text colour. Git status still shows as
        -- the coloured marker at the right edge (? untracked, and so on).
        name = { use_git_status_colors = false },
      },
    },
    keys = {
      { '<D-b>', '<cmd>Neotree toggle<CR>', desc = 'File explorer' }, -- VS Code's sidebar toggle
    },
  },
}
