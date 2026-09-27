-- Sort Python imports with isort, which reads the project's own settings
-- from pyproject.toml.
--
-- It runs just after the save rather than during it, so :write returns at
-- once. isort takes around 100 ms to start, and waiting on it made every
-- save feel slow. conform writes the file again once the imports are sorted,
-- and skips it if you have typed in the meantime.
return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    opts = {
      formatters_by_ft = { python = { 'isort' } },
      format_after_save = { lsp_format = 'never' },
    },
  },
}