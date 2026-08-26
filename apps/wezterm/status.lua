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

-- ==========================================
-- BIẾN CACHE ĐỂ TỐI ƯU HIỆU NĂNG
-- ==========================================
local last_ram_check_time = 0
local cached_ram_usage = nil
local UPDATE_INTERVAL = 5 -- Thời gian giãn cách giữa mỗi lần check RAM (5 giây)

local is_windows = wezterm.target_triple:find("windows") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil

local function get_ram_usage()
  if is_windows then
    local success, stdout = wezterm.run_child_process({
      'cmd.exe', '/c', 'wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value'
    })
    if success and stdout then
      local free = stdout:match("FreePhysicalMemory=(%d+)")
      local total = stdout:match("TotalVisibleMemorySize=(%d+)")
      if free and total then
        local used = tonumber(total) - tonumber(free)
        return tostring(math.floor((used / tonumber(total)) * 100 + 0.5))
      end
    end
  elseif is_linux then
    local file = io.open("/proc/meminfo", "r")
    if file then
      local mem_total, mem_available
      for line in file:lines() do
        local total = line:match("MemTotal:%s+(%d+)")
        if total then mem_total = tonumber(total) end
        local avail = line:match("MemAvailable:%s+(%d+)")
        if avail then mem_available = tonumber(avail) end
        if mem_total and mem_available then break end
      end
      file:close()
      if mem_total and mem_available and mem_total > 0 then
        local used = mem_total - mem_available
        return tostring(math.floor((used / mem_total) * 100 + 0.5))
      end
    end
  end
  return nil
end

function module.setup()
  wezterm.on('update-status', function(window, pane)
    local current_time = os.time()

    if current_time - last_ram_check_time >= UPDATE_INTERVAL then
      cached_ram_usage = get_ram_usage()
      last_ram_check_time = current_time
    end

    local display = cached_ram_usage and (cached_ram_usage .. '%') or 'N/A'
    local color   = ram_color(cached_ram_usage)
    local icon    = ram_icon(cached_ram_usage)

    window:set_right_status(wezterm.format({
      { Foreground = { Color = color } },
      { Text = ' RAM: ' .. display .. icon .. ' ' },
    }))
  end)

  -- ==========================================
  -- ĐỊNH DẠNG TÊN TAB
  -- ==========================================
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = tab.active_pane.foreground_process_name or "Tab"
    title = string.gsub(title, "(.*[/\\])", "")
    return {
      { Text = " " .. title .. " " },
    }
  end)
end

return module