-- File-type icons, used by the tree, the tabs and the status line.
--
-- devicons draws a few file types with glyphs newer than the Nerd Font that
-- WezTerm takes icons from, so they came out blank. Point those at older
-- glyphs the font has, in the same colours.
return {
  {
    'nvim-tree/nvim-web-devicons',
    opts = {
      override_by_extension = {
        yaml = { icon = vim.fn.nr2char(0xE6A8), color = '#D70000', name = 'Yaml' },
        yml = { icon = vim.fn.nr2char(0xE6A8), color = '#D70000', name = 'Yml' },
        css = { icon = vim.fn.nr2char(0xE749), color = '#663399', name = 'Css' },
      },
    },
  },
}
