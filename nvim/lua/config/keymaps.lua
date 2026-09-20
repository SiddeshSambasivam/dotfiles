-- Keymaps that do not belong to a plugin. Plugin keymaps live in that
-- plugin's own file under lua/plugins/.

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

-- Move the selection and keep it selected.
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
