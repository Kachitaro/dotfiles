local wezterm = require 'wezterm'
local act = wezterm.action
local module = {}

function module.setup(config)
  config.default_prog = { 'pwsh' }
  config.font = wezterm.font('JetBrainsMono Nerd Font Mono', {
    weight = 'Regular',
    style  = 'Normal',
  })
  config.font_size = 10.5
  config.font_rules = {
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
  }

  config.window_decorations = "RESIZE"
  config.window_background_opacity = 0.75 
  config.default_cursor_style = 'BlinkingBar'
  config.automatically_reload_config = true

  config.keys = {
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
  }
end

return module