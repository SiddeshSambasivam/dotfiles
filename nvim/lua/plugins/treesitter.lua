-- Syntax trees for highlighting.
--
-- The main branch, which is the rewrite for Neovim 0.12. It compiles
-- each parser with the tree-sitter CLI and a C compiler: home.nix
-- installs the CLI and Xcode provides cc. Parsers land in
-- ~/.local/share/nvim/site/parser and install once.
local parsers = {
  'bash', 'css', 'dockerfile', 'go', 'html', 'javascript', 'json', 'lua',
  'markdown', 'markdown_inline', 'nix', 'python', 'rust', 'sql', 'toml',
  'tsx', 'typescript', 'vim', 'vimdoc', 'yaml',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- the plugin does not support lazy loading
    build = ':TSUpdate',
    config = function()
      -- A no-op for parsers already on disk.
      require('nvim-treesitter').install(parsers)

      -- The main branch no longer turns highlighting on by itself.
      -- pcall because a filetype with no parser would otherwise error.
      vim.api.nvim_create_autocmd('FileType', {
        desc = 'Start treesitter highlighting',
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
