-- Open buffers as tabs along the top. Step through them with the built-in
-- [b and ]b, which Neovim 0.11 maps to :bprevious and :bnext.
return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        -- Start the tabs beside the file tree, not above it.
        offsets = {
          { filetype = 'neo-tree', text = 'Explorer', highlight = 'Directory', separator = true },
        },
      },
    },
  },
}
