-- Status line, in the theme vscode.nvim ships for it.
return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = { theme = 'vscode' },
    },
  },
}
