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

-- Tab accepts a ghost-text suggestion when one is showing, and otherwise
-- indents as usual.
map('i', '<Tab>', function()
  local ok, ghost = pcall(require, 'minuet.virtualtext')
  if ok and ghost.action.is_visible() then
    ghost.action.accept()
  else
    vim.api.nvim_feedkeys(vim.keycode('<Tab>'), 'n', false)
  end
end, { desc = 'Accept suggestion or indent' })

-- Shift-Tab takes the line back one indent level, as in VS Code. Tab already
-- indents: expandtab and softtabstop make it insert four spaces.
map('i', '<S-Tab>', '<C-d>', { desc = 'Outdent line' })

-- Option-Backspace deletes the word before the cursor, as in other macOS
-- editors. Only the left Option key: WezTerm sends it as Alt, while the
-- right one still types special characters.
map('i', '<M-BS>', '<C-w>', { desc = 'Delete previous word' })

-- Cmd-/ toggles a line comment in the file's language (# in Python), as in
-- VS Code. It runs Neovim's built-in gcc, which reads 'commentstring', and
-- keeps the cursor on the same character.
--
-- Plain text, JSON and files with no known type have no comment syntax, so
-- gcc would refuse. Fall back the way VS Code does: // for JSON, # otherwise.
local function ensure_commentstring()
  if vim.bo.commentstring == '' then
    vim.bo.commentstring = vim.bo.filetype == 'json' and '// %s' or '# %s'
  end
end

local function toggle_comment()
  ensure_commentstring()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local before = #vim.api.nvim_get_current_line()
  vim.cmd.normal('gcc')
  local shift = #vim.api.nvim_get_current_line() - before
  vim.api.nvim_win_set_cursor(0, { row, math.max(0, col + shift) })
end
map({ 'n', 'i' }, '<D-/>', toggle_comment, { desc = 'Toggle comment' })
map('x', '<D-/>', function()
  ensure_commentstring()
  return 'gc'
end, { expr = true, remap = true, desc = 'Toggle comment' })

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
