return {
  {
    'folke/tokyonight.nvim',
    lazy = false,   -- a colorscheme should load immediately
    priority = 1000, -- and before everything else
    config = function()
      require('tokyonight').setup { style = 'night' }
      vim.cmd.colorscheme 'tokyonight'
    end,
  },
}
