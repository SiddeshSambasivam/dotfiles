-- Open buffers as tabs along the top. Step through them with the built-in
-- [b and ]b, which Neovim 0.11 maps to :bprevious and :bnext.
return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
}
