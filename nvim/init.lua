-- Neovim entry point.
-- Linked to ~/.config/nvim/init.lua by home-manager (see home.nix).
--
-- Layout:
--   lua/config/   options, keymaps, autocmds
--   lua/plugins/  one file per plugin; lazy.nvim imports them all
--
-- Test without switching:  nvim -u ./nvim/init.lua

-- Leader must be set before lazy.nvim loads, or plugin keymaps bind
-- against the wrong key.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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
  -- lazy-lock.json lands in ~/.config/nvim, which is a real directory.
  -- Only init.lua and lua/ are read-only store symlinks, so the lock
  -- file is writable. Copy it into the repo when you want plugins
  -- pinned across machines.
  change_detection = { notify = false },
  ui = { border = 'rounded' },
})
