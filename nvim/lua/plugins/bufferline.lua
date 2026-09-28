-- Open buffers as tabs along the top, styled after VS Code's Dark Modern tab
-- bar: grey names on inactive tabs, a white name on the active one, no
-- italics and no coloured bar. A file with errors gets a red name and its
-- error count, and the close button shows only on the active tab.
--
-- Cmd-Shift-[ and Cmd-Shift-] step through the tabs in the order shown.
-- WezTerm passes those chords through only while nvim is in front (see
-- wezterm.lua).

-- VS Code Dark Modern's tab colours.
local ACTIVE_BG, INACTIVE_BG = '#1f1f1f', '#181818'
local ACTIVE_FG, INACTIVE_FG, PATH_FG = '#ffffff', '#9d9d9d', '#6e6e6e'
local BORDER, ERROR, WARNING = '#2b2b2b', '#f14c4c', '#cca700'

-- One entry per bufferline group: inactive tabs, the active tab, and a tab
-- shown in another window (visible), which VS Code draws like inactive.
local function tab_highlights()
  local hl = { fill = { bg = INACTIVE_BG } }
  local function group(name, inactive_fg, active_fg)
    hl[name] = { fg = inactive_fg, bg = INACTIVE_BG }
    hl[name .. '_visible'] = { fg = inactive_fg, bg = INACTIVE_BG }
    hl[name .. '_selected'] = { fg = active_fg, bg = ACTIVE_BG }
  end
  hl.background = { fg = INACTIVE_FG, bg = INACTIVE_BG }
  hl.buffer_visible = { fg = INACTIVE_FG, bg = INACTIVE_BG }
  hl.buffer_selected = { fg = ACTIVE_FG, bg = ACTIVE_BG }
  group('modified', INACTIVE_FG, ACTIVE_FG)
  group('duplicate', PATH_FG, INACTIVE_FG)
  -- The close button is drawn in the tab's own background colour, so only
  -- the active tab shows it.
  group('close_button', INACTIVE_BG, ACTIVE_FG)
  group('separator', BORDER, BORDER)
  group('error', ERROR, ERROR)
  group('error_diagnostic', ERROR, ERROR)
  group('warning', WARNING, WARNING)
  group('warning_diagnostic', WARNING, WARNING)
  return hl
end

return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false, -- keys below would otherwise defer loading, and the tab bar with it
    keys = {
      { '<D-S-[>', '<cmd>BufferLineCyclePrev<CR>', mode = { 'n', 'i', 'v' }, desc = 'Previous tab' },
      { '<D-S-]>', '<cmd>BufferLineCycleNext<CR>', mode = { 'n', 'i', 'v' }, desc = 'Next tab' },
    },
    config = function()
      local bufferline = require('bufferline')
      bufferline.setup({
        options = {
          style_preset = bufferline.style_preset.no_italic,
          -- Apply the colours below over the theme's. vscode.nvim sets its
          -- own tab-bar background, which would otherwise win.
          themable = false,
          indicator = { style = 'none' },
          show_close_icon = false,
          modified_icon = '●',
          diagnostics = 'nvim_lsp',
          diagnostics_indicator = function(count) return tostring(count) end,
          -- Start the tabs beside the file tree, not above it.
          offsets = {
            { filetype = 'neo-tree', text = 'Explorer', highlight = 'Directory', separator = true },
          },
        },
        highlights = tab_highlights(),
      })
    end,
  },
}
