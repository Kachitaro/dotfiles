local wezterm = require 'wezterm'
local module = {}

local function ram_color(usage)
  local pct = tonumber(usage)
  if not pct then return '#888888' end
  if pct >= 90 then return '#ff5555' end
  if pct >= 80 then return '#ffb86c' end
  if pct >= 60 then return '#f1fa8c' end
  return '#50fa7b'
end

local function ram_icon(usage)
  local pct = tonumber(usage)
  if not pct then return '' end
  if pct >= 90 then return ' !!' end
  if pct >= 80 then return ' !' end
  return ''
end

function module.setup()
  wezterm.on('update-status', function(window, pane)
    local ram_usage = nil

    local success, stdout = wezterm.run_child_process({
      'powershell.exe', '-NoProfile', '-Command',
      "(Get-CimInstance Win32_OperatingSystem | ForEach-Object { [Math]::Round((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) / $_.TotalVisibleMemorySize) * 100) })"
    })

    if success then
      ram_usage = stdout:gsub("%s+", "")
    end

    local display = ram_usage and (ram_usage .. '%') or 'N/A'
    local color   = ram_color(ram_usage)
    local icon    = ram_icon(ram_usage)

    window:set_right_status(wezterm.format({
      { Foreground = { Color = color } },
      { Text = ' RAM: ' .. display .. icon .. ' ' },
    }))
  end)
end

return module
