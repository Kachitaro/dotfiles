local wezterm = require 'wezterm'
local act = wezterm.action

return {
  -- Window
  window_decorations = "NONE",
  adjust_window_size_when_changing_font_size = false,
  color_scheme = 'BlulocoDark',


  window_padding = {
    left = 8,
    right = 8,
    top = 6,
    bottom = 6,
  },

  -- Font
  font = wezterm.font('JetBrainsMono Nerd Font Mono', {
    weight = 'Regular',
    style  = 'Normal',
  }),
  font_size = 9.0,
  
  font_rules = {
    {
      italic = true,
      font = wezterm.font {
        family = "JetBrainsMono Nerd Font Mono",
        weight = "Regular",
        italic = true,
      },
    },
    {
      intensity = "Bold",
      font = wezterm.font {
        family = "JetBrainsMono Nerd Font Mono",
        weight = "Bold",
      },
    },
  },


  -- Scrollback
  scrollback_lines = 10000,

  -- Selection → copy to clipboard
  selection_word_boundary = " \t\n{}[]()\"'`,;:",

  -- Cursor
  default_cursor_style = "BlinkingBar",

  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,

  keys = {
    {
      key = '|',
      mods = 'CTRL|SHIFT',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
     key = 'd',
      mods = 'CTRL|SHIFT',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    }
  },

  -- Live reload
  automatically_reload_config = true,
}
