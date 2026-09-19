-- WezTerm configuration.
-- Linked to ~/.config/wezterm/wezterm.lua by home-manager (see home.nix).
-- Test without switching:  wezterm --config-file ./wezterm.lua start

local wezterm = require 'wezterm'

local act = wezterm.action
local config = wezterm.config_builder()

-- Font. MesloLGS NF is a Nerd Font, which powerlevel10k needs
-- for its glyphs. The fallbacks cover anything it lacks.
config.font = wezterm.font_with_fallback { 'MesloLGS NF', 'JetBrains Mono', 'Menlo' }
config.font_size = 13.0
config.line_height = 1.05

-- Colours, carried over from the iTerm profile.
config.colors = {
  background = '#101216',
  foreground = '#c1c2c3',
  cursor_bg = '#c9d1d9',
  cursor_border = '#c9d1d9',
  cursor_fg = '#101216',
}

config.default_cursor_style = 'SteadyBlock'

-- Window. TITLE keeps the macOS title bar and traffic lights;
-- RESIZE alone removes them.
config.window_padding = { left = 6, right = 6, top = 6, bottom = 4 }
config.window_decorations = 'TITLE | RESIZE'
config.scrollback_lines = 50000
config.audible_bell = 'Disabled'
config.check_for_updates = false

-- Tab bar always visible, so tabs and panes are discoverable
-- rather than appearing only once a second tab exists.
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = true

-- The native-looking tab bar. false gives the retro one drawn
-- in terminal cells, which looks out of place under a real
-- macOS title bar.
config.use_fancy_tab_bar = true
config.tab_max_width = 32
config.window_frame = {
  font = wezterm.font { family = 'MesloLGS NF', weight = 'Regular' },
  font_size = 12.0,
  active_titlebar_bg = '#101216',
  inactive_titlebar_bg = '#101216',
}
config.colors.tab_bar = {
  background = '#101216',
  active_tab = { bg_color = '#1c1f26', fg_color = '#c9d1d9' },
  inactive_tab = { bg_color = '#101216', fg_color = '#6b7280' },
  inactive_tab_hover = { bg_color = '#1c1f26', fg_color = '#c1c2c3' },
  new_tab = { bg_color = '#101216', fg_color = '#6b7280' },
  new_tab_hover = { bg_color = '#1c1f26', fg_color = '#c1c2c3' },
}

-- Native macOS fullscreen, on the standard cmd-ctrl-f chord.
--
-- The trade: a natively fullscreen window gets its own macOS
-- Space and is invisible to AeroSpace until you leave
-- fullscreen. AeroSpace's own `alt-f` fills the screen without
-- that, if a window needs to stay tiled.
config.native_macos_fullscreen_mode = true

-- Left Option sends Alt/Meta so readline word-motions work.
-- Right Option still types special characters.
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

-- Panes. WezTerm's stock split bindings are ctrl+alt+shift+quote
-- and ctrl+alt+shift+5, which nobody discovers. These follow the
-- iTerm convention instead.
--
-- cmd-h and cmd-l are deliberately unused: macOS owns those for
-- Space navigation and would intercept them first.
config.keys = {
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'w', mods = 'CMD', action = act.CloseCurrentPane { confirm = false } },

  { key = '[', mods = 'CMD', action = act.ActivatePaneDirection 'Prev' },
  { key = ']', mods = 'CMD', action = act.ActivatePaneDirection 'Next' },
  { key = 'LeftArrow', mods = 'CMD|ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CMD|ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'CMD|ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'CMD|ALT', action = act.ActivatePaneDirection 'Down' },

  { key = 'z', mods = 'CMD|SHIFT', action = act.TogglePaneZoomState },

  -- Rename the active tab. WezTerm ships no binding for this.
  -- Submitting an empty line clears the override and hands the
  -- title back to automatic naming.
  {
    key = 'e',
    mods = 'CMD|SHIFT',
    action = act.PromptInputLine {
      description = 'New tab title',
      action = wezterm.action_callback(function(window, _, line)
        if line ~= nil then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- Fullscreen on the standard macOS chord. WezTerm's default
  -- is alt+Enter, which is also how some TUIs take a newline,
  -- so that one is handed back to the running program.
  { key = 'f', mods = 'CMD|CTRL', action = act.ToggleFullScreen },
  { key = 'Enter', mods = 'ALT', action = act.DisableDefaultAssignment },
}

return config
