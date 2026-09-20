return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- Pinned to master on purpose. The default branch is now `main`,
    -- a rewrite that drops the nvim-treesitter.configs module this
    -- setup uses. Moving to main means a different API, not just a
    -- version bump.
    branch = 'master',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      ensure_installed = { 'lua', 'nix', 'python', 'go', 'rust', 'bash', 'json', 'yaml', 'markdown' },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}
