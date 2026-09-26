-- Keymaps that do not belong to a plugin. Plugin keymaps live in that
-- plugin's own file under lua/plugins/.
--
-- No leader key. Editor commands sit on Cmd, the way VS Code has them.
-- <D-...> is Cmd: WezTerm passes it through over the kitty keyboard
-- protocol (enable_kitty_keyboard in wezterm.lua), but only for chords
-- WezTerm does not bind itself. `wezterm show-keys` lists those.

local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
map({ 'n', 'i', 'v' }, '<D-s>', '<cmd>write<CR>', { desc = 'Save' })

-- Cmd-w reaches nvim only because wezterm.lua passes it through when nvim
-- is in front; anywhere else it still closes the WezTerm pane.
local buffers = require('config.buffers')
map({ 'n', 'i', 'v' }, '<D-w>', buffers.close, { desc = 'Close tab' })
map({ 'n', 'i', 'v' }, '<D-S-w>', buffers.reopen, { desc = 'Reopen closed tab' })

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

-- Terminal in a split along the bottom, on VS Code's Ctrl-`. Leave
-- terminal mode with Esc twice: a single Esc still reaches programs
-- running inside it, like fzf and lazygit, which use it to cancel.
map('n', '<C-`>', '<cmd>botright split | resize 15 | terminal<CR>', { desc = 'Terminal' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Leave terminal mode' })
