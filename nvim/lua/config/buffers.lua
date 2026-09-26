-- Close the current buffer the way Cmd-w closes a VS Code tab, and bring
-- closed ones back with Cmd-Shift-w, most recent first.

local M = {}

-- Closed files, newest last, with the cursor where you left it.
local closed = {}

-- A window showing a real file, not the tree, a terminal or help.
local function main_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == '' then return win end
  end
end

function M.close()
  local buf = vim.api.nvim_get_current_buf()

  -- The tree and terminals are panels, not tabs: close the panel.
  if vim.bo[buf].filetype == 'neo-tree' then return vim.cmd('Neotree close') end
  if vim.bo[buf].buftype == 'terminal' then return vim.cmd('bdelete!') end
  if vim.bo[buf].buftype ~= '' then return vim.cmd('close') end

  if vim.bo[buf].modified then
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
    local choice = vim.fn.confirm(
      ('Save changes to %s?'):format(name ~= '' and name or 'this buffer'),
      '&Save\n&Discard\n&Cancel', 1)
    if choice == 1 then vim.cmd.write() elseif choice ~= 2 then return end
  end

  local path = vim.api.nvim_buf_get_name(buf)
  if path ~= '' then
    table.insert(closed, { path = path, cursor = vim.api.nvim_win_get_cursor(0) })
  end

  -- Put another buffer in this window first. Deleting the buffer directly
  -- would close the window too and collapse the layout into the tree.
  vim.cmd('bprevious')
  if vim.api.nvim_get_current_buf() == buf then vim.cmd('enew') end
  vim.cmd('bdelete! ' .. buf)
end

function M.reopen()
  local last = table.remove(closed)
  if not last then return vim.notify('No closed tab to reopen') end
  local win = main_window()
  if win then vim.api.nvim_set_current_win(win) end
  vim.cmd.edit(vim.fn.fnameescape(last.path))
  pcall(vim.api.nvim_win_set_cursor, 0, last.cursor)
end

return M
