-- Neovim configuration.
-- Linked to ~/.config/nvim/init.lua by home-manager (see home.nix).
-- Test without switching:  nvim -u ./nvim/init.lua
--
-- Deliberately no plugin manager. See the note at the bottom.

-- Leader must be set before any mapping that uses it.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ---------------------------------------------------------------- files
vim.opt.undofile = true -- undo history survives closing the file
vim.opt.swapfile = false
vim.opt.backup = false

-- ---------------------------------------------------------------- display
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes' -- always reserved, so text does not jump
vim.opt.cursorline = true
vim.opt.scrolloff = 8 -- keep 8 lines visible above and below the cursor
vim.opt.termguicolors = true
vim.opt.wrap = false

-- ---------------------------------------------------------------- indent
vim.opt.expandtab = true -- spaces, not tabs
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

-- ---------------------------------------------------------------- search
vim.opt.ignorecase = true
vim.opt.smartcase = true -- a capital letter makes the search case-sensitive
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- ---------------------------------------------------------------- windows
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ---------------------------------------------------------------- misc
vim.opt.clipboard = 'unnamedplus' -- y and p use the macOS clipboard
vim.opt.mouse = 'a'
vim.opt.updatetime = 250

-- ---------------------------------------------------------------- keymaps
local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Write' })
map('n', '<leader>q', '<cmd>quit<CR>', { desc = 'Quit' })

-- Window navigation without the <C-w> prefix.
map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

-- Keep the cursor centred when stepping through search results.
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')

-- Move selected lines and keep them selected.
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- ---------------------------------------------------------------- autocmds
-- Briefly highlight whatever was just yanked.
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight on yank',
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- ----------------------------------------------------------------------
-- Adding plugins later:
--
-- nix can install them (programs.neovim.plugins in home.nix), or a
-- plugin manager can. Do not do both.
--
-- If you use lazy.nvim, note that it writes lazy-lock.json into the
-- config directory. Only this one file is a read-only store symlink,
-- so the rest of ~/.config/nvim stays writable and the lock file
-- works. Add it to the repo by hand if you want it pinned.
-- ----------------------------------------------------------------------
