-- Briefly highlight whatever was just yanked.
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight on yank',
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- A terminal needs no line numbers or sign column, and should be ready to
-- type into as soon as it opens.
vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Terminal buffer setup',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
    vim.cmd.startinsert()
  end,
})

-- Drop the empty buffer nvim starts with once a real file is showing, so it
-- does not linger as a [No Name] tab. Plugins like neo-tree open files in a
-- way that skips nvim's usual reuse of that buffer. Only a buffer that is
-- unnamed, unchanged, empty and off screen goes.
vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Remove the leftover empty buffer',
  callback = function(args)
    if vim.bo[args.buf].buftype ~= '' or vim.api.nvim_buf_get_name(args.buf) == '' then return end
    vim.schedule(function()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[b].buflisted and vim.bo[b].buftype == '' and not vim.bo[b].modified
          and vim.api.nvim_buf_get_name(b) == ''
          and vim.api.nvim_buf_line_count(b) == 1 and vim.api.nvim_buf_get_lines(b, 0, 1, false)[1] == ''
          and #vim.fn.win_findbuf(b) == 0 then
          vim.api.nvim_buf_delete(b, {})
        end
      end
    end)
  end,
})
