-- Status line, in the theme vscode.nvim ships for it.
return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = { theme = 'vscode' },
      -- In the tree window, show the directory instead of neo-tree's
      -- internal buffer name.
      extensions = { 'neo-tree' },
    },
  },
}
