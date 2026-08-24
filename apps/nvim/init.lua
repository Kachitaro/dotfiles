vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Apply dynamically generated custom theme overrides
local function get_theme_path()
  local uv = vim.uv or vim.loop

  -- 0. Try dynamic path resolution via `dot theme path` (or `k-dot theme path`)
  local out = vim.fn.system { "dot", "theme", "path" }
  if vim.v.shell_error == 0 and out and out ~= "" then
    local trimmed = vim.trim(out)
    local candidate = trimmed .. "/theme.lua"
    if uv.fs_stat(candidate) then
      return candidate
    end
  end

  local k_out = vim.fn.system { "k-dot", "theme", "path" }
  if vim.v.shell_error == 0 and k_out and k_out ~= "" then
    local trimmed = vim.trim(k_out)
    local candidate = trimmed .. "/theme.lua"
    if uv.fs_stat(candidate) then
      return candidate
    end
  end

  local candidates = {}

  -- 1. Check DOTFILES_DIR environment variable
  local env_dotfiles = os.getenv "DOTFILES_DIR"
  if env_dotfiles and env_dotfiles ~= "" then
    table.insert(candidates, env_dotfiles .. "/themes/generated/theme.lua")
  end

  -- 2. Resolve via current file location (debug.getinfo)
  local info = debug.getinfo(1, "S")
  if info and info.source and info.source:sub(1, 1) == "@" then
    local current_file = info.source:sub(2)
    local real_file = uv.fs_realpath(current_file) or current_file
    local nvim_dir = vim.fs.dirname(real_file)
    if nvim_dir then
      local dotfiles_dir = vim.fs.dirname(nvim_dir)
      if dotfiles_dir then
        table.insert(candidates, dotfiles_dir .. "/themes/generated/theme.lua")
      end
    end
  end

  -- 3. Resolve via stdpath("config") realpath
  local std_config = vim.fn.stdpath "config"
  if std_config then
    local real_config = uv.fs_realpath(std_config) or std_config
    local dotfiles_dir = vim.fs.dirname(real_config)
    if dotfiles_dir then
      table.insert(candidates, dotfiles_dir .. "/themes/generated/theme.lua")
    end
  end

  -- 4. Fallback paths (home directory & legacy path)
  local home = os.getenv "HOME" or os.getenv "USERPROFILE" or ""
  if home ~= "" then
    table.insert(candidates, home .. "/.dotfiles/themes/generated/theme.lua")
    table.insert(candidates, home .. "/Desktop/Work/dotfiles/themes/generated/theme.lua")
  end

  for _, path in ipairs(candidates) do
    if uv.fs_stat(path) then
      return path
    end
  end

  return candidates[1] or (home .. "/Desktop/Work/dotfiles/themes/generated/theme.lua")
end


local theme_path = get_theme_path()
local success, theme = pcall(dofile, theme_path)
if success and type(theme) == "table" then
  vim.schedule(function()
    vim.api.nvim_set_hl(0, "Normal", { bg = theme.bg, fg = theme.fg })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = theme.bg })
    vim.api.nvim_set_hl(0, "LineNr", { fg = theme.black })
    -- Add more custom overrides here if needed
  end)
end
