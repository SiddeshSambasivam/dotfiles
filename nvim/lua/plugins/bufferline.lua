-- Open buffers as tabs along the top. Cmd-Shift-[ and Cmd-Shift-] step
-- through them in the order shown, as in VS Code. WezTerm passes those
-- chords through only while nvim is in front (see wezterm.lua).
return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false, -- keys below would otherwise defer loading, and the tab bar with it
    keys = {
      { '<D-S-[>', '<cmd>BufferLineCyclePrev<CR>', mode = { 'n', 'i', 'v' }, desc = 'Previous tab' },
      { '<D-S-]>', '<cmd>BufferLineCycleNext<CR>', mode = { 'n', 'i', 'v' }, desc = 'Next tab' },
    },
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
