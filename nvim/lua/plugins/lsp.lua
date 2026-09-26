-- Language servers. nvim-lspconfig only ships the per-server configs;
-- Neovim 0.11+ does the rest through vim.lsp.enable.
--
-- The servers themselves are separate programs, installed by home.nix
-- (rust-analyzer comes from rustup instead). A server is enabled only if
-- its binary is on PATH, so a missing one stays silent rather than
-- erroring every time a matching file opens. The binary is spelled out
-- because lspconfig defines some commands, ts_ls among them, as
-- functions rather than lists.
--
-- Neovim's defaults cover the keys: K hover, grn rename, gra code
-- action, grr references, gri implementation, gO document symbols,
-- CTRL-] definition.
local servers = {
  bashls = 'bash-language-server',
  gopls = 'gopls',
  lua_ls = 'lua-language-server',
  nil_ls = 'nil',
  pyright = 'pyright-langserver',
  rust_analyzer = 'rust-analyzer',
  ts_ls = 'typescript-language-server',
}

return {
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    config = function()
      for name, bin in pairs(servers) do
        if vim.fn.executable(bin) == 1 then
          vim.lsp.enable(name)
        end
      end
    end,
  },
}
