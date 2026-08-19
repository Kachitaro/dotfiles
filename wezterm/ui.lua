local module = {}

function module.setup(config)
  config.tab_bar_at_bottom = true
  config.status_update_interval = 100
  config.use_fancy_tab_bar = false
  -- config.hide_tab_bar_if_only_one_tab = true
  config.scrollback_lines = 10000
  config.adjust_window_size_when_changing_font_size = false
  -- config.color_scheme = 'OneHalfDark'

  config.colors = {
    tab_bar = {
      background = 'rgba(0, 0, 0, 0)',
      active_tab = {
        bg_color = 'rgba(43, 32, 66, 0.8)',
        fg_color = '#c0c0c0',
      },
      inactive_tab = {
        bg_color = 'rgba(0, 0, 0, 0)',
        fg_color = '#808080',
      },
      inactive_tab_hover = {
        bg_color = 'rgba(59, 48, 82, 0.5)',
        fg_color = '#909090',
        italic = true,
      },
      new_tab = {
        bg_color = 'rgba(0, 0, 0, 0)',
        fg_color = '#808080',
      },
      new_tab_hover = {
        bg_color = 'rgba(59, 48, 82, 0.5)',
        fg_color = '#909090',
        italic = true,
      },
    },
  }
end

return module