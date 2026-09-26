-- Neovim entry point.
-- home-manager links ~/.config/nvim/init.lua and lua/ straight to this
-- directory, outside the nix store (see home.nix). Edits here take
-- effect the next time nvim starts, with no switch.
--
-- Layout:
--   lua/config/   options, keymaps, autocmds
--   lua/plugins/  one file per plugin; lazy.nvim imports them all
--
-- Test without switching:  nvim -u ./nvim/init.lua

-- ---------------------------------------------------------------------
-- Bootstrap lazy.nvim. It installs itself to ~/.local/share/nvim on
-- first launch, which needs git and a network connection once.
-- ---------------------------------------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require('config.options')
require('config.keymaps')
require('config.autocmds')

require('lazy').setup({
  spec = { { import = 'plugins' } },
  -- Keep lazy-lock.json next to this file in the repo, so the plugin
  -- commits are versioned and every machine gets the same ones.
  -- resolve() follows the home-manager symlinks back to the repo.
  lockfile = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.stdpath('config') .. '/init.lua'), ':h') .. '/lazy-lock.json',
  change_detection = { notify = false },
  ui = { border = 'rounded' },
})
