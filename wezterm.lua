-- WezTerm configuration.
-- Linked to ~/.config/wezterm/wezterm.lua by home-manager (see home.nix).
-- Test without switching:  wezterm --config-file ./wezterm.lua start

local wezterm = require 'wezterm'

local act = wezterm.action
local config = wezterm.config_builder()

-- Font. Menlo, the same as the Cursor editor. It has no icon glyphs, so
-- MesloLGS NF (a Nerd Font) comes next and supplies the icons nvim and
-- powerlevel10k draw.
config.font = wezterm.font_with_fallback { 'Menlo', 'MesloLGS NF', 'JetBrains Mono' }
config.font_size = 14.0
config.line_height = 1.05
-- WezTerm draws text with FreeType, which comes out thinner than macOS's
-- own text engine. Light hinting keeps letter shapes closer to their design,
-- the way macOS draws them.
config.freetype_load_target = 'Light'
-- Subpixel smoothing: edges use the red, green and blue parts of each pixel
-- separately, which draws thicker, sharper strokes than grayscale smoothing.
config.freetype_render_target = 'HorizontalLcd'

-- Colours, carried over from the iTerm profile.
config.colors = {
  background = '#101216',
  foreground = '#c1c2c3',
  cursor_bg = '#c9d1d9',
  cursor_border = '#c9d1d9',
  cursor_fg = '#101216',
}

-- Blinking block that switches on and off with no fade. cursor_blink_rate
-- is how long each phase lasts, in ms (default 800).
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 700
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- Report keys with the kitty keyboard protocol to programs that ask
-- for it. This is how nvim sees Cmd (<D-...>) and Ctrl-`; the shell
-- does not ask, so it is unaffected.
config.enable_kitty_keyboard = true

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
-- Space. Rectangle's maximize fills the screen without that, if
-- the window needs to stay on the current Space.
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
-- For chords nvim uses that WezTerm also binds: when nvim is the foreground
-- program, write the chord's kitty keyboard sequence straight to it, and
-- otherwise run the WezTerm action. SendKey cannot do this, because it
-- encodes with termwiz's xterm encoder, which drops Cmd entirely.
-- The shifted bracket is bound three ways ({ with and without SHIFT, and
-- [ with SHIFT) because macOS can report the same press as any of them.
local function nvim_or(sequence, fallback)
  return wezterm.action_callback(function(window, pane)
    local proc = pane:get_foreground_process_name() or ''
    if proc:match('n?vim$') then
      window:perform_action(act.SendString(sequence), pane)
    else
      window:perform_action(fallback, pane)
    end
  end)
end

-- Kitty keyboard sequences: ESC [ <key code> ; <1 + modifier bits> u,
-- with Shift 1 and Cmd 8. nvim reads these as <D-w>, <S-D-[> and <S-D-]>.
local CMD_W = '\x1b[119;9u'
local CMD_SHIFT_LBRACKET = '\x1b[91;10u'
local CMD_SHIFT_RBRACKET = '\x1b[93;10u'

config.keys = {
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  -- Cmd-w closes the nvim tab, and Cmd-Shift-[ / ] step through nvim tabs,
  -- when nvim is in front. Anywhere else they keep their WezTerm meaning.
  { key = 'w', mods = 'CMD', action = nvim_or(CMD_W, act.CloseCurrentPane { confirm = false }) },
  { key = '[', mods = 'CMD|SHIFT', action = nvim_or(CMD_SHIFT_LBRACKET, act.ActivateTabRelative(-1)) },
  { key = '{', mods = 'CMD', action = nvim_or(CMD_SHIFT_LBRACKET, act.ActivateTabRelative(-1)) },
  { key = '{', mods = 'CMD|SHIFT', action = nvim_or(CMD_SHIFT_LBRACKET, act.ActivateTabRelative(-1)) },
  { key = ']', mods = 'CMD|SHIFT', action = nvim_or(CMD_SHIFT_RBRACKET, act.ActivateTabRelative(1)) },
  { key = '}', mods = 'CMD', action = nvim_or(CMD_SHIFT_RBRACKET, act.ActivateTabRelative(1)) },
  { key = '}', mods = 'CMD|SHIFT', action = nvim_or(CMD_SHIFT_RBRACKET, act.ActivateTabRelative(1)) },

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

-- Cmd-Shift-letter chords nvim uses: Cmd-Shift-f grep, Cmd-Shift-r search
-- and replace, Cmd-Shift-m problems, Cmd-Shift-w reopen tab. WezTerm binds
-- the plain Cmd-letter for each (search, reload, hide, close), so these are
-- bound explicitly and handed to nvim as kitty sequences. Both spellings of
-- the letter are bound, since macOS may report the shifted key either way.
-- Outside nvim they do nothing.
for _, chord in ipairs({ { 'f', 102 }, { 'r', 114 }, { 'm', 109 }, { 'w', 119 } }) do
  local letter, code = chord[1], chord[2]
  local action = nvim_or(string.format('\x1b[%d;10u', code), act.Nop)
  table.insert(config.keys, { key = letter, mods = 'CMD|SHIFT', action = action })
  table.insert(config.keys, { key = letter:upper(), mods = 'CMD', action = action })
end

return config
