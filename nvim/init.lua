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

-- lazy-lock.json lives next to this file in the repo, so the plugin
-- commits are versioned and every machine gets the same ones.
-- resolve() follows the home-manager symlinks back to the repo.
local lockfile = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.stdpath('config') .. '/init.lua'), ':h') .. '/lazy-lock.json'

-- ---------------------------------------------------------------------
-- Bootstrap lazy.nvim. It installs itself to ~/.local/share/nvim on
-- first launch, which needs git and a network connection once. It then
-- checks out the commit in lazy-lock.json, since `Lazy restore` pins
-- every plugin except lazy.nvim itself.
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
  local locked = vim.json.decode(table.concat(vim.fn.readfile(lockfile), '\n'))['lazy.nvim']
  if locked then vim.fn.system({ 'git', '-C', lazypath, 'checkout', '--quiet', locked.commit }) end
end
vim.opt.rtp:prepend(lazypath)

require('config.options')
require('config.keymaps')
require('config.autocmds')

require('lazy').setup({
  spec = { { import = 'plugins' } },
  lockfile = lockfile,
  change_detection = { notify = false },
  ui = { border = 'rounded' },
})
