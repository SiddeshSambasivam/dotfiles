-- Ghost-text code suggestions from a local model, like Copilot. minuet asks
-- Ollama's fill-in-the-middle endpoint for the code between the text before
-- and after the cursor. It needs a model that supports that, which chat
-- models such as qwen3.5 do not.
--
-- Pull the model once:  ollama pull qwen2.5-coder:14b
--
-- Tab accepts a suggestion when one is showing (see keymaps.lua).
local model = 'qwen2.5-coder:14b'

return {
  {
    'milanglacier/minuet-ai.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    -- Loaded at startup: it turns suggestions on per buffer when the
    -- filetype is set, which happens before the first InsertEnter.
    lazy = false,
    -- Until the model is pulled, every request fails and minuet stops you at
    -- a "Press ENTER" error each time. Check once at startup instead, and
    -- keep suggestions off with a one-line hint when the model is missing.
    config = function(_, opts)
      local tags = vim.system({ 'curl', '-s', '--max-time', '1', 'http://localhost:11434/api/tags' }, { text = true }):wait()
      local ok, list = pcall(vim.json.decode, tags.stdout or '')
      local names = ok and type(list) == 'table' and vim.tbl_map(function(m) return m.name end, list.models or {}) or {}
      if not vim.tbl_contains(names, model) then
        opts.virtualtext.auto_trigger_ft = {}
        -- Deferred, so it cannot stack with other startup messages into a
        -- "Press ENTER" prompt.
        vim.schedule(function()
          vim.notify(('Ghost text off: Ollama is not serving %s. Run: ollama pull %s'):format(model, model), vim.log.levels.WARN)
        end)
      end
      require('minuet').setup(opts)
    end,
    opts = {
      provider = 'openai_fim_compatible',
      n_completions = 1, -- one suggestion at a time keeps a local model responsive
      context_window = 512, -- characters of surrounding code sent with each request
      provider_options = {
        openai_fim_compatible = {
          -- Ollama needs no key, but minuet requires the name of some set
          -- environment variable here.
          api_key = 'TERM',
          name = 'Ollama',
          end_point = 'http://localhost:11434/v1/completions',
          model = model,
          optional = { max_tokens = 56, top_p = 0.9 },
        },
      },
      virtualtext = {
        auto_trigger_ft = { '*' },
        -- Prompts and panels, not files: no suggestions there.
        auto_trigger_ignore_ft = { 'TelescopePrompt', 'spectre_panel', 'neo-tree', 'neo-tree-popup' },
      },
    },
  },
}
