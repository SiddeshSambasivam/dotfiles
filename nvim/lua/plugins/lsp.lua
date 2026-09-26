-- Language servers. nvim-lspconfig only ships the per-server configs;
-- Neovim 0.11+ does the rest through vim.lsp.enable.
--
-- The servers themselves are separate programs. A server is enabled
-- only if its binary is on PATH, so a missing one stays silent rather
-- than erroring every time a matching file opens.
--
-- Neovim's defaults cover the keys: K hover, grn rename, gra code
-- action, grr references, gri implementation, gO document symbols,
-- CTRL-] definition.
local servers = {
  'bashls',        -- bash-language-server
  'gopls',
  'lua_ls',        -- lua-language-server
  'nil_ls',        -- nil, for Nix
  'pyright',
  'rust_analyzer',
  'ts_ls',         -- typescript-language-server
}

return {
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    config = function()
      for _, name in ipairs(servers) do
        local cmd = vim.lsp.config[name] and vim.lsp.config[name].cmd
        if type(cmd) == 'table' and vim.fn.executable(cmd[1]) == 1 then
          vim.lsp.enable(name)
        end
      end
    end,
  },
}
