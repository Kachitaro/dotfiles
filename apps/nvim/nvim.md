This file is a merged representation of the entire codebase, combined into a single document by Repomix.

# File Summary

## Purpose
This file contains a packed representation of the entire repository's contents.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Files are sorted by Git change count (files with more changes are at the bottom)

# Directory Structure
```
lua/
  configs/
    conform.lua
    lazy.lua
    lspconfig.lua
  plugins/
    init.lua
  autocmds.lua
  chadrc.lua
  mappings.lua
  options.lua
.stylua.toml
init.lua
lazy-lock.json
```

# Files

## File: lua/configs/conform.lua
```lua
local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
```

## File: lua/configs/lazy.lua
```lua
return {
  defaults = { lazy = true },
  install = { colorscheme = { "nvchad" } },

  ui = {
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
}
```

## File: lua/configs/lspconfig.lua
```lua
require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
```

## File: lua/plugins/init.lua
```lua
return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Plugin gõ tiếng Việt trực tiếp trong Neovim (Chỉ hoạt động ở Insert Mode)
  {
    "sontungexpt/vietnamese.nvim",
    dependencies = { "sontungexpt/bim.nvim" },
    event = "InsertEnter",
    opts = {
      enabled = true,
      input_method = "telex", -- "telex" hoặc "vni"
      orthography = "modern", -- "modern" (hòa, thúy) hoặc "old" (hoà, thuý)
    },
  },

  -- Tự động ép IME hệ điều hành (Windows/macOS/Linux) về English khi ra Normal mode / thoát Neovim
  {
    "keaising/im-select.nvim",
    event = "VeryLazy",
    cond = function()
      return vim.fn.executable "im-select" == 1 or vim.fn.executable "im-select.exe" == 1
    end,
    opts = {
      default_im_select = "1033", -- US English
      default_command = "im-select",
      set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
      set_previous_events = { "InsertEnter" },
      async_switch_im = true,
    },
  },
}
```

## File: lua/autocmds.lua
```lua
require "nvchad.autocmds"


if vim.fn.has("win32") == 1 and vim.fn.executable("im-select.exe") == 1 then
  local default_im = "1033"
  local current_im = default_im

  local function get_im()
    local result = vim.fn.system('im-select.exe')
    return result:gsub("%s+", "")
  end

  local function set_im(im)
    vim.fn.jobstart({ 'im-select.exe', im }, { detach = true })
  end

  local im_augroup = vim.api.nvim_create_augroup("IMSelect", { clear = true })

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = im_augroup,
    callback = function()
      current_im = get_im()
      set_im(default_im)
    end,
  })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = im_augroup,
    callback = function()
      set_im(current_im)
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = im_augroup,
    callback = function()
      set_im(default_im)
    end,
  })

  vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = im_augroup,
    callback = function()
      set_im(default_im)
    end,
  })
end
```

## File: lua/chadrc.lua
```lua
-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "catppuccin",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
```

## File: lua/mappings.lua
```lua
require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<C-\\>", "<cmd>vsplit<CR>", { desc = "Chia dọc màn hình (Vertical Split)" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Bật/tắt gõ tiếng Việt trong Neovim
map({ "n", "i" }, "<C-e>", "<cmd>VietnameseToggle<CR>", { desc = "Toggle tiếng Việt (Telex/VNI)" })
```

## File: lua/options.lua
```lua
require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
```

## File: .stylua.toml
```toml
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "None"
```

## File: init.lua
```lua
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

  local k_out = vim.fn.system { "dot", "theme", "path" }
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
  end)
end
```

## File: lazy-lock.json
```json
{
  "LuaSnip": { "branch": "master", "commit": "0abc8f390b278c3b4aabc4c004ac8a088b65cf24" },
  "NvChad": { "branch": "v2.5", "commit": "add44b952d631981614bbb8cfc6f7002f296dfe6" },
  "base46": { "branch": "v3.0", "commit": "267954c8663607823f03a3259bb8deb15688212f" },
  "bim.nvim": { "branch": "main", "commit": "b8c00d63e68a25f53d4e316e02f83e6a0273b6e6" },
  "cmp-async-path": { "branch": "main", "commit": "98185a91d49ff5dd249aebf2f7456e18063fa2a0" },
  "cmp-buffer": { "branch": "main", "commit": "b74fab3656eea9de20a9b8116afa3cfc4ec09657" },
  "cmp-nvim-lsp": { "branch": "main", "commit": "cbc7b02bb99fae35cb42f514762b89b5126651ef" },
  "cmp-nvim-lua": { "branch": "main", "commit": "e3a22cb071eb9d6508a156306b102c45cd2d573d" },
  "cmp_luasnip": { "branch": "master", "commit": "98d9cb5c2c38532bd9bdb481067b20fea8f32e90" },
  "conform.nvim": { "branch": "master", "commit": "619363c30309d29ffa631e67c8183f2a72caa373" },
  "friendly-snippets": { "branch": "main", "commit": "6cd7280adead7f586db6fccbd15d2cac7e2188b9" },
  "gitsigns.nvim": { "branch": "main", "commit": "25050e4ed39e628282831d4cbecb1850454ce915" },
  "im-select.nvim": { "branch": "master", "commit": "963a4e9d528ef8a8d328eeff690593b0146d30e2" },
  "indent-blankline.nvim": { "branch": "master", "commit": "d28a3f70721c79e3c5f6693057ae929f3d9c0a03" },
  "lazy.nvim": { "branch": "main", "commit": "85c7ff3711b730b4030d03144f6db6375044ae82" },
  "mason.nvim": { "branch": "main", "commit": "16ba83bfc8a25f52bb545134f5bee082b195c460" },
  "menu": { "branch": "main", "commit": "7a0a4a2896b715c066cfbe320bdc048091874cc6" },
  "minty": { "branch": "main", "commit": "aafc9e8e0afe6bf57580858a2849578d8d8db9e0" },
  "nvim-autopairs": { "branch": "master", "commit": "7b9923abad60b903ece7c52940e1321d39eccc79" },
  "nvim-cmp": { "branch": "main", "commit": "2ffe79f1f021def8dd1fcd81deb16f1bb0d989f3" },
  "nvim-lspconfig": { "branch": "master", "commit": "ed19590a3a9792901553c388d1aadafce012f80d" },
  "nvim-tree.lua": { "branch": "master", "commit": "b2aadda94b107480c48e548d6db51c6840b7b33c" },
  "nvim-treesitter": { "branch": "main", "commit": "4916d6592ede8c07973490d9322f187e07dfefac" },
  "nvim-web-devicons": { "branch": "master", "commit": "2ae6958df7ced50baac5035cec0c15799eedfbf7" },
  "plenary.nvim": { "branch": "master", "commit": "74b06c6c75e4eeb3108ec01852001636d85a932b" },
  "telescope.nvim": { "branch": "master", "commit": "40aedd8a68c78a656a10a8d62d80c54af59420fb" },
  "ui": { "branch": "v3.0", "commit": "fe781d1c12860d6a25d45e588fe4fdd27eb34a1a" },
  "vietnamese.nvim": { "branch": "main", "commit": "df1ea9db573e43ed1e21101f98471b3aa05e1813" },
  "volt": { "branch": "main", "commit": "620de1321f275ec9d80028c68d1b88b409c0c8b1" },
  "which-key.nvim": { "branch": "main", "commit": "3aab2147e74890957785941f0c1ad87d0a44c15a" }
}
```
