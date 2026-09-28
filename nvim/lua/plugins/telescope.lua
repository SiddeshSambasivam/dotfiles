-- Fuzzy finder. live_grep shells out to ripgrep, which home.nix installs.
return {
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = 'Telescope',
    opts = {
      pickers = {
        -- The problems list: the whole message, wrapped, with the list
        -- across the full width. By default the message gets half the
        -- width and is cut off.
        diagnostics = { line_width = 'full', wrap_results = true, layout_strategy = 'vertical' },
      },
    },
    keys = {
      -- Cmd-p and Cmd-Shift-f are VS Code's quick open and search.
      { '<D-p>', '<cmd>Telescope find_files<CR>', desc = 'Find files' },
      { '<D-S-f>', '<cmd>Telescope live_grep<CR>', desc = 'Grep' },
      { '<D-e>', '<cmd>Telescope buffers<CR>', desc = 'Open buffers' },
      -- VS Code's Problems panel: every diagnostic in the open files.
      { '<D-S-m>', '<cmd>Telescope diagnostics<CR>', desc = 'Problems' },
    },
  },
}
