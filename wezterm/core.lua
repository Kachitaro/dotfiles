local wezterm = require 'wezterm'
local act = wezterm.action
local module = {}

function module.setup(config)
  local is_windows = wezterm.target_triple:find("windows") ~= nil

  if is_windows then
    local raw_home = wezterm.home_dir or os.getenv("USERPROFILE") or ""
    local home = (raw_home:gsub("\\", "/"))
    local ps_dir = home .. "/.config/powershell"
    local ps_profile = (ps_dir .. "/user_profile.ps1"):gsub("/", "\\")

    -- Kiểm tra nếu file profile chưa tồn tại thì tự động tạo
    local f = io.open(ps_profile, "r")
    if f then
      f:close()
    else
      local dotfiles_dir = os.getenv("DOTFILES_DIR") or (wezterm.config_dir and (wezterm.config_dir .. "/..")) or nil
      local source_profile = dotfiles_dir and ((dotfiles_dir:gsub("\\", "/") .. "/powershell/user_profile.ps1"):gsub("/", "\\")) or nil

      os.execute('mkdir "' .. (ps_dir:gsub("/", "\\")) .. '" 2>nul')

      local src_f = source_profile and io.open(source_profile, "r") or nil
      local content = "# PowerShell User Profile\n"
      if src_f then
        content = src_f:read("*a")
        src_f:close()
      end

      local new_f = io.open(ps_profile, "w")
      if new_f then
        new_f:write(content)
        new_f:close()
      end
    end

    config.default_prog = {
      'pwsh.exe',
      '-NoExit',
      '-File',
      ps_profile,
    }
  end

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