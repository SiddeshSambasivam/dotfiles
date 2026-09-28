-- File explorer in a sidebar.
--
-- Folders get an icon and colour by name, the way VS Code's Material icon
-- theme draws them (api, assets, tests, __pycache__ and so on). Folders not
-- listed here keep the plain folder icon. Files keep nvim-web-devicons'
-- icons.
--
-- Icons are Nerd Font Material Design folder glyphs (nf-md-folder_*). The
-- codepoints are from github.com/ryanoasis/nerd-fonts/blob/master/glyphnames.json.
-- (Lua needs these defined above the `return`, so they come first.)

local FOLDER_ICONS = {
  { icon = 0xF0870, color = '#FFA726', names = { 'api', 'apis', 'routes', 'router', 'routers', 'endpoints' } },
  { icon = 0xF024F, color = '#FFCA28', names = { 'assets', 'images', 'img', 'static', 'public', 'media', 'icons' } },
  { icon = 0xF178A, color = '#EF5350', names = { 'views', 'templates', 'pages', 'screens', 'layouts' } },
  { icon = 0xF12E3, color = '#E57373', names = { 'schemas', 'models', 'types', 'entities', 'db', 'database', 'migrations' } },
  { icon = 0xF197E, color = '#66BB6A', names = { 'test', 'tests', '__tests__', 'spec', 'specs', 'e2e', 'fixtures' } },
  { icon = 0xF0C82, color = '#42A5F5', names = { 'docs', 'doc', 'documentation', 'notes' } },
  { icon = 0xF107F, color = '#90A4AE', names = { 'config', 'configs', 'settings', '.vscode', '.idea' } },
  { icon = 0xF19FC, color = '#26A69A', names = { 'utils', 'util', 'helpers', 'lib', 'libs', 'scripts', 'bin', 'tools' } },
  { icon = 0xF08AC, color = '#FDD835', names = { 'auth', 'security', 'permissions' } },
  { icon = 0xF024C, color = '#AB47BC', names = { 'admin', 'users', 'user', 'accounts' } },
  { icon = 0xF0D0B, color = '#7E57C2', names = { 'tasks', 'jobs', 'workers', 'queues', 'celery' } },
  { icon = 0xF0253, color = '#5C6BC0', names = { 'components', 'services', 'adapters', 'modules', 'packages' } },
  { icon = 0xF179E, color = '#5A5A5A', names = { '__pycache__', '.venv', 'venv', 'node_modules', 'dist', 'build', '.git',
    '.mypy_cache', '.pytest_cache', '.ruff_cache', '.cache', '.next', 'coverage', '.direnv' } },
}

-- neo-tree's italic groups, with the same colours minus the italics.
local UPRIGHT_HIGHLIGHTS = {
  NeoTreeRootName = { bold = true },
  NeoTreeFileStatsHeader = { bold = true },
  NeoTreeMessage = { fg = '#6e6e6e' },
  NeoTreeGitConflict = { fg = '#ff8700', bold = true },
  NeoTreeGitUntracked = { fg = '#ff8700' },
}

-- Plain folders use Material's own folder glyphs in its grey, so they
-- match the named ones instead of mixing two icon sets.
local PLAIN_FOLDER = { closed = 0xF024B, open = 0xF0770, empty = 0xF0256, color = '#90A4AE' }

-- name -> { text, highlight }, and one highlight group per colour.
local function build_folder_lookup()
  vim.api.nvim_set_hl(0, 'NeoTreeDirectoryIcon', { fg = PLAIN_FOLDER.color })
  local lookup = {}
  for index, group in ipairs(FOLDER_ICONS) do
    local highlight = 'NeoTreeFolderIcon' .. index
    vim.api.nvim_set_hl(0, highlight, { fg = group.color })
    for _, name in ipairs(group.names) do
      lookup[name] = { text = vim.fn.nr2char(group.icon), highlight = highlight }
    end
  end
  return lookup
end

-- neo-tree calls this for every row. Folders look themselves up by name.
-- Files take nvim-web-devicons' icon, which is what neo-tree does by default.
local function pick_icon(icon, node, lookup)
  if node.type == 'directory' then
    local match = lookup[node.name:lower()]
    if match then
      icon.text, icon.highlight = match.text, match.highlight
    end
  elseif node.type == 'file' then
    local ok, devicons = pcall(require, 'nvim-web-devicons')
    if ok then
      local text, highlight = devicons.get_icon(node.name)
      icon.text, icon.highlight = text or icon.text, highlight or icon.highlight
    end
  end
end

return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    lazy = false, -- neo-tree defers its own loading
    keys = {
      { '<D-b>', '<cmd>Neotree toggle<CR>', desc = 'File explorer' }, -- VS Code's sidebar toggle
    },
    config = function()
      -- neo-tree draws these in italics. It only fills in groups that are not
      -- already defined, so defining them upright first keeps them that way.
      for name, hl in pairs(UPRIGHT_HIGHLIGHTS) do
        vim.api.nvim_set_hl(0, name, hl)
      end
      local lookup = build_folder_lookup()
      require('neo-tree').setup({
        default_component_configs = {
          icon = {
            folder_closed = vim.fn.nr2char(PLAIN_FOLDER.closed),
            folder_open = vim.fn.nr2char(PLAIN_FOLDER.open),
            folder_empty = vim.fn.nr2char(PLAIN_FOLDER.empty),
            folder_empty_open = vim.fn.nr2char(PLAIN_FOLDER.empty),
            provider = function(icon, node)
              pick_icon(icon, node, lookup)
            end,
          },
          -- Names stay the normal text colour. Git status still shows as
          -- the coloured marker at the right edge (? untracked, and so on).
          name = { use_git_status_colors = false },
        },
      })
    end,
  },
}
