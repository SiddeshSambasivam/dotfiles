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
