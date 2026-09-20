-- Briefly highlight whatever was just yanked.
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight on yank',
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})
