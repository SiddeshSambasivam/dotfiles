-- Format on save. Python runs isort, which sorts and groups the imports and
-- reads the project's own settings from pyproject.toml.
return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    opts = {
      formatters_by_ft = { python = { 'isort' } },
      format_on_save = { timeout_ms = 2000, lsp_format = 'never' },
    },
  },
}
