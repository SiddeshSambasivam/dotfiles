-- VS Code's Dark Modern palette. Loads first, before anything that reads
-- highlight groups, so lualine and bufferline pick up its colours.
return {
  {
    'Mofiqul/vscode.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('vscode')
    end,
  },
}
