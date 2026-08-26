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
.github/
  workflows/
    ci.yml
    release.yml
  CODEOWNERS
assets/
  showcase.png
atuin/
  themes/
    theme.toml
  atuin-receipt.json
  config.toml
bat/
  config
carapace/
  overlays/
    .gitkeep
cli/
  src/
    commands/
      add.rs
      eject.rs
      init.rs
      inject.rs
      install.rs
      mod.rs
      theme.rs
      uninstall.rs
      update.rs
    linker.rs
    main.rs
    paths.rs
    theme_engine.rs
  Cargo.toml
nvim/
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
powershell/
  functions.ps1
  Microsoft.PowerShell_profile.ps1
  set_up_windows.ps1
  user_profile.ps1
scoop/
  config.json
shell/
  .bashrc
  .zshrc
starship/
  starship.toml
themes/
  generated/
    theme.lua
    theme.ps1
    theme.sh
  theme.json
wezterm/
  core.lua
  status.lua
  ui.lua
  wezterm.lua
.gitignore
install.ps1
install.sh
LICENSE
README.md
README.vi.md
```

# Files

## File: powershell/Microsoft.PowerShell_profile.ps1
````powershell
# Load dotfiles config
. "/home/john/Desktop/Work/dotfiles/powershell/user_profile.ps1"
````

## File: .github/workflows/ci.yml
````yaml
name: CI

on:
  push:
    branches: [ "main" ]
    paths:
      - "cli/**"
      - ".github/workflows/ci.yml"
  pull_request:
    branches: [ "main" ]
    paths:
      - "cli/**"
      - ".github/workflows/ci.yml"

jobs:
  test:
    name: Test (${{ matrix.os }})
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Rust toolchain
        uses: dtolnay/rust-toolchain@stable

      - name: Rust Cache
        uses: Swatinem/rust-cache@v2
        with:
          workspaces: cli

      - name: Check
        run: cargo check --manifest-path cli/Cargo.toml

      - name: Run Tests
        run: cargo test --manifest-path cli/Cargo.toml
````

## File: .github/CODEOWNERS
````
* @kachitaro
````

## File: atuin/atuin-receipt.json
````json
{
  "binaries": ["atuin"],
  "binary_aliases": {},
  "cdylibs": [],
  "cstaticlibs": [],
  "install_layout": "flat",
  "install_prefix": "/home/john/.atuin/bin",
  "modify_path": true,
  "provider": { "source": "cargo-dist", "version": "0.31.0" },
  "source": {
    "app_name": "atuin",
    "name": "atuin",
    "owner": "atuinsh",
    "release_type": "github"
  },
  "version": "18.19.0"
}
````

## File: bat/config
````
# ==============================================================================
# 🦇 Bat Configuration File (Dotfiles)
# ==============================================================================

# Theme đồng bộ tự động từ theme.json (dot theme reload)
--theme="Catppuccin Mocha"

# Hiển thị số dòng, git modifications và header gọn gàng
--style="numbers,changes,header"

# Bật italic text nếu terminal hỗ trợ font Nerd Font
--italic-text=always

# Mặc định xuống dòng mềm (wrap) để không bị tràn màn hình
--wrap=auto

# Sử dụng UTF-8
--map-syntax "*.ps1:PowerShell"
--map-syntax "*.psm1:PowerShell"
--map-syntax "*.psd1:PowerShell"
````

## File: carapace/overlays/.gitkeep
````

````

## File: cli/src/commands/init.rs
````rust
use anyhow::{Context, Result};
use owo_colors::OwoColorize;
use std::fs;
use std::path::PathBuf;

use crate::paths;
use crate::theme_engine;

const DEFAULT_THEME_JSON: &str = include_str!("../../../themes/theme.json");

pub fn execute(target_path: Option<PathBuf>, force: bool) -> Result<()> {
    let dotfiles_dir = match target_path {
        Some(p) => paths::strip_unc_prefix(
            if p.is_absolute() {
                p
            } else {
                std::env::current_dir()?.join(p)
            }
        ),
        None => {
            let current = std::env::current_dir()?;
            let is_already_dotfiles = current
                .file_name()
                .map(|name| {
                    let s = name.to_string_lossy().to_lowercase();
                    s == "dotfiles" || s == ".dotfiles"
                })
                .unwrap_or(false);

            if is_already_dotfiles {
                paths::strip_unc_prefix(current)
            } else {
                paths::strip_unc_prefix(current.join("dotfiles"))
            }
        }
    };

    println!(
        "{}",
        format!("🔹 Khởi tạo kho dotfiles tại: {}", dotfiles_dir.display()).cyan()
    );

    // 1. Tạo thư mục dotfiles nếu chưa tồn tại
    if !dotfiles_dir.exists() {
        fs::create_dir_all(&dotfiles_dir)
            .with_context(|| format!("Không thể tạo thư mục dotfiles tại {}", dotfiles_dir.display()))?;
        println!("  ✅ Đã tạo thư mục: {}", dotfiles_dir.display());
    }

    // 2. Tạo thư mục themes và ghi default theme.json nếu chưa có
    let themes_dir = dotfiles_dir.join("themes");
    if !themes_dir.exists() {
        fs::create_dir_all(&themes_dir)
            .with_context(|| format!("Không thể tạo thư mục {}", themes_dir.display()))?;
    }

    let theme_json_path = themes_dir.join("theme.json");
    if !theme_json_path.exists() || force {
        fs::write(&theme_json_path, DEFAULT_THEME_JSON)
            .with_context(|| format!("Không thể tạo {}", theme_json_path.display()))?;
        println!("  ✅ Đã tạo file mẫu theme: {}", theme_json_path.display());
    } else {
        println!("  ℹ️  Đã có sẵn {}", theme_json_path.display());
    }

    // 3. Compile theme lần đầu
    println!("  🔄 Đang biên dịch Theme Engine ban đầu...");
    let theme_data = theme_engine::generate_themes(&dotfiles_dir)?;
    println!(
        "  ✅ Đã tạo theme '{}' tại: {}",
        theme_data.name,
        dotfiles_dir.join("themes").join("generated").display()
    );

    // 4. Thiết lập biến môi trường DOTFILES_DIR nếu trên Windows
    #[cfg(windows)]
    {
        let setx_status = std::process::Command::new("setx")
            .args(["DOTFILES_DIR", &dotfiles_dir.to_string_lossy()])
            .output();

        if let Ok(output) = setx_status {
            if output.status.success() {
                println!("  ✅ Đã tự động cấu hình biến môi trường DOTFILES_DIR.");
            }
        }
    }

    println!("\n{}", "🎉 KHỞI TẠO THÀNH CÔNG!".green().bold());
    println!("Bây giờ bạn có thể bắt đầu sử dụng các lệnh:");
    println!("  • {} : Thu nạp một cấu hình vào kho dotfiles", "dot add <path>".yellow());
    println!("  • {} : Biên dịch lại khi bạn chỉnh sửa theme.json", "dot theme reload".yellow());
    println!("  • {} : In đường dẫn chứa theme đã biên dịch", "dot theme path".yellow());

    #[cfg(unix)]
    {
        println!("\n{}", "💡 Gợi ý cấu hình biến môi trường trên Linux/macOS:".bold());
        println!("Thêm dòng sau vào ~/.bashrc hoặc ~/.zshrc:");
        println!("  export DOTFILES_DIR=\"{}\"", dotfiles_dir.display());
    }

    Ok(())
}
````

## File: cli/src/commands/theme.rs
````rust
use anyhow::Result;
use owo_colors::OwoColorize;

use crate::paths;
use crate::theme_engine;

pub fn reload() -> Result<()> {
    let dotfiles_dir = paths::resolve_dotfiles_dir()?;
    println!("{}", "Đang tải lại giao diện (Theme Engine)...".cyan());

    let theme_data = theme_engine::generate_themes(&dotfiles_dir)?;
    let _sh_path = dotfiles_dir.join("themes").join("generated").join("theme.sh");

    println!(
        "{}",
        format!(
            "Theme '{}' compiled! (WezTerm & Neovim reload automatically)",
            theme_data.name
        )
        .green()
    );

    #[cfg(windows)]
    {
        println!(
            "{}",
            "Note: Khởi động lại terminal hoặc mở tab mới để biến môi trường áp dụng cho prompt.".yellow()
        );
    }

    #[cfg(unix)]
    {
        println!(
            "{}",
            format!(
                "Note: Để apply màu mới vào Shell hiện tại, chạy thủ công: source {} (hoặc mở terminal mới)",
                _sh_path.display()
            )
            .yellow()
        );
    }


    Ok(())
}

pub fn print_path() -> Result<()> {
    let path = paths::theme_generated_dir()?;
    // Print plain absolute path without extra text so Neovim/WezTerm/scripts can directly eval/dofile it
    println!("{}", path.display());
    Ok(())
}
````

## File: cli/src/linker.rs
````rust
use anyhow::{Context, Result};
use owo_colors::OwoColorize;
use std::fs;
use std::io;
use std::path::Path;
use std::time::{SystemTime, UNIX_EPOCH};

/// Check whether a path exists and is a symlink or reparse point.
pub fn is_symlink(path: &Path) -> bool {
    fs::symlink_metadata(path)
        .map(|m| m.file_type().is_symlink())
        .unwrap_or(false)
}

/// Recursively copy a directory and all of its contents.
pub fn copy_dir_all(src: &Path, dst: &Path) -> io::Result<()> {
    fs::create_dir_all(dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let file_type = entry.file_type()?;
        let dst_path = dst.join(entry.file_name());
        if file_type.is_dir() {
            copy_dir_all(&entry.path(), &dst_path)?;
        } else {
            fs::copy(entry.path(), dst_path)?;
        }
    }
    Ok(())
}

/// Remove a symlink safely across platforms.
pub fn remove_symlink(path: &Path, is_dir: bool) -> io::Result<()> {
    #[cfg(windows)]
    {
        if is_dir {
            // Windows directory symlinks/junctions must be removed via remove_dir
            if fs::remove_dir(path).is_ok() {
                return Ok(());
            }
        }
    }
    let _ = is_dir;
    fs::remove_file(path)
}

fn get_timestamp() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs()
}

/// Create a safe symlink from `link` pointing to `target`.
/// 
/// 1. If `target` does not exist -> warns and skips without error.
/// 2. If `link` already is a symlink -> removes it and recreates.
/// 3. If `link` is a real file/dir -> backups to `<link>.bak_<timestamp>` (or deletes if `force` is true).
/// 4. Creates symlink (Windows: symlink_file/symlink_dir, Unix: symlink).
/// 5. Windows fallback: if symlink creation fails (insufficient privileges / Dev Mode disabled),
///    falls back to copying files/directories.
pub fn create_safe_link(link: &Path, target: &Path, is_dir: bool, force: bool) -> Result<()> {
    if !target.exists() {
        eprintln!(
            "{}",
            format!("  ⚠️ Target không tồn tại: {}", target.display()).yellow()
        );
        return Ok(());
    }

    if let Some(parent) = link.parent() {
        if !parent.exists() {
            fs::create_dir_all(parent)
                .with_context(|| format!("Không thể tạo thư mục cha: {}", parent.display()))?;
        }
    }

    let link_exists_or_symlink = fs::symlink_metadata(link).is_ok();

    if link_exists_or_symlink {
        if is_symlink(link) {
            remove_symlink(link, is_dir)
                .with_context(|| format!("Không thể gỡ symlink cũ: {}", link.display()))?;
        } else {
            // Real file or directory
            if force {
                if is_dir && link.is_dir() {
                    fs::remove_dir_all(link)
                        .with_context(|| format!("Không thể xóa thư mục cũ: {}", link.display()))?;
                } else {
                    fs::remove_file(link)
                        .with_context(|| format!("Không thể xóa file cũ: {}", link.display()))?;
                }
                println!(
                    "{}",
                    format!("  ⚠️ Đã xóa (ghi đè) file/thư mục hiện tại: {}", link.display()).yellow()
                );
            } else {
                let timestamp = get_timestamp();
                let backup_path = format!("{}.bak_{}", link.display(), timestamp);
                fs::rename(link, &backup_path).with_context(|| {
                    format!(
                        "Không thể sao lưu file/thư mục hiện tại sang: {}",
                        backup_path
                    )
                })?;
                println!(
                    "{}",
                    format!("  ⚠️ Đã sao lưu file/thư mục hiện tại sang: {}", backup_path).yellow()
                );
            }
        }
    }

    #[cfg(unix)]
    {
        std::os::unix::fs::symlink(target, link).with_context(|| {
            format!(
                "Lỗi khi tạo symlink {} -> {}",
                link.display(),
                target.display()
            )
        })?;
        println!(
            "{}",
            format!("  ✅ Linked: {} -> {}", link.display(), target.display()).green()
        );
    }

    #[cfg(windows)]
    {
        let symlink_result = if is_dir {
            std::os::windows::fs::symlink_dir(target, link)
        } else {
            std::os::windows::fs::symlink_file(target, link)
        };

        match symlink_result {
            Ok(_) => {
                println!(
                    "{}",
                    format!("  ✅ Linked: {} -> {}", link.display(), target.display()).green()
                );
            }
            Err(e) => {
                println!(
                    "{}",
                    format!(
                        "  ⚠️ Không thể tạo Symlink ({}). Tiến hành copy file/thư mục thay thế...",
                        e
                    )
                    .yellow()
                );
                if is_dir {
                    copy_dir_all(target, link).with_context(|| {
                        format!("Không thể copy thư mục fallback {} -> {}", target.display(), link.display())
                    })?;
                } else {
                    fs::copy(target, link).with_context(|| {
                        format!("Không thể copy file fallback {} -> {}", target.display(), link.display())
                    })?;
                }
                println!(
                    "{}",
                    format!("  ✅ Copied: {} -> {}", link.display(), target.display()).green()
                );
            }
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_create_safe_link_file_backup_and_overwrite() {
        let temp = tempdir().unwrap();
        let target_file = temp.path().join("source.txt");
        let link_file = temp.path().join("dest.txt");

        fs::write(&target_file, "hello world").unwrap();
        fs::write(&link_file, "original content").unwrap();

        // Safe link without force should backup original
        create_safe_link(&link_file, &target_file, false, false).unwrap();

        // dest.txt exists
        assert!(link_file.exists());

        // A backup file dest.txt.bak_* exists
        let mut backups = Vec::new();
        for entry in fs::read_dir(temp.path()).unwrap() {
            let entry = entry.unwrap();
            let name = entry.file_name().to_string_lossy().to_string();
            if name.starts_with("dest.txt.bak_") {
                backups.push(name);
            }
        }
        assert_eq!(backups.len(), 1);

        // Re-linking existing symlink should recreate without extra backups
        create_safe_link(&link_file, &target_file, false, false).unwrap();
        assert!(link_file.exists());
    }

    #[test]
    fn test_create_safe_link_nonexistent_target_skips() {
        let temp = tempdir().unwrap();
        let target_file = temp.path().join("missing.txt");
        let link_file = temp.path().join("dest.txt");

        // Should return Ok without creating link
        create_safe_link(&link_file, &target_file, false, false).unwrap();
        assert!(!link_file.exists());
    }

    #[test]
    fn test_create_safe_link_dir_force() {
        let temp = tempdir().unwrap();
        let target_dir = temp.path().join("source_dir");
        let link_dir = temp.path().join("dest_dir");

        fs::create_dir_all(&target_dir).unwrap();
        fs::write(target_dir.join("file.txt"), "hello").unwrap();

        fs::create_dir_all(&link_dir).unwrap();
        fs::write(link_dir.join("old.txt"), "old").unwrap();

        // Safe link with force = true should delete existing real directory without backup
        create_safe_link(&link_dir, &target_dir, true, true).unwrap();
        assert!(link_dir.exists());

        let mut backups = Vec::new();
        for entry in fs::read_dir(temp.path()).unwrap() {
            let entry = entry.unwrap();
            let name = entry.file_name().to_string_lossy().to_string();
            if name.starts_with("dest_dir.bak_") {
                backups.push(name);
            }
        }
        assert_eq!(backups.len(), 0);
    }
}
````

## File: nvim/lua/configs/conform.lua
````lua
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
````

## File: nvim/lua/configs/lazy.lua
````lua
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
````

## File: nvim/lua/configs/lspconfig.lua
````lua
require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
````

## File: nvim/lua/options.lua
````lua
require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
````

## File: nvim/.stylua.toml
````toml
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "None"
````

## File: nvim/lazy-lock.json
````json
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
````

## File: themes/theme.json
````json
{
  "name": "Catppuccin Mocha",
  "bg": "#1e1e2e",
  "fg": "#cdd6f4",
  "black": "#45475a",
  "red": "#f38ba8",
  "green": "#a6e3a1",
  "yellow": "#f9e2af",
  "blue": "#89b4fa",
  "magenta": "#f5c2e7",
  "cyan": "#94e2d5",
  "white": "#bac2de"
}
````

## File: wezterm/wezterm.lua
````lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

require('core').setup(config)
require('ui').setup(config)
require('status').setup()

return config
````

## File: LICENSE
````
MIT License

Copyright (c) 2026 kachitaro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
````

## File: atuin/config.toml
````toml
# ==============================================================================
# Cấu hình Atuin (Lịch sử terminal siêu cấp)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Giao diện (UI)
# ------------------------------------------------------------------------------
# Chế độ hiển thị: "compact" (gọn gàng, giống fzf), "full" (hiện nhiều thông tin), "blind" (siêu gọn)
style = "full"

# Hiển thị giao diện Atuin ở dưới cùng của terminal (thay vì bung đầy toàn màn hình)
inline_height = 15

# Vị trí thanh tìm kiếm: "bottom" (dưới cùng) hoặc "top" (trên cùng)
invert = true

# Định dạng thời gian (ví dụ: "2024-10-01 14:30" thay vì "1 hour ago")
# Các lựa chọn: "l", "r" (relative - tương đối), "d" (date), "t" (time), "dt" (date time)
time_format = "l"

# ------------------------------------------------------------------------------
# 2. Hành vi tìm kiếm (Search Behavior)
# ------------------------------------------------------------------------------
# Chế độ tìm kiếm mặc định. "fuzzy" (gõ sai chữ cũng ra), "prefix" (khớp từ đầu), "exact" (khớp hoàn toàn)
search_mode = "fuzzy"

# Chỉ tìm kiếm lịch sử trong thư mục hiện tại theo mặc định? 
# "global" (toàn bộ), "host" (máy này), "session" (tab hiện tại), "directory" (thư mục này)
filter_mode_default = "global"

# Lệnh này có giúp bạn khi ấn Enter, terminal sẽ chỉ ĐIỀN lệnh vào prompt chứ chưa CHẠY NGAY
# Tính năng này cực kỳ an toàn, giúp bạn có cơ hội kiểm tra và sửa lệnh trước khi nhấn Enter thêm lần nữa.
enter_accept = true

# ------------------------------------------------------------------------------
# 3. Quản lý dữ liệu & Bỏ qua (Sync & Ignore)
# ------------------------------------------------------------------------------
# (Bật nếu bạn có dùng server Atuin để đồng bộ) Tự động đồng bộ lịch sử giữa các máy tính.
auto_sync = false

# Tần suất đồng bộ ngầm (tính bằng giây). Mặc định là 1 tiếng (3600s).
sync_frequency = 3600

# Bỏ qua không lưu những lệnh chứa mật khẩu hoặc lệnh quá ngắn/thường xuyên
secrets_filter = true
history_filter = [
    "^clear",
    "^ls",
    "^ll",
    "^la",
    "^cd",
    "^exit"
]

# ------------------------------------------------------------------------------
# 4. Giao diện màu sắc (Theme)
# ------------------------------------------------------------------------------
[theme]
name = "theme"
````

## File: cli/src/commands/add.rs
````rust
use anyhow::{bail, Context, Result};
use owo_colors::OwoColorize;
use std::fs;
use std::path::PathBuf;

use crate::linker::{copy_dir_all, create_safe_link, is_symlink};
use crate::paths;

pub fn execute(path: PathBuf) -> Result<()> {
    if !path.exists() {
        bail!("❌ Đường dẫn không tồn tại: {}", path.display());
    }

    if is_symlink(&path) {
        bail!("❌ Đường dẫn này đã là symlink (đã được quản lý rồi)!");
    }

    let canonical_path = paths::strip_unc_prefix(
        path.canonicalize()
            .with_context(|| format!("Không thể chuẩn hóa đường dẫn: {}", path.display()))?,
    );

    let is_dir = canonical_path.is_dir();
    let basename = canonical_path
        .file_name()
        .ok_or_else(|| anyhow::anyhow!("Đường dẫn không hợp lệ: {}", canonical_path.display()))?;

    let dotfiles_dir = paths::resolve_dotfiles_dir()?;
    let dotfiles_dest = dotfiles_dir.join(basename);

    if dotfiles_dest.exists() {
        bail!(
            "❌ Thư mục/tệp đích đã tồn tại trong dotfiles: {}",
            dotfiles_dest.display()
        );
    }

    let basename_str = basename.to_string_lossy();
    println!(
        "{}",
        format!("🔹 Đang thu nạp '{}' vào kho dotfiles...", basename_str).cyan()
    );

    // Try rename/move first. If cross-device move fails, copy and delete.
    if let Err(_) = fs::rename(&canonical_path, &dotfiles_dest) {
        if is_dir {
            copy_dir_all(&canonical_path, &dotfiles_dest)?;
            fs::remove_dir_all(&canonical_path)?;
        } else {
            fs::copy(&canonical_path, &dotfiles_dest)?;
            fs::remove_file(&canonical_path)?;
        }
    }

    create_safe_link(&canonical_path, &dotfiles_dest, is_dir, false)?;

    println!("{}", "  ✅ Thu nạp thành công!".green());
    println!(
        "{}",
        format!(
            "🎉 Thư mục \"{}\" đã được tích hợp và sẽ tự động đồng bộ (Auto-Discover) trong các lần chạy sau!",
            basename_str
        )
        .cyan()
    );

    Ok(())
}
````

## File: cli/src/commands/eject.rs
````rust
use anyhow::Result;
use owo_colors::OwoColorize;
use std::fs;
use std::path::{Path, PathBuf};

use crate::linker::{copy_dir_all, is_symlink, remove_symlink};
use crate::paths;

pub fn execute() -> Result<()> {
    let dotfiles_dir = paths::resolve_dotfiles_dir()?;
    println!(
        "{}",
        "🔹 Đang phục hồi (eject) cấu hình về máy thực...".cyan()
    );

    let home_dir = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));
    let targets = paths::discover_app_targets(&dotfiles_dir);

    for target in targets {
        restore_app_if_symlinked(&target.src, &target.dest, target.is_dir, &target.name)?;
    }

    #[cfg(windows)]
    {
        // Clean PowerShell profile scripts
        clean_powershell_profiles(&home_dir)?;
    }

    #[cfg(unix)]
    {
        // Clean bashrc, zshrc, pwsh
        clean_unix_shell_profiles(&home_dir)?;
    }

    println!(
        "\n{}",
        "🎉 Quá trình EJECT hoàn tất! Máy bạn đã độc lập.".green()
    );
    println!(
        "{}",
        format!(
            "Giờ bạn có thể xóa an toàn thư mục: {}",
            dotfiles_dir.display()
        )
        .yellow()
    );

    Ok(())
}

fn restore_app_if_symlinked(src: &Path, dest: &Path, is_dir: bool, name: &str) -> Result<()> {
    if is_symlink(dest) {
        remove_symlink(dest, is_dir)?;
        if src.exists() {
            if is_dir {
                copy_dir_all(src, dest)?;
            } else {
                fs::copy(src, dest)?;
            }
            println!(
                "{}",
                format!("  ✅ Đã phục hồi: {} -> {}", name, dest.display()).green()
            );
        }
    }
    Ok(())
}

#[cfg(windows)]
fn clean_powershell_profiles(home_dir: &Path) -> Result<()> {
    println!(
        "{}",
        "\n🔹 Gỡ cấu hình khỏi PowerShell Profile...".cyan()
    );

    let doc_dir = dirs::document_dir().unwrap_or_else(|| home_dir.join("Documents"));
    let candidate_profiles = [
        doc_dir.join("PowerShell").join("Microsoft.PowerShell_profile.ps1"),
        doc_dir.join("PowerShell").join("profile.ps1"),
        doc_dir.join("WindowsPowerShell").join("Microsoft.PowerShell_profile.ps1"),
        doc_dir.join("WindowsPowerShell").join("profile.ps1"),
        home_dir.join("Documents").join("PowerShell").join("Microsoft.PowerShell_profile.ps1"),
        home_dir.join("Documents").join("WindowsPowerShell").join("Microsoft.PowerShell_profile.ps1"),
    ];

    for profile in candidate_profiles {
        if profile.is_file() {
            if let Ok(content) = fs::read_to_string(&profile) {
                let cleaned_lines: Vec<&str> = content
                    .lines()
                    .filter(|line| {
                        !line.contains("# Load dotfiles user profile")
                            && !line.contains("user_profile.ps1")
                    })
                    .collect();
                let new_content = cleaned_lines.join("\r\n");
                if new_content != content {
                    fs::write(&profile, new_content)?;
                    println!(
                        "{}",
                        format!("  ✅ Đã gỡ cấu hình khỏi: {}", profile.display()).green()
                    );
                }
            }
        }
    }

    Ok(())
}

#[cfg(unix)]
fn clean_unix_shell_profiles(home_dir: &Path) -> Result<()> {
    println!(
        "{}",
        "\n🔹 Gỡ bỏ dòng load dotfiles khỏi shell profile...".cyan()
    );

    let shell_profiles = [
        home_dir.join(".bashrc"),
        home_dir.join(".zshrc"),
        home_dir.join(".config").join("powershell").join("Microsoft.PowerShell_profile.ps1"),
    ];

    for profile in shell_profiles {
        if profile.is_file() {
            if let Ok(content) = fs::read_to_string(&profile) {
                let cleaned_lines: Vec<&str> = content
                    .lines()
                    .filter(|line| {
                        !line.contains("# Load dotfiles config")
                            && !line.contains("dotfiles/shell/.bashrc")
                            && !line.contains("dotfiles/shell/.zshrc")
                            && !line.contains("user_profile.ps1")
                    })
                    .collect();
                let new_content = cleaned_lines.join("\n");
                if new_content != content {
                    fs::write(&profile, new_content)?;
                    println!(
                        "{}",
                        format!("  ✅ Đã gỡ cấu hình khỏi: {}", profile.display()).green()
                    );
                }
            }
        }
    }

    Ok(())
}
````

## File: cli/src/commands/inject.rs
````rust
use anyhow::Result;
use owo_colors::OwoColorize;
use std::fs;
use std::path::{Path, PathBuf};

use crate::linker::create_safe_link;
use crate::paths;
use crate::theme_engine;

pub fn execute(force: bool) -> Result<()> {
    let dotfiles_dir = paths::resolve_dotfiles_dir()?;
    println!(
        "{}",
        "🔹 Đang đồng bộ và liên kết (inject) cấu hình vào hệ thống...".cyan()
    );

    let home_dir = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));
    let targets = paths::discover_app_targets(&dotfiles_dir);

    for target in targets {
        if target.src.exists() {
            create_safe_link(&target.dest, &target.src, target.is_dir, force)?;
        }
    }

    #[cfg(windows)]
    {
        // Re-inject PowerShell profile loading
        inject_powershell_profiles(&dotfiles_dir, &home_dir)?;
    }

    #[cfg(unix)]
    {
        // Re-inject shell profiles
        inject_unix_shell_profiles(&dotfiles_dir, &home_dir)?;
    }

    // Compile theme files to ensure themes/generated/ is up-to-date
    if let Err(e) = theme_engine::generate_themes(&dotfiles_dir) {
        eprintln!(
            "{}",
            format!("  ⚠️ Không thể biên dịch Theme: {}", e).yellow()
        );
    }

    println!(
        "\n{}",
        "🎉 Quá trình INJECT hoàn tất! Hệ thống đã được liên kết lại với Dotfiles.".green()
    );

    Ok(())
}

#[cfg(windows)]
fn inject_powershell_profiles(dotfiles_dir: &Path, home_dir: &Path) -> Result<()> {
    println!(
        "{}",
        "\n🔹 Nạp cấu hình vào PowerShell Profile...".cyan()
    );

    let doc_dir = dirs::document_dir().unwrap_or_else(|| home_dir.join("Documents"));
    let target_profiles = [
        doc_dir.join("PowerShell").join("Microsoft.PowerShell_profile.ps1"),
        doc_dir.join("WindowsPowerShell").join("Microsoft.PowerShell_profile.ps1"),
        home_dir.join("Documents").join("PowerShell").join("Microsoft.PowerShell_profile.ps1"),
        home_dir.join("Documents").join("WindowsPowerShell").join("Microsoft.PowerShell_profile.ps1"),
    ];

    let source_line = format!(
        "\r\n# Load dotfiles user profile\r\n. \"{}\\powershell\\user_profile.ps1\"\r\n",
        dotfiles_dir.display()
    );

    for profile in target_profiles {
        if let Some(parent) = profile.parent() {
            let _ = fs::create_dir_all(parent);
        }

        let existing = if profile.is_file() {
            fs::read_to_string(&profile).unwrap_or_default()
        } else {
            String::new()
        };

        if !existing.contains("user_profile.ps1") {
            let mut new_content = existing;
            new_content.push_str(&source_line);
            fs::write(&profile, new_content)?;
            println!(
                "{}",
                format!("  ✅ Đã nạp dotfiles vào: {}", profile.display()).green()
            );
        } else {
            println!(
                "{}",
                format!("  ✅ Profile đã được cấu hình trước đó: {}", profile.display()).green()
            );
        }
    }

    Ok(())
}

#[cfg(unix)]
fn inject_unix_shell_profiles(dotfiles_dir: &Path, home_dir: &Path) -> Result<()> {
    println!(
        "{}",
        "\n🔹 Nạp cấu hình vào Shell Profiles...".cyan()
    );

    let bash_line = format!(
        "\n# Load dotfiles config\n[ -f \"{}/shell/.bashrc\" ] && source \"{}/shell/.bashrc\"\n",
        dotfiles_dir.display(),
        dotfiles_dir.display()
    );

    let zsh_line = format!(
        "\n# Load dotfiles config\n[ -f \"{}/shell/.zshrc\" ] && source \"{}/shell/.zshrc\"\n",
        dotfiles_dir.display(),
        dotfiles_dir.display()
    );

    let bashrc = home_dir.join(".bashrc");
    let existing_bash = fs::read_to_string(&bashrc).unwrap_or_default();
    if !existing_bash.contains("dotfiles/shell/.bashrc") {
        let mut new_content = existing_bash;
        new_content.push_str(&bash_line);
        fs::write(&bashrc, new_content)?;
        println!("{}", "  ✅ Đã nạp dotfiles vào ~/.bashrc".green());
    }

    let zshrc = home_dir.join(".zshrc");
    let existing_zsh = fs::read_to_string(&zshrc).unwrap_or_default();
    if !existing_zsh.contains("dotfiles/shell/.zshrc") {
        let mut new_content = existing_zsh;
        new_content.push_str(&zsh_line);
        fs::write(&zshrc, new_content)?;
        println!("{}", "  ✅ Đã nạp dotfiles vào ~/.zshrc".green());
    }

    // PowerShell on Linux
    let pwsh_profile_dir = home_dir.join(".config").join("powershell");
    let pwsh_profile = pwsh_profile_dir.join("Microsoft.PowerShell_profile.ps1");
    let pwsh_line = format!(
        "\n# Load dotfiles config\n. \"{}/powershell/user_profile.ps1\"\n",
        dotfiles_dir.display()
    );

    let _ = fs::create_dir_all(&pwsh_profile_dir);
    let existing_pwsh = fs::read_to_string(&pwsh_profile).unwrap_or_default();
    if !existing_pwsh.contains("user_profile.ps1") {
        let mut new_content = existing_pwsh;
        new_content.push_str(&pwsh_line);
        fs::write(&pwsh_profile, new_content)?;
        println!("{}", "  ✅ Đã nạp dotfiles vào PowerShell profile".green());
    }

    Ok(())
}
````

## File: cli/src/commands/install.rs
````rust
use anyhow::{bail, Context, Result};
use std::process::Command;

use crate::paths;

pub fn execute(force: bool) -> Result<()> {
    let dotfiles_dir = paths::resolve_dotfiles_dir()?;

    #[cfg(windows)]
    {
        let script_path = dotfiles_dir.join("install.ps1");
        if !script_path.exists() {
            bail!("Không tìm thấy script cài đặt: {}", script_path.display());
        }

        let ps_cmd = if Command::new("pwsh").arg("-v").output().is_ok() {
            "pwsh"
        } else {
            "powershell"
        };

        let mut cmd = Command::new(ps_cmd);
        cmd.arg("-ExecutionPolicy")
            .arg("Bypass")
            .arg("-File")
            .arg(&script_path)
            .arg("-Full");

        if force {
            cmd.arg("-ForceInstall");
        }

        let status = cmd
            .status()
            .with_context(|| format!("Không thể thực thi script cài đặt bằng {}", ps_cmd))?;

        if !status.success() {
            bail!("Script cài đặt kết thúc với lỗi (exit code: {:?})", status.code());
        }
    }

    #[cfg(unix)]
    {
        let script_path = dotfiles_dir.join("install.sh");
        if !script_path.exists() {
            bail!("Không tìm thấy script cài đặt: {}", script_path.display());
        }

        let mut cmd = Command::new("bash");
        cmd.arg(&script_path).arg("--full");

        if force {
            cmd.arg("--force");
        }

        let status = cmd
            .status()
            .with_context(|| "Không thể thực thi script cài đặt bằng bash")?;

        if !status.success() {
            bail!("Script cài đặt kết thúc với lỗi (exit code: {:?})", status.code());
        }
    }


    Ok(())
}
````

## File: cli/src/commands/mod.rs
````rust
pub mod add;
pub mod eject;
pub mod init;
pub mod inject;
pub mod install;
pub mod theme;
pub mod uninstall;
pub mod update;
````

## File: nvim/lua/plugins/init.lua
````lua
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
````

## File: nvim/lua/autocmds.lua
````lua
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
````

## File: nvim/lua/chadrc.lua
````lua
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
````

## File: nvim/lua/mappings.lua
````lua
require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<C-\\>", "<cmd>vsplit<CR>", { desc = "Chia dọc màn hình (Vertical Split)" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Bật/tắt gõ tiếng Việt trong Neovim
map({ "n", "i" }, "<C-e>", "<cmd>VietnameseToggle<CR>", { desc = "Toggle tiếng Việt (Telex/VNI)" })
````

## File: powershell/set_up_windows.ps1
````powershell
# Wrapper script để chạy installer chính
$installScript = Join-Path $PSScriptRoot "..\install.ps1"
if (Test-Path $installScript) {
    & $installScript @args
} else {
    Write-Host "Downloading and running latest installer..." -ForegroundColor Cyan
    irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex
}
````

## File: scoop/config.json
````json
{
  "last_update": "2026-08-22T22:20:30.4917022+07:00",
  "scoop_repo": "https://github.com/ScoopInstaller/Scoop",
  "scoop_branch": "master",
  "purge_old_versions": true
}
````

## File: shell/.zshrc
````
# ==============================================================================
# 🚀 ZSH Configuration File (Dotfiles)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Environment Variables & Paths (Load First)
# ------------------------------------------------------------------------------
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LESSCHARSET="utf-8"

# Preferred Editor
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
    export VISUAL='nvim'
fi

# Path Setup
export PATH="$HOME/.local/bin:$PATH"

# Bun & FNM Runtime
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"
[ -d "$HOME/.local/share/fnm" ] && export PATH="$HOME/.local/share/fnm:$PATH"

# Custom Config Paths
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export BAT_CONFIG_DIR="$HOME/.config/bat"
export BAT_CONFIG_PATH="$HOME/.config/bat/config"

# Dotfiles Directory Logic
if [ -z "$DOTFILES_DIR" ]; then
    if [ -n "${(%):-%x}" ]; then
        DOTFILES_DIR="$(cd "$(dirname "${(%):-%x}")/.." 2>/dev/null && pwd)"
    fi
fi
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# ------------------------------------------------------------------------------
# 2. Aliases & Utility Shortcuts
# ------------------------------------------------------------------------------
# Navigation
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'

# Basic Tools
alias g='git'
alias vi='nvim'
alias vim='nvim'

# Bat (Modern cat)
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
fi
if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
    alias b='bat'
fi

# Eza (Modern ls)
export EZA_COLORS="di=1;34:ln=35"
export EZA_STANDARD_OPTIONS="--color=always --icons=always --group-directories-first"

alias ls="eza $EZA_STANDARD_OPTIONS"
alias ll="eza -al $EZA_STANDARD_OPTIONS --git --time-style=long-iso --color-scale"
alias la="eza -a $EZA_STANDARD_OPTIONS"
alias lt="eza -a --tree --level=3 $EZA_STANDARD_OPTIONS"

# ------------------------------------------------------------------------------
# 3. Completion Base (Compinit)
# ------------------------------------------------------------------------------
autoload -Uz compinit
compinit

# ------------------------------------------------------------------------------
# 4. Modern CLI Tools & Completion Initializations
# ------------------------------------------------------------------------------

# Zoxide (Modern cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# Atuin (SQLite Shell History)
[ -f "$HOME/.atuin/bin/env" ] && source "$HOME/.atuin/bin/env"
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"

# Fzf (Fuzzy Finder)
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --info=inline"
    export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza -a --tree --level=2 --color=always --icons=always {}; else bat --color=always --style=numbers,changes {}; fi' --preview-window 'right:55%,border-left' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
    export FZF_ALT_C_OPTS="--preview 'eza -a --tree --level=2 --color=always --icons=always {}' --preview-window 'right:55%,border-left' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
    source <(fzf --zsh)
fi

# Carapace (Multi-shell Completion)
if command -v carapace >/dev/null 2>&1; then
    export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
    source <(carapace _carapace zsh)
fi

# FNM (Fast Node Manager)
if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd --shell zsh)"
fi

# Starship Prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ------------------------------------------------------------------------------
# 5. Functions & Themes
# ------------------------------------------------------------------------------
get_system_size() {
    echo -e "\033[0;32m====== Disk Usage Report ======\033[0m"
    df -h /
    echo ""
    echo -e "\033[0;32m====== Top 10 Largest Directories in Home ======\033[0m"
    du -h -d 2 "$HOME" 2>/dev/null | sort -hr | head -n 10
}

# Load Theme
if [ -f "$DOTFILES_DIR/themes/generated/theme.sh" ]; then
    source "$DOTFILES_DIR/themes/generated/theme.sh"
elif [ -f "$HOME/Desktop/Work/dotfiles/themes/generated/theme.sh" ]; then
    source "$HOME/Desktop/Work/dotfiles/themes/generated/theme.sh"
fi

# ------------------------------------------------------------------------------
# 6. ZSH Plugins (Must be loaded at the very end!)
# ------------------------------------------------------------------------------
if [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# NOTE: zsh-syntax-highlighting MUST be the LAST plugin sourced!
if [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
````

## File: wezterm/status.lua
````lua
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
      'pwsh.exe', '-NoProfile', '-NonInteractive', '-Command',
      "(Get-CimInstance Win32_OperatingSystem | ForEach-Object { [Math]::Round((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) / $_.TotalVisibleMemorySize) * 100) })"
    })
    if success and stdout then
      return stdout:gsub("%s+", "")
    end
  elseif is_linux then
    -- Đọc trực tiếp /proc/meminfo siêu nhanh trên Linux mà không cần spawn child process
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
````

## File: .gitignore
````
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
desktop.ini

# Backup files (generated by dotfiles install/uninstall scripts)
*.bak
*.bak_*
*.tmp
*.swp
*.swo

# Python bytecode & cache (scripts/generate_theme.py)
__pycache__/
*.py[cod]
*$py.class
.pytest_cache/

# Editor / IDE directories
.idea/
.vscode/
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?

# Environment & Secrets
.env
.env.local
*.pem
*.key
secrets.json

# Logs
*.log

# Rust / Cargo build artifacts
target/
cli/target/
bin/*.exe
````

## File: .github/workflows/release.yml
````yaml
name: Release

on:
  push:
    branches:
      - "release"
    tags:
      - "v*"
  pull_request:
    types:
      - closed
    branches:
      - "release"
  workflow_dispatch:
    inputs:
      version:
        description: "Version to release (e.g. 0.1.1 or leave empty to auto-bump patch)"
        required: false
        default: ""


permissions:
  contents: write

jobs:
  prepare-version:
    name: Prepare Release Version
    if: github.event_name != 'pull_request' || github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.get_version.outputs.version }}
      tag: ${{ steps.get_version.outputs.tag }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Calculate Release Version
        id: get_version
        run: |
          # 1. Đọc version hiện tại từ cli/Cargo.toml
          CURRENT_VER=$(grep -m1 '^version = ' cli/Cargo.toml | sed -E 's/version = "(.*)"/\1/')
          echo "Current Cargo.toml version: $CURRENT_VER"

          INPUT_VER="${{ github.event.inputs.version }}"

          if [ -n "$INPUT_VER" ]; then
            # Nếu người dùng nhập thủ công qua workflow_dispatch
            CLEAN_VER="${INPUT_VER#v}"
          elif [[ "${{ github.ref }}" =~ ^refs/tags/v ]]; then
            # Nếu kích hoạt bằng push tag
            CLEAN_VER="${GITHUB_REF_NAME#v}"
          else
            # Kích hoạt khi push vào nhánh release: kiểm tra xem tag đã tồn tại chưa
            if git rev-parse "v$CURRENT_VER" >/dev/null 2>&1; then
              # Tag đã tồn tại -> tự động tăng patch version (vd: 0.1.0 -> 0.1.1)
              IFS='.' read -r major minor patch <<< "$CURRENT_VER"
              NEW_PATCH=$((patch + 1))
              CLEAN_VER="${major}.${minor}.${NEW_PATCH}"
              echo "Auto-bumped patch version from $CURRENT_VER to $CLEAN_VER"
            else
              CLEAN_VER="$CURRENT_VER"
            fi
          fi

          TAG="v$CLEAN_VER"
          echo "tag=$TAG" >> $GITHUB_OUTPUT
          echo "version=$CLEAN_VER" >> $GITHUB_OUTPUT
          echo "Target Tag: $TAG, Version: $CLEAN_VER"

  build-release:
    name: Build (${{ matrix.target }})
    needs: [prepare-version]
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        include:
          - os: windows-latest
            target: x86_64-pc-windows-msvc
            bin_name: dot.exe
            archive_ext: zip
          - os: ubuntu-latest
            target: x86_64-unknown-linux-gnu
            bin_name: dot
            archive_ext: tar.gz
          - os: ubuntu-latest
            target: aarch64-unknown-linux-gnu
            bin_name: dot
            archive_ext: tar.gz
            use_cross: true
          - os: macos-latest
            target: aarch64-apple-darwin
            bin_name: dot
            archive_ext: tar.gz
          - os: macos-latest
            target: x86_64-apple-darwin
            bin_name: dot
            archive_ext: tar.gz

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Rust toolchain
        uses: dtolnay/rust-toolchain@stable
        with:
          targets: ${{ matrix.target }}

      - name: Update Version in Cargo.toml
        run: |
          VERSION="${{ needs.prepare-version.outputs.version }}"
          echo "Updating Cargo.toml version to $VERSION"
          sed -i -E "s/^version = \".*\"/version = \"$VERSION\"/" cli/Cargo.toml
          cat cli/Cargo.toml | head -n 10
        shell: bash

      - name: Install Cross (if needed)
        if: matrix.use_cross
        run: cargo install cross --git https://github.com/cross-rs/cross

      - name: Build Binary
        run: |
          if [ "${{ matrix.use_cross }}" = "true" ]; then
            cross build --release --manifest-path cli/Cargo.toml --target ${{ matrix.target }}
          else
            cargo build --release --manifest-path cli/Cargo.toml --target ${{ matrix.target }}
          fi
        shell: bash

      - name: Package Archive (Unix)
        if: matrix.os != 'windows-latest'
        run: |
          ARCHIVE_NAME="dot-${{ matrix.target }}.tar.gz"
          cd cli/target/${{ matrix.target }}/release
          tar -czf "../../../../${ARCHIVE_NAME}" dot
        shell: bash

      - name: Package Archive (Windows)
        if: matrix.os == 'windows-latest'
        run: |
          $archiveName = "dot-${{ matrix.target }}.zip"
          Compress-Archive -Path "cli\target\${{ matrix.target }}\release\dot.exe" -DestinationPath $archiveName
        shell: pwsh

      - name: Upload Artifact
        uses: actions/upload-artifact@v4
        with:
          name: dot-${{ matrix.target }}
          path: dot-${{ matrix.target }}.${{ matrix.archive_ext }}

  publish-release:
    name: Publish GitHub Release
    needs: [prepare-version, build-release]
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Download all artifacts
        uses: actions/download-artifact@v4
        with:
          path: release_artifacts

      - name: Flatten Artifacts
        run: |
          mkdir -p dist
          find release_artifacts -type f -exec cp {} dist/ \;
          ls -la dist/

      - name: Generate Checksums
        run: |
          cd dist
          sha256sum * > SHA256SUMS.txt
          cat SHA256SUMS.txt

      - name: Create Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ needs.prepare-version.outputs.tag }}
          name: Release ${{ needs.prepare-version.outputs.tag }}
          files: dist/*
          generate_release_notes: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  sync-to-main:
    name: Sync Version Back to Main Branch
    needs: [prepare-version, publish-release]
    runs-on: ubuntu-latest
    steps:
      - name: Checkout main branch
        uses: actions/checkout@v4
        with:
          ref: main
          fetch-depth: 0

      - name: Update Cargo.toml on main
        run: |
          VERSION="${{ needs.prepare-version.outputs.version }}"
          echo "Updating cli/Cargo.toml on main to version $VERSION"
          sed -i -E "s/^version = \".*\"/version = \"$VERSION\"/" cli/Cargo.toml

          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"

          if ! git diff --quiet cli/Cargo.toml; then
            git add cli/Cargo.toml
            git commit -m "chore(release): bump version to $VERSION [skip ci]"
            git push origin main
            echo "Successfully updated version to $VERSION on main branch!"
          else
            echo "Version on main is already up to date."
          fi
````

## File: atuin/themes/theme.toml
````toml
# Auto-generated by Theme Engine for Atuin
[theme]
name = "theme"
parent = "default"

[colors]
AlertInfo = "#89b4fa"
AlertWarn = "#f9e2af"
AlertError = "#f38ba8"
Annotation = "#94e2d5"
Base = "#cdd6f4"
Guidance = "#a6e3a1"
Important = "#f5c2e7"
Title = "#89b4fa"
Muted = "#45475a"
SyntaxCommand = "#89b4fa"
SyntaxFlag = "#94e2d5"
SyntaxString = "#a6e3a1"
SyntaxVariable = "#f5c2e7"
SyntaxOperator = "#94e2d5"
SyntaxComment = "#45475a"
````

## File: cli/src/commands/update.rs
````rust
use anyhow::{bail, Result};
use owo_colors::OwoColorize;
use std::env;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

const CURRENT_VERSION: &str = env!("CARGO_PKG_VERSION");
const REPO: &str = "kachitaro/dotfiles";

pub fn execute() -> Result<()> {
    println!(
        "{}",
        format!("🔹 Đang kiểm tra và tải bản phát hành mới nhất từ GitHub ({}) ...", REPO).cyan()
    );
    println!("  Phiên bản hiện tại: {}", format!("v{}", CURRENT_VERSION).yellow());

    // 1. Xác định vị trí file thực thi hiện tại hoặc ~/.local/bin
    let current_exe = env::current_exe().ok();
    let home_bin = dirs::home_dir().map(|h| {
        #[cfg(windows)]
        { h.join(".local").join("bin").join("dot.exe") }
        #[cfg(unix)]
        { h.join(".local").join("bin").join("dot") }
    });

    let target_dest = if let Some(ref exe) = current_exe {
        if exe.exists() {
            exe.clone()
        } else if let Some(ref h_bin) = home_bin {
            h_bin.clone()
        } else {
            exe.clone()
        }
    } else if let Some(ref h_bin) = home_bin {
        h_bin.clone()
    } else {
        PathBuf::from(if cfg!(windows) { "dot.exe" } else { "dot" })
    };

    if let Some(parent) = target_dest.parent() {
        let _ = fs::create_dir_all(parent);
    }

    // 2. Tải và giải nén bản release tương ứng với OS/Arch
    #[cfg(windows)]
    {
        let url = format!(
            "https://github.com/{}/releases/latest/download/dot-x86_64-pc-windows-msvc.zip",
            REPO
        );
        let temp_dir = env::temp_dir().join("dot_update_extract");
        let temp_zip = env::temp_dir().join("dot_update.zip");

        if temp_dir.exists() {
            let _ = fs::remove_dir_all(&temp_dir);
        }
        if temp_zip.exists() {
            let _ = fs::remove_file(&temp_zip);
        }

        println!("  Đang tải: {}", url.dimmed());

        let ps_script = format!(
            r#"
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
            Invoke-WebRequest -Uri "{url}" -OutFile "{zip}" -UseBasicParsing -TimeoutSec 30
            Expand-Archive -Path "{zip}" -DestinationPath "{ext}" -Force
            "#,
            url = url,
            zip = temp_zip.display(),
            ext = temp_dir.display()
        );

        let status = Command::new("powershell")
            .args(["-NoProfile", "-Command", &ps_script])
            .status()?;

        if !status.success() || !temp_dir.exists() {
            bail!("Không thể tải hoặc giải nén release từ GitHub. Vui lòng kiểm tra kết nối mạng.");
        }

        // Tìm dot.exe đã giải nén
        let extracted_dot = find_extracted_binary(&temp_dir, "dot.exe")?;

        // Trên Windows, để ghi đè file .exe đang chạy, đổi tên file cũ trước
        let old_exe = target_dest.with_extension("exe.old");
        if target_dest.exists() {
            let _ = fs::remove_file(&old_exe);
            fs::rename(&target_dest, &old_exe).ok();
        }

        fs::copy(&extracted_dot, &target_dest)?;
        let _ = fs::remove_file(&old_exe);
        let _ = fs::remove_dir_all(&temp_dir);
        let _ = fs::remove_file(&temp_zip);

        // Đồng bộ thêm vào ~/.local/bin/dot.exe nếu target_dest nằm ở chỗ khác
        if let Some(ref h_bin) = home_bin {
            if h_bin != &target_dest {
                if let Some(p) = h_bin.parent() { let _ = fs::create_dir_all(p); }
                let _ = fs::copy(&target_dest, h_bin);
            }
        }
    }

    #[cfg(unix)]
    {
        let os = std::env::consts::OS;
        let arch = std::env::consts::ARCH;

        let target_triple = match (os, arch) {
            ("linux", "x86_64") => "x86_64-unknown-linux-gnu",
            ("linux", "aarch64") => "aarch64-unknown-linux-gnu",
            ("macos", "aarch64") => "aarch64-apple-darwin",
            ("macos", "x86_64") => "x86_64-apple-darwin",
            _ => bail!("Hệ điều hành hoặc kiến trúc chưa được hỗ trợ tự động: {}-{}", os, arch),
        };

        let url = format!(
            "https://github.com/{}/releases/latest/download/dot-{}.tar.gz",
            REPO, target_triple
        );
        let temp_dir = env::temp_dir().join("dot_update_extract");
        let _ = fs::create_dir_all(&temp_dir);

        println!("  Đang tải: {}", url.dimmed());

        let cmd = format!(
            "curl -fsSL \"{}\" | tar -xz -C \"{}\"",
            url,
            temp_dir.display()
        );

        let status = Command::new("sh").arg("-c").arg(&cmd).status()?;
        if !status.success() {
            bail!("Không thể tải hoặc giải nén release từ GitHub. Vui lòng kiểm tra kết nối mạng.");
        }

        let extracted_dot = find_extracted_binary(&temp_dir, "dot")?;

        fs::copy(&extracted_dot, &target_dest)?;
        let _ = Command::new("chmod").arg("+x").arg(&target_dest).status();
        let _ = fs::remove_dir_all(&temp_dir);

        if let Some(ref h_bin) = home_bin {
            if h_bin != &target_dest {
                if let Some(p) = h_bin.parent() { let _ = fs::create_dir_all(p); }
                let _ = fs::copy(&target_dest, h_bin);
                let _ = Command::new("chmod").arg("+x").arg(h_bin).status();
            }
        }
    }

    println!(
        "{}",
        format!("  ✅ Đã cập nhật binary 'dot' thành công tại: {}", target_dest.display()).green()
    );
    println!("\n{}", "🎉 Cập nhật CLI hoàn tất!".green().bold());

    Ok(())
}

fn find_extracted_binary(dir: &std::path::Path, bin_name: &str) -> Result<PathBuf> {
    if dir.is_dir() {
        for entry in fs::read_dir(dir)? {
            let entry = entry?;
            let path = entry.path();
            if path.is_file() && path.file_name().map(|n| n == bin_name).unwrap_or(false) {
                return Ok(path);
            }
            if path.is_dir() {
                if let Ok(found) = find_extracted_binary(&path, bin_name) {
                    return Ok(found);
                }
            }
        }
    }
    bail!("Không tìm thấy binary '{}' trong file nén release.", bin_name)
}
````

## File: cli/src/main.rs
````rust
#![allow(dead_code)]

use anyhow::Result;

use clap::{Parser, Subcommand};
use std::path::PathBuf;

mod commands;
mod linker;
mod paths;
mod theme_engine;

#[derive(Parser, Debug)]
#[command(
    name = "dot",
    about = "Kachitaro Dotfiles CLI",
    version
)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand, Debug)]
pub enum Commands {
    /// Run the installation script.
    Install {
        /// Overwrite existing configs
        #[arg(short, long)]
        force: bool,
    },
    /// Remove dotfiles symlinks and configurations.
    Uninstall,
    /// Adopt a new config folder into dotfiles.
    Add {
        /// Path to target config folder or file to adopt
        path: PathBuf,
    },
    /// Restore real files to your system (unlink).
    Eject,
    /// Re-link dotfiles symlinks and configurations into the system (re-sync).
    Inject {
        /// Force overwrite without backup
        #[arg(short, long)]
        force: bool,
    },
    /// Initialize a standalone dotfiles workspace.
    Init {
        /// Custom destination path for dotfiles directory (defaults to ~/.dotfiles)
        path: Option<PathBuf>,
        /// Overwrite existing default templates if already present
        #[arg(short, long)]
        force: bool,
    },
    /// Self-update dot binary to the latest version from GitHub Release.
    Update,
    /// Theme engine and configuration management.
    Theme {
        #[command(subcommand)]
        action: ThemeCommands,
    },
}

#[derive(Subcommand, Debug)]
pub enum ThemeCommands {
    /// Recompile theme.json and apply dynamically.
    Reload,
    /// Print absolute path of themes/generated/ directory.
    Path,
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Init { path, force } => commands::init::execute(path, force)?,
        Commands::Install { force } => commands::install::execute(force)?,
        Commands::Uninstall => commands::uninstall::execute()?,
        Commands::Update => commands::update::execute()?,
        Commands::Add { path } => commands::add::execute(path)?,
        Commands::Eject => commands::eject::execute()?,
        Commands::Inject { force } => commands::inject::execute(force)?,
        Commands::Theme { action } => match action {
            ThemeCommands::Reload => commands::theme::reload()?,
            ThemeCommands::Path => commands::theme::print_path()?,
        },
    }

    Ok(())
}
````

## File: cli/src/paths.rs
````rust
use anyhow::{Context, Result};
use std::env;
use std::path::{Path, PathBuf};

/// Environment variable to override dotfiles directory (useful for local dev/testing).
pub const DOTFILES_DIR_ENV: &str = "DOTFILES_DIR";

/// Check if a directory looks like the root of the dotfiles repository.
pub fn is_dotfiles_root(path: &Path) -> bool {
    path.join("themes").is_dir()
        && (path.join("scripts").is_dir()
            || path.join("bin").is_dir()
            || path.join(".git").exists()
            || path.join("dotfiles.md").exists()
            || path.join("themes").join("theme.json").exists())
}

/// Find the dotfiles root directory by traversing upwards from an executable or file path.
pub fn find_dotfiles_root_from(path: &Path) -> Result<PathBuf> {
    let mut current = if path.is_file() {
        path.parent().map(Path::to_path_buf).unwrap_or_else(|| path.to_path_buf())
    } else {
        path.to_path_buf()
    };

    loop {
        if is_dotfiles_root(&current) {
            return Ok(current);
        }
        if let Some(parent) = current.parent() {
            current = parent.to_path_buf();
        } else {
            break;
        }
    }

    anyhow::bail!(
        "Could not determine dotfiles root from path '{}'. Please set the {} environment variable.",
        path.display(),
        DOTFILES_DIR_ENV
    )
}

/// Strip Windows UNC verbatim prefix `\\?\` if present.
pub fn strip_unc_prefix(path: PathBuf) -> PathBuf {
    #[cfg(windows)]
    {
        let path_str = path.to_string_lossy();
        if let Some(stripped) = path_str.strip_prefix(r"\\?\UNC\") {
            return PathBuf::from(format!(r"\\{}", stripped));
        }
        if let Some(stripped) = path_str.strip_prefix(r"\\?\") {
            return PathBuf::from(stripped);
        }
    }
    path
}

/// Resolve dotfiles directory safely across platforms and symlinks.
/// 
/// 1. If DOTFILES_DIR environment variable is set and not empty, use it.
/// 2. Otherwise, get current_exe() and canonicalize() to trace any symlinks to the real binary,
///    then walk up to find the dotfiles repository root.
/// 3. Fallback: Check if ~/.dotfiles exists and is a valid dotfiles root.
pub fn resolve_dotfiles_dir() -> Result<PathBuf> {
    if let Ok(env_val) = env::var(DOTFILES_DIR_ENV) {
        let trimmed = env_val.trim();
        if !trimmed.is_empty() {
            let path = PathBuf::from(trimmed);
            if path.exists() {
                let canonical = path
                    .canonicalize()
                    .with_context(|| format!("Failed to canonicalize {}='{}'", DOTFILES_DIR_ENV, trimmed))?;
                return Ok(strip_unc_prefix(canonical));
            }
            return Ok(strip_unc_prefix(path));
        }
    }

    let current_exe = env::current_exe().context("Failed to get current executable path")?;
    let canonical_exe = current_exe
        .canonicalize()
        .context("Failed to canonicalize current executable path")?;

    if let Ok(root) = find_dotfiles_root_from(&canonical_exe) {
        return Ok(strip_unc_prefix(root));
    }

    // Fallback 1: Check current directory or ./dotfiles
    if let Ok(current) = env::current_dir() {
        if is_dotfiles_root(&current) {
            if let Ok(canonical) = current.canonicalize() {
                return Ok(strip_unc_prefix(canonical));
            }
            return Ok(current);
        }
        let current_subdir = current.join("dotfiles");
        if is_dotfiles_root(&current_subdir) {
            if let Ok(canonical) = current_subdir.canonicalize() {
                return Ok(strip_unc_prefix(canonical));
            }
            return Ok(current_subdir);
        }
    }

    // Fallback 2: Check default ~/.dotfiles
    if let Some(home) = dirs::home_dir() {
        let default_dotfiles = home.join(".dotfiles");
        if is_dotfiles_root(&default_dotfiles) || default_dotfiles.is_dir() {
            if let Ok(canonical) = default_dotfiles.canonicalize() {
                return Ok(strip_unc_prefix(canonical));
            }
            return Ok(default_dotfiles);
        }
    }

    anyhow::bail!(
        "Could not determine dotfiles root from path '{}'. Please run 'dot init' or set the {} environment variable.",
        canonical_exe.display(),
        DOTFILES_DIR_ENV
    )
}

/// Return absolute path to `<DOTFILES_DIR>/themes/generated`.
pub fn theme_generated_dir() -> Result<PathBuf> {
    let dotfiles_dir = resolve_dotfiles_dir()?;
    Ok(dotfiles_dir.join("themes").join("generated"))
}

#[derive(Debug, Clone)]
pub struct AppTarget {
    pub name: String,
    pub src: PathBuf,
    pub dest: PathBuf,
    pub is_dir: bool,
}

/// Dynamic auto-discovery of dotfiles packages (Stow-like dynamic scanning).
/// Automatically detects any configuration folder in the repository and maps it
/// to the proper OS destinations on Windows, macOS, and Linux.
pub fn discover_app_targets(dotfiles_dir: &Path) -> Vec<AppTarget> {
    let mut targets = Vec::new();
    let home_dir = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));

    let entries = match std::fs::read_dir(dotfiles_dir) {
        Ok(e) => e,
        Err(_) => return targets,
    };

    let ignored_names = [
        ".git",
        ".github",
        "target",
        "cli",
        "assets",
        "themes",
        "scripts",
        "bin",
        "scratch",
        "node_modules",
        "tests",
        ".system_generated",
    ];

    #[cfg(windows)]
    let config_dir = home_dir.join(".config");
    #[cfg(windows)]
    let local_appdata = dirs::data_local_dir().unwrap_or_else(|| home_dir.join("AppData").join("Local"));
    #[cfg(windows)]
    let roaming_appdata = dirs::config_dir().unwrap_or_else(|| home_dir.join("AppData").join("Roaming"));

    #[cfg(unix)]
    let config_dir = home_dir.join(".config");

    for entry in entries.flatten() {
        let path = entry.path();
        if !path.is_dir() {
            continue;
        }

        let folder_name = match path.file_name().and_then(|n| n.to_str()) {
            Some(n) => n,
            None => continue,
        };

        if ignored_names.contains(&folder_name) {
            continue;
        }

        #[cfg(windows)]
        {
            match folder_name {
                "nvim" => {
                    targets.push(AppTarget {
                        name: "nvim (LocalAppdata)".to_string(),
                        src: path.clone(),
                        dest: local_appdata.join("nvim"),
                        is_dir: true,
                    });
                    targets.push(AppTarget {
                        name: "nvim (.config)".to_string(),
                        src: path.clone(),
                        dest: config_dir.join("nvim"),
                        is_dir: true,
                    });
                }
                "bat" => {
                    targets.push(AppTarget {
                        name: "bat (AppData)".to_string(),
                        src: path.clone(),
                        dest: roaming_appdata.join("bat"),
                        is_dir: true,
                    });
                    targets.push(AppTarget {
                        name: "bat (.config)".to_string(),
                        src: path.clone(),
                        dest: config_dir.join("bat"),
                        is_dir: true,
                    });
                }
                "helix" => {
                    targets.push(AppTarget {
                        name: "helix (AppData)".to_string(),
                        src: path.clone(),
                        dest: roaming_appdata.join("helix"),
                        is_dir: true,
                    });
                    targets.push(AppTarget {
                        name: "helix (.config)".to_string(),
                        src: path.clone(),
                        dest: config_dir.join("helix"),
                        is_dir: true,
                    });
                }
                "wezterm" => {
                    targets.push(AppTarget {
                        name: "wezterm (.config)".to_string(),
                        src: path.clone(),
                        dest: config_dir.join("wezterm"),
                        is_dir: true,
                    });
                    let wz_lua = path.join("wezterm.lua");
                    if wz_lua.exists() {
                        targets.push(AppTarget {
                            name: "wezterm.lua (~/.wezterm.lua)".to_string(),
                            src: wz_lua,
                            dest: home_dir.join(".wezterm.lua"),
                            is_dir: false,
                        });
                    }
                }
                "shell" => {
                    // Shell profile scripts (bash/zsh) are injected directly into .bashrc / .zshrc
                }
                _ => {
                    // Mọi thư mục khác (starship, atuin, carapace, powershell, scoop, git, lazygit, tmux, yazi...)
                    // Tự động map vào ~/.config/<folder_name>
                    targets.push(AppTarget {
                        name: folder_name.to_string(),
                        src: path.clone(),
                        dest: config_dir.join(folder_name),
                        is_dir: true,
                    });
                }
            }
        }

        #[cfg(unix)]
        {
            match folder_name {
                "wezterm" => {
                    targets.push(AppTarget {
                        name: "wezterm (.config)".to_string(),
                        src: path.clone(),
                        dest: config_dir.join("wezterm"),
                        is_dir: true,
                    });
                    let wz_lua = path.join("wezterm.lua");
                    if wz_lua.exists() {
                        targets.push(AppTarget {
                            name: "wezterm.lua (~/.wezterm.lua)".to_string(),
                            src: wz_lua,
                            dest: home_dir.join(".wezterm.lua"),
                            is_dir: false,
                        });
                    }
                }
                "shell" => {
                    // Handled by shell profile injector
                }
                _ => {
                    targets.push(AppTarget {
                        name: folder_name.to_string(),
                        src: path.clone(),
                        dest: config_dir.join(folder_name),
                        is_dir: true,
                    });
                }
            }
        }
    }

    #[cfg(unix)]
    {
        // Link CLI binary if built
        let local_bin = home_dir.join(".local").join("bin");
        let cli_bin = dotfiles_dir.join("cli").join("target").join("release").join("dot");
        if cli_bin.exists() {
            targets.push(AppTarget {
                name: "dot (CLI binary)".to_string(),
                src: cli_bin,
                dest: local_bin.join("dot"),
                is_dir: false,
            });
        }
    }

    targets
}



#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::tempdir;

    fn setup_fake_dotfiles_repo() -> tempfile::TempDir {
        let dir = tempdir().expect("Failed to create tempdir");
        let root = dir.path();
        fs::create_dir_all(root.join("themes").join("generated")).unwrap();
        fs::create_dir_all(root.join("bin")).unwrap();
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::create_dir_all(root.join("target").join("release")).unwrap();
        fs::write(root.join("bin").join("dot"), b"fake binary").unwrap();
        fs::write(root.join("target").join("release").join("dot"), b"fake binary").unwrap();
        dir
    }

    fn get_canonical_root(temp_dir: &tempfile::TempDir) -> PathBuf {
        strip_unc_prefix(temp_dir.path().canonicalize().unwrap())
    }

    #[test]
    fn test_resolve_from_direct_path() {
        let fake_repo = setup_fake_dotfiles_repo();
        let canonical_root = get_canonical_root(&fake_repo);

        // 1. From <root>/bin/dot
        let bin_path = canonical_root.join("bin").join("dot");
        let resolved = find_dotfiles_root_from(&bin_path).expect("Failed to resolve from bin/dot");
        assert_eq!(strip_unc_prefix(resolved), canonical_root);

        // 2. From <root>/target/release/dot
        let release_path = canonical_root.join("target").join("release").join("dot");
        let resolved = find_dotfiles_root_from(&release_path).expect("Failed to resolve from target/release/dot");
        assert_eq!(strip_unc_prefix(resolved), canonical_root);
    }

    #[test]
    fn test_resolve_from_symlink() {
        let fake_repo = setup_fake_dotfiles_repo();
        let canonical_root = get_canonical_root(&fake_repo);
        let real_bin = canonical_root.join("bin").join("dot");

        let outside_dir = tempdir().expect("Failed to create outside tempdir");
        let symlink_path = outside_dir.path().join("dot_symlink");

        #[cfg(unix)]
        let symlink_created = std::os::unix::fs::symlink(&real_bin, &symlink_path).is_ok();

        #[cfg(windows)]
        let symlink_created = std::os::windows::fs::symlink_file(&real_bin, &symlink_path).is_ok();

        if symlink_created {
            let canonical_exe = symlink_path.canonicalize().expect("Failed to canonicalize symlink");
            let resolved = find_dotfiles_root_from(&canonical_exe).expect("Failed to resolve from symlinked executable");
            assert_eq!(strip_unc_prefix(resolved), canonical_root);
        }
    }

    #[test]
    fn test_theme_generated_dir_structure() {
        let fake_repo = setup_fake_dotfiles_repo();
        let canonical_root = get_canonical_root(&fake_repo);
        let expected = canonical_root.join("themes").join("generated");

        let generated = canonical_root.join("themes").join("generated");
        assert_eq!(generated, expected);
        assert!(generated.exists());
    }

    #[test]
    fn test_env_override() {
        let fake_repo = setup_fake_dotfiles_repo();
        let canonical_root = get_canonical_root(&fake_repo);

        // Set DOTFILES_DIR
        unsafe {
            env::set_var(DOTFILES_DIR_ENV, canonical_root.to_str().unwrap());
        }
        let resolved = resolve_dotfiles_dir().expect("Failed to resolve from env");
        assert_eq!(resolved, canonical_root);

        // Clean up env
        unsafe {
            env::remove_var(DOTFILES_DIR_ENV);
        }
    }

    #[test]
    fn test_discover_app_targets_dynamic() {
        let fake_repo = setup_fake_dotfiles_repo();
        let root = fake_repo.path();

        // Create sample configs in fake repo
        fs::create_dir_all(root.join("bat")).unwrap();
        fs::create_dir_all(root.join("starship")).unwrap();
        fs::create_dir_all(root.join("custom_app")).unwrap();

        let targets = discover_app_targets(root);
        let names: Vec<String> = targets.iter().map(|t| t.name.clone()).collect();

        assert!(names.iter().any(|n| n.contains("bat")));
        assert!(names.iter().any(|n| n.contains("starship")));
        assert!(names.iter().any(|n| n == "custom_app"));
    }
}
````

## File: cli/src/theme_engine.rs
````rust
use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::fs;
use std::path::Path;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct ThemeData {
    #[serde(default = "default_theme_name")]
    pub name: String,
    pub bg: String,
    pub fg: String,
    pub black: String,
    pub red: String,
    pub green: String,
    pub yellow: String,
    pub blue: String,
    pub magenta: String,
    pub cyan: String,
    pub white: String,
    #[serde(flatten)]
    pub extra: BTreeMap<String, serde_json::Value>,
}

fn default_theme_name() -> String {
    "Custom".to_string()
}

impl ThemeData {
    /// Return the list of color key-value pairs in standard order.
    pub fn colors(&self) -> Vec<(&str, &str)> {
        let mut list = vec![
            ("bg", self.bg.as_str()),
            ("fg", self.fg.as_str()),
            ("black", self.black.as_str()),
            ("red", self.red.as_str()),
            ("green", self.green.as_str()),
            ("yellow", self.yellow.as_str()),
            ("blue", self.blue.as_str()),
            ("magenta", self.magenta.as_str()),
            ("cyan", self.cyan.as_str()),
            ("white", self.white.as_str()),
        ];
        for (k, v) in &self.extra {
            if let Some(s) = v.as_str() {
                list.push((k.as_str(), s));
            }
        }
        list
    }
}

pub fn generate_lua(theme: &ThemeData) -> String {
    let mut out = String::from("-- Auto-generated by Theme Engine\nreturn {\n");
    for (key, value) in theme.colors() {
        out.push_str(&format!("  {} = \"{}\",\n", key, value));
    }
    out.push_str("}\n");
    out
}

pub fn generate_sh(theme: &ThemeData) -> String {
    let mut out = String::from("# Auto-generated by Theme Engine\n");
    out.push_str(&format!("export THEME_NAME=\"{}\"\n", theme.name));
    out.push_str(&format!("export BAT_THEME=\"{}\"\n", theme.name));
    for (key, value) in theme.colors() {
        out.push_str(&format!("export THEME_{}=\"{}\"\n", key.to_uppercase(), value));
    }
    out
}

pub fn generate_ps1(theme: &ThemeData) -> String {
    let mut out = String::from("# Auto-generated by Theme Engine\n");
    out.push_str(&format!("$env:THEME_NAME=\"{}\"\n", theme.name));
    out.push_str(&format!("$env:BAT_THEME=\"{}\"\n", theme.name));
    for (key, value) in theme.colors() {
        out.push_str(&format!("$env:THEME_{}=\"{}\"\n", key.to_uppercase(), value));
    }
    out
}

pub fn update_bat_config(dotfiles_dir: &Path, theme: &ThemeData) -> Result<()> {
    let bat_config_path = dotfiles_dir.join("bat").join("config");
    if !bat_config_path.exists() {
        if let Some(parent) = bat_config_path.parent() {
            let _ = fs::create_dir_all(parent);
        }
    }

    let content = if bat_config_path.exists() {
        fs::read_to_string(&bat_config_path).unwrap_or_default()
    } else {
        String::new()
    };

    let theme_line = format!("--theme=\"{}\"", theme.name);

    let new_content = if content.contains("--theme=") {
        content
            .lines()
            .map(|line| {
                if line.trim().starts_with("--theme=") {
                    theme_line.clone()
                } else {
                    line.to_string()
                }
            })
            .collect::<Vec<_>>()
            .join("\n")
    } else {
        format!("{}\n\n{}", theme_line, content)
    };

    fs::write(&bat_config_path, format!("{}\n", new_content.trim()))
        .with_context(|| format!("Không thể ghi tệp: {}", bat_config_path.display()))?;

    Ok(())
}

pub fn generate_atuin_theme(theme: &ThemeData) -> String {
    format!(
r#"# Auto-generated by Theme Engine for Atuin
[theme]
name = "theme"
parent = "default"

[colors]
AlertInfo = "{blue}"
AlertWarn = "{yellow}"
AlertError = "{red}"
Annotation = "{cyan}"
Base = "{fg}"
Guidance = "{green}"
Important = "{magenta}"
Title = "{blue}"
Muted = "{black}"
SyntaxCommand = "{blue}"
SyntaxFlag = "{cyan}"
SyntaxString = "{green}"
SyntaxVariable = "{magenta}"
SyntaxOperator = "{cyan}"
SyntaxComment = "{black}"
"#,
        blue = theme.blue,
        yellow = theme.yellow,
        red = theme.red,
        cyan = theme.cyan,
        fg = theme.fg,
        green = theme.green,
        magenta = theme.magenta,
        black = theme.black
    )
}

pub fn generate_starship_palette(theme: &ThemeData) -> String {
    format!(
r#"[palettes.theme]
bg = "{bg}"
fg = "{fg}"
black = "{black}"
red = "{red}"
green = "{green}"
yellow = "{yellow}"
blue = "{blue}"
magenta = "{magenta}"
cyan = "{cyan}"
white = "{white}"
peach = "{yellow}"
sapphire = "{blue}"
lavender = "{magenta}"
text = "{fg}"
base = "{bg}"
mantle = "{bg}"
crust = "{bg}"
surface0 = "{black}"
overlay0 = "{white}"
"#,
        bg = theme.bg,
        fg = theme.fg,
        black = theme.black,
        red = theme.red,
        green = theme.green,
        yellow = theme.yellow,
        blue = theme.blue,
        magenta = theme.magenta,
        cyan = theme.cyan,
        white = theme.white,
    )
}

pub fn update_starship_config(dotfiles_dir: &Path, theme: &ThemeData) -> Result<()> {
    let starship_path = dotfiles_dir.join("starship").join("starship.toml");
    if !starship_path.exists() {
        return Ok(());
    }

    let content = fs::read_to_string(&starship_path)
        .with_context(|| format!("Không thể đọc tệp: {}", starship_path.display()))?;

    // Find where [palettes begins or keep config before [palettes
    let base_content = if let Some(idx) = content.find("[palettes") {
        content[..idx].trim_end().to_string()
    } else {
        content.trim_end().to_string()
    };

    // Ensure palette = 'theme' is set
    let updated_base = if let Some(pos) = base_content.find("palette =") {
        let line_end = base_content[pos..].find('\n').map(|p| pos + p).unwrap_or(base_content.len());
        format!("{}palette = 'theme'{}", &base_content[..pos], &base_content[line_end..])
    } else {
        base_content
    };

    let palette_section = generate_starship_palette(theme);
    let new_content = format!("{}\n\n{}\n", updated_base.trim(), palette_section.trim());

    fs::write(&starship_path, new_content)
        .with_context(|| format!("Không thể ghi tệp: {}", starship_path.display()))?;

    Ok(())
}

/// Parses theme.json and directly generates destination config files:
/// - themes/generated/theme.lua (Neovim, WezTerm)
/// - themes/generated/theme.sh (Bash, Zsh)
/// - themes/generated/theme.ps1 (PowerShell)
/// - atuin/themes/theme.toml (Atuin)
/// - starship/starship.toml (Starship Prompt palette)
pub fn generate_themes(dotfiles_dir: &Path) -> Result<ThemeData> {
    let theme_json_path = dotfiles_dir.join("themes").join("theme.json");
    let content = fs::read_to_string(&theme_json_path)
        .with_context(|| format!("Không thể đọc tệp theme: {}", theme_json_path.display()))?;

    let theme_data: ThemeData = serde_json::from_str(&content)
        .with_context(|| format!("Lỗi phân tích JSON từ: {}", theme_json_path.display()))?;

    let out_dir = dotfiles_dir.join("themes").join("generated");
    let atuin_themes_dir = dotfiles_dir.join("atuin").join("themes");

    fs::create_dir_all(&out_dir)
        .with_context(|| format!("Không thể tạo thư mục: {}", out_dir.display()))?;
    fs::create_dir_all(&atuin_themes_dir)
        .with_context(|| format!("Không thể tạo thư mục: {}", atuin_themes_dir.display()))?;

    fs::write(out_dir.join("theme.lua"), generate_lua(&theme_data))
        .with_context(|| "Không thể ghi tệp theme.lua")?;
    fs::write(out_dir.join("theme.sh"), generate_sh(&theme_data))
        .with_context(|| "Không thể ghi tệp theme.sh")?;
    fs::write(out_dir.join("theme.ps1"), generate_ps1(&theme_data))
        .with_context(|| "Không thể ghi tệp theme.ps1")?;

    fs::write(
        atuin_themes_dir.join("theme.toml"),
        generate_atuin_theme(&theme_data),
    )
    .with_context(|| "Không thể ghi tệp atuin theme.toml")?;

    // Synchronize Starship prompt palette
    let _ = update_starship_config(dotfiles_dir, &theme_data);

    // Synchronize Bat theme
    let _ = update_bat_config(dotfiles_dir, &theme_data);

    Ok(theme_data)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample_theme() -> ThemeData {
        serde_json::from_str(r##"{
            "name": "Catppuccin Mocha",
            "bg": "#1e1e2e",
            "fg": "#cdd6f4",
            "black": "#45475a",
            "red": "#f38ba8",
            "green": "#a6e3a1",
            "yellow": "#f9e2af",
            "blue": "#89b4fa",
            "magenta": "#f5c2e7",
            "cyan": "#94e2d5",
            "white": "#bac2de"
        }"##).unwrap()
    }

    #[test]
    fn test_theme_generation_output() {
        let theme = sample_theme();

        let lua = generate_lua(&theme);
        assert!(lua.contains("bg = \"#1e1e2e\","));
        assert!(lua.contains("fg = \"#cdd6f4\","));

        let sh = generate_sh(&theme);
        assert!(sh.contains("export THEME_BG=\"#1e1e2e\""));

        let ps1 = generate_ps1(&theme);
        assert!(ps1.contains("$env:THEME_BG=\"#1e1e2e\""));

        let atuin = generate_atuin_theme(&theme);
        assert!(atuin.contains("AlertInfo = \"#89b4fa\""));

        let starship = generate_starship_palette(&theme);
        assert!(starship.contains("[palettes.theme]"));
        assert!(starship.contains("bg = \"#1e1e2e\""));
    }
}
````

## File: starship/starship.toml
````toml
"$schema" = 'https://starship.rs/config-schema.json'

palette = 'theme'
add_newline = false

format = """
$directory\
$git_branch\
$git_status\
$character"""

right_format = """
$c\
$rust\
$golang\
$nodejs\
$bun\
$php\
$java\
$kotlin\
$haskell\
$python\
$conda\
$time"""

[directory]
style = "peach"
format = "[$path ]($style)"
truncation_length = 3

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = "󰝚 "
"Pictures" = " "
"Developer" = "󰲋 "

[git_branch]
symbol = ""
style = "yellow"
format = '[$symbol $branch ]($style)'

[git_status]
style = "yellow"
format = '([$all_status$ahead_behind ]($style))'

[nodejs]
symbol = ""
style = "green"
format = '[$symbol( $version) ]($style)'

[bun]
symbol = ""
style = "green"
format = '[$symbol( $version) ]($style)'

[c]
symbol = ""
style = "green"
format = '[$symbol( $version) ]($style)'

[rust]
symbol = ""
style = "green"
format = '[$symbol( $version) ]($style)'

[golang]
symbol = ""
style = "green"
format = '[$symbol( $version) ]($style)'

[php]
symbol = ""
style = "green"
format = '[$symbol( $version) ]($style)'

[java]
symbol = ""
style = "green"
format = '[$symbol( $version) ]($style)'

[kotlin]
symbol = ""
style = "green"
format = '[$symbol( $version) ]($style)'

[haskell]
symbol = ""
style = "green"
format = '[$symbol( $version) ]($style)'

[python]
symbol = ""
style = "green"
format = '[$symbol( $version)(\(#$virtualenv\)) ]($style)'

[docker_context]
symbol = ""
style = "sapphire"
format = '[$symbol( $context) ]($style)'

[conda]
symbol = ""
style = "sapphire"
format = '[ $symbol $environment ]($style)'
ignore_base = false

[time]
disabled = false
time_format = "%R"
style = "lavender"
format = '[ $time ]($style)'

[character]
disabled = false
success_symbol = '[➜](bold green)'
error_symbol = '[➜](bold red)'
vimcmd_symbol = '[⬅](bold green)'
vimcmd_replace_one_symbol = '[⬅](bold lavender)'
vimcmd_replace_symbol = '[⬅](bold lavender)'
vimcmd_visual_symbol = '[⬅](bold yellow)'

[palettes.theme]
bg = "#1e1e2e"
fg = "#cdd6f4"
black = "#45475a"
red = "#f38ba8"
green = "#a6e3a1"
yellow = "#f9e2af"
blue = "#89b4fa"
magenta = "#f5c2e7"
cyan = "#94e2d5"
white = "#bac2de"
peach = "#f9e2af"
sapphire = "#89b4fa"
lavender = "#f5c2e7"
text = "#cdd6f4"
base = "#1e1e2e"
mantle = "#1e1e2e"
crust = "#1e1e2e"
surface0 = "#45475a"
overlay0 = "#bac2de"
````

## File: wezterm/core.lua
````lua
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
````

## File: cli/src/commands/uninstall.rs
````rust
use anyhow::Result;
use owo_colors::OwoColorize;
use std::fs;
use std::path::{Path, PathBuf};

use crate::linker::{is_symlink, remove_symlink};
use crate::paths;

pub fn execute() -> Result<()> {
    println!(
        "{}",
        "Bắt đầu gỡ cài đặt (Uninstall) Dotfiles...".red()
    );
    println!("{}", "Xóa các symlink cấu hình...".cyan());

    let home_dir = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));
    let dotfiles_dir = paths::resolve_dotfiles_dir().unwrap_or_else(|_| home_dir.join(".dotfiles"));
    let targets = paths::discover_app_targets(&dotfiles_dir);

    for target in targets {
        if is_symlink(&target.dest) {
            let _ = remove_symlink(&target.dest, target.is_dir);
            println!(
                "{}",
                format!("  Đã xóa: {}", target.dest.display()).green()
            );
        }
    }

    #[cfg(windows)]
    {
        // Clean PowerShell profile scripts
        clean_powershell_profiles(&home_dir)?;
    }

    #[cfg(unix)]
    {
        // Clean shell profiles
        clean_unix_shell_profiles(&home_dir)?;
    }

    println!(
        "\n{}",
        "Hoàn tất gỡ cài đặt! Các file gốc/backup (.bak_*) của bạn vẫn được giữ nguyên.".green()
    );

    Ok(())
}

#[cfg(windows)]
fn clean_powershell_profiles(home_dir: &Path) -> Result<()> {
    println!("{}", "Gỡ cấu hình khỏi PowerShell Profile...".cyan());

    let doc_dir = dirs::document_dir().unwrap_or_else(|| home_dir.join("Documents"));
    let candidate_profiles = [
        doc_dir.join("PowerShell").join("Microsoft.PowerShell_profile.ps1"),
        doc_dir.join("PowerShell").join("profile.ps1"),
        doc_dir.join("WindowsPowerShell").join("Microsoft.PowerShell_profile.ps1"),
        doc_dir.join("WindowsPowerShell").join("profile.ps1"),
        home_dir.join("Documents").join("PowerShell").join("Microsoft.PowerShell_profile.ps1"),
        home_dir.join("Documents").join("WindowsPowerShell").join("Microsoft.PowerShell_profile.ps1"),
    ];

    for profile in candidate_profiles {
        if profile.is_file() {
            if let Ok(content) = fs::read_to_string(&profile) {
                let cleaned_lines: Vec<&str> = content
                    .lines()
                    .filter(|line| {
                        !line.contains("# Load dotfiles user profile")
                            && !line.contains("user_profile.ps1")
                    })
                    .collect();
                let new_content = cleaned_lines.join("\r\n");
                if new_content != content {
                    fs::write(&profile, new_content)?;
                    println!(
                        "{}",
                        format!("  Đã gỡ cấu hình khỏi: {}", profile.display()).green()
                    );
                }
            }
        }
    }

    Ok(())
}

#[cfg(unix)]
fn clean_unix_shell_profiles(home_dir: &Path) -> Result<()> {
    println!("{}", "Gỡ bỏ cấu hình dotfiles khỏi shell profile...".cyan());

    let shell_profiles = [
        home_dir.join(".bashrc"),
        home_dir.join(".zshrc"),
        home_dir.join(".config").join("powershell").join("Microsoft.PowerShell_profile.ps1"),
    ];

    for profile in shell_profiles {
        if profile.is_file() {
            if let Ok(content) = fs::read_to_string(&profile) {
                let cleaned_lines: Vec<&str> = content
                    .lines()
                    .filter(|line| {
                        !line.contains("# Load dotfiles config")
                            && !line.contains("dotfiles/shell/.bashrc")
                            && !line.contains("dotfiles/shell/.zshrc")
                            && !line.contains("user_profile.ps1")
                    })
                    .collect();
                let new_content = cleaned_lines.join("\n");
                if new_content != content {
                    fs::write(&profile, new_content)?;
                    println!(
                        "{}",
                        format!("  Đã gỡ cấu hình khỏi: {}", profile.display()).green()
                    );
                }
            }
        }
    }

    Ok(())
}
````

## File: cli/Cargo.toml
````toml
[package]
name = "k-dot"
version = "0.0.2"
edition = "2024"
description = "Cross-platform CLI manager for Kachitaro Dotfiles"

[[bin]]
name = "dot"
path = "src/main.rs"


[dependencies]
clap = { version = "4.5", features = ["derive"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
owo-colors = "4.1"
dirs = "5.0"
anyhow = "1.0"

[dev-dependencies]
tempfile = "3.14"
````

## File: nvim/init.lua
````lua
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
````

## File: wezterm/ui.lua
````lua
local wezterm = require 'wezterm'
local module = {}

local function get_theme_path()
  -- 0. Resolve dynamically via `dot theme path` (or `k-dot theme path`)
  local ok, dynamic_path = pcall(function()
    local success, out, _ = wezterm.run_child_process({ "dot", "theme", "path" })
    if success and out and out ~= "" then
      return out:gsub("[\r\n]+$", "") .. "/theme.lua"
    end
    local k_success, k_out, _ = wezterm.run_child_process({ "k-dot", "theme", "path" })
    if k_success and k_out and k_out ~= "" then
      return k_out:gsub("[\r\n]+$", "") .. "/theme.lua"
    end
    return nil
  end)

  if ok and dynamic_path then
    local f = io.open(dynamic_path, "r")
    if f then
      f:close()
      return dynamic_path
    end
  end

  local candidates = {}

  -- 1. Check DOTFILES_DIR environment variable
  local dotfiles_dir = os.getenv("DOTFILES_DIR")
  if dotfiles_dir and dotfiles_dir ~= "" then
    table.insert(candidates, dotfiles_dir .. "/themes/generated/theme.lua")
  end

  -- 2. Resolve via wezterm.config_dir
  if wezterm.config_dir then
    table.insert(candidates, wezterm.config_dir .. "/../themes/generated/theme.lua")
    table.insert(candidates, wezterm.config_dir .. "/themes/generated/theme.lua")
  end

  -- 3. Resolve via wezterm.config_file (if available)
  if wezterm.config_file then
    local config_dir = wezterm.config_file:match("^(.*)[/\\]")
    if config_dir then
      table.insert(candidates, config_dir .. "/../themes/generated/theme.lua")
    end
  end

  -- 4. Fallback paths (home directory & legacy path)
  local home = os.getenv("HOME") or os.getenv("USERPROFILE") or (wezterm.home_dir or "")
  if home ~= "" then
    table.insert(candidates, home .. "/.dotfiles/themes/generated/theme.lua")
    table.insert(candidates, home .. "/Desktop/Work/dotfiles/themes/generated/theme.lua")
  end

  for _, path in ipairs(candidates) do
    local f = io.open(path, "r")
    if f then
      f:close()
      return path
    end
  end

  if wezterm.config_dir then
    return wezterm.config_dir .. "/../themes/generated/theme.lua"
  end
  return home .. "/Desktop/Work/dotfiles/themes/generated/theme.lua"
end


function module.setup(config)
  config.tab_bar_at_bottom = true
  config.status_update_interval = 100
  config.use_fancy_tab_bar = false
  -- config.hide_tab_bar_if_only_one_tab = true
  config.scrollback_lines = 10000
  config.adjust_window_size_when_changing_font_size = false
  -- Load dynamically generated theme
  local theme_path = get_theme_path()
  local success, theme = pcall(dofile, theme_path)

  if success and type(theme) == "table" then
    config.colors = {
      background = theme.bg,
      foreground = theme.fg,
      ansi = { theme.black, theme.red, theme.green, theme.yellow, theme.blue, theme.magenta, theme.cyan, theme.white },
      brights = { theme.black, theme.red, theme.green, theme.yellow, theme.blue, theme.magenta, theme.cyan, theme.white },
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
end

return module
````

## File: README.vi.md
````markdown
# 🛠️ Bộ Dotfiles & Môi trường phát triển Đa nền tảng

![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/anhtai2k)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)

🌐 **Ngôn ngữ**: [English](README.md) | **Tiếng Việt**

Bộ dotfiles cá nhân được tối ưu hoá cho **PowerShell 7**, **Bash / Zsh**, các công cụ dòng lệnh hiện đại, **WezTerm** GPU terminal emulator, và **Neovim (NvChad)** IDE, được quản lý toàn diện bởi công cụ CLI viết bằng Rust (`k-dot` / `dot`) & **Theme Engine**.

Thiết lập lại toàn bộ môi trường lập trình của bạn trên **Windows 11/10** và **Linux / WSL / macOS** chỉ bằng 1 dòng lệnh duy nhất.

---

## 📸 Hình ảnh giao diện

![Xem trước Terminal & Neovim](assets/showcase.png)

## 📑 Mục lục

- [📸 Hình ảnh giao diện](#-hình-ảnh-giao-diện)
- [🚀 Hướng dẫn cài đặt](#-hướng-dẫn-cài-đặt)
- [🧰 Quản lý bằng CLI `dot`](#-quản-lý-bằng-cli-dot-rust)
- [🎨 Theme Engine (Đồng bộ màu sắc)](#-theme-engine-đồng-bộ-màu-sắc)
- [⌨️ Phím tắt & Tiện ích](#️-phím-tắt--tiện-ích)
- [☕ Ủng hộ / Donate](#-ủng-hộ--donate)
- [📜 Giấy phép](#-giấy-phép)

---

## 🚀 Hướng dẫn cài đặt

### 1. Windows (PowerShell)

Mở **PowerShell** (Khuyến khích Run as Administrator nếu cài đặt toàn diện) và chạy:

```powershell
# ⚡ Cài đặt nhanh: Tự động tải binary dot release & gắn symlink cấu hình ngay lập tức
irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex

# 🚀 Cài đặt máy mới toàn diện: Tự động cài Scoop, Neovim, WezTerm, Font, Node, Tools & ảo hoá
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1))) -Full
```

### 2. Linux / macOS

Mở **Terminal** và chạy:

```bash
# ⚡ Cài đặt nhanh: Tự động tải binary dot release & gắn symlink cấu hình ngay lập tức
curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash

# 🚀 Cài đặt máy mới toàn diện: Tự động cài package hệ thống (apt/brew/pacman), Neovim, WezTerm, Font, Tools
curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash -s -- --full
```

### 3. Chạy trực tiếp từ repo đã clone

```bash
# Windows
.\install.ps1        # hoặc .\install.ps1 -Full

# Linux/macOS
./install.sh         # hoặc ./install.sh --full
```

> [!IMPORTANT]
> Sau khi cài trên Windows, **khởi động lại máy** để áp dụng Hyper-V, WSL và font. Trên Linux/macOS, chạy `source ~/.bashrc` hoặc mở tab terminal mới.

### 4. Cài đè & gỡ cài đặt

| Thao tác                                           | Windows                       | Linux/macOS              |
| :------------------------------------------------- | :---------------------------- | :----------------------- |
| Cài đè, bỏ qua sao lưu                             | `.\install.ps1 -ForceInstall` | `./install.sh --force`   |
| Gỡ cài đặt (xoá symlink, khôi phục môi trường gốc) | `dot uninstall`               | `dot uninstall`          |

---

## 🧰 Quản lý bằng CLI `dot` (Rust)

Công cụ dòng lệnh quản lý (`k-dot` / `dot`) được viết hoàn toàn bằng **Rust** cho tốc độ khởi động siêu nhanh, xử lý đường dẫn / symlink an toàn và không phụ thuộc runtime bên ngoài.

```bash
dot init [path]                  # Khởi tạo kho dotfiles độc lập (mặc định ~/.dotfiles) kèm theme.json mẫu
dot install                      # Chạy script cài đặt hệ thống (Tùy chọn: --force / -ForceInstall)
dot update                       # Tự động cập nhật CLI binary (dot) lên phiên bản mới nhất từ GitHub Release
dot add <path>                   # Thu nạp một config từ ~/.config vào kho (vd: dot add ~/.config/alacritty)
dot eject                        # Gỡ symlink, trả file thực về máy (hoạt động độc lập)
dot inject                       # Đồng bộ / gắn lại symlink và nạp cấu hình dotfiles vào hệ thống (Tùy chọn: --force)
dot uninstall                    # Gỡ cài đặt hoàn toàn
dot theme reload                 # Biên dịch và áp dụng theme mới từ theme.json
dot theme path                   # In ra đường dẫn tuyệt đối của themes/generated (để script lấy path động)
dot --help                       # Hiển thị menu trợ giúp
```

### 🦀 Tự biên dịch CLI từ mã nguồn (Build from source)

Để tự biên dịch binary CLI:

```bash
cd cli
cargo build --release
```

#### Các lệnh build mẫu cho từng nền tảng (Cross-compilation):
- **Windows (MSVC)**: `cargo build --release --target x86_64-pc-windows-msvc`
- **Linux (x86_64)**: `cargo build --release --target x86_64-unknown-linux-gnu`
- **macOS (Apple Silicon)**: `cargo build --release --target aarch64-apple-darwin`

---

## 🎨 Theme Engine (Đồng bộ màu sắc)

Toàn bộ màu sắc của Neovim, WezTerm, Starship, Bash, Zsh và PowerShell được đồng bộ từ **một nguồn sự thật duy nhất**: `themes/theme.json`.

1. Sửa màu trong `themes/theme.json`.
2. Chạy `dot theme reload`.
3. Rust Theme Engine tự động biên dịch JSON trực tiếp ra:
   - `themes/generated/theme.lua` (WezTerm & Neovim)
   - `themes/generated/theme.sh` (Bash & Zsh)
   - `themes/generated/theme.ps1` (PowerShell)
   - `atuin/themes/theme.toml` (Atuin Shell History)
4. WezTerm, Neovim và Shell tự động nhận diện vị trí dotfiles động và áp dụng màu mới ngay lập tức.

Theme mặc định hiện tại: **Catppuccin Mocha**.

---

## ⌨️ Phím tắt & Tiện ích

### WezTerm

| Phím tắt            | Thao tác                       |
| :------------------ | :----------------------------- |
| `Ctrl + Shift + \|` | Chia màn hình theo chiều dọc   |
| `Ctrl + Shift + D`  | Chia màn hình theo chiều ngang |

### Core Shell & Shell Tools

| Phím tắt / Lệnh        | Mô tả                                                                            |
| :--------------------- | :------------------------------------------------------------------------------- |
| `Ctrl + R`             | **Atuin** tìm kiếm lịch sử lệnh tương tác (kèm thời lượng chạy, exit code, ngày) |
| `Ctrl + F`             | **PSFzf / FZF** tìm kiếm tệp và thư mục siêu nhanh                               |
| `Tab`                  | **Carapace** menu auto-complete trực quan đa shell                               |
| `z <thư_mục>`          | **Zoxide** nhảy nhanh đến thư mục thường xuyên sử dụng                           |
| `g`                    | Phím tắt nhanh cho `git`                                                         |
| `ls`, `ll`, `la`, `lt` | **Eza** liệt kê tệp hiện đại (kèm icon, trạng thái git, cây thư mục)             |
| `cat <tệp>`            | **Bat** xem nội dung tệp có highlight cú pháp và số dòng                         |
| `Get-SystemSizeReport` | *(PowerShell)* Báo cáo chi tiết dung lượng các thư mục dev, node_modules và cache |

---

## ☕ Ủng hộ / Donate

Nếu bạn thấy bộ dotfiles này hữu ích, hãy ủng hộ tác giả qua:

- **Ko-fi**: [ko-fi.com/anhtai2k](https://ko-fi.com/anhtai2k)
- **Star repo**: ⭐ Hãy thả 1 sao trên GitHub nhé!

---

## 📜 Giấy phép

Phát hành dưới **Giấy phép MIT**. Xem tệp `LICENSE` để biết thêm chi tiết.
````

## File: install.sh
````bash
#!/usr/bin/env bash
# ==============================================================================
# 🚀 Linux / macOS Dotfiles & Dev Environment Installer
# Usage:
#   # ⚡ Fast Install: Tải CLI dot và gắn cấu hình ngay
#   curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash
#
#   # 🚀 Full Machine Setup: Cài đặt toàn bộ môi trường phần mềm
#   curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash -s -- --full
# ==============================================================================
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m'

FULL_INSTALL=false
FORCE_INSTALL=false

for arg in "$@"; do
    case "$arg" in
        --full)
            FULL_INSTALL=true
            ;;
        --force)
            FORCE_INSTALL=true
            ;;
    esac
done

echo -e "${MAGENTA}====================================================================${NC}"
echo -e "${MAGENTA}  🚀 KACHITARO DOTFILES & DEV ENVIRONMENT INSTALLER                ${NC}"
echo -e "${MAGENTA}  Repository: https://github.com/kachitaro/dotfiles                ${NC}"
echo -e "${MAGENTA}====================================================================${NC}\n"

# 1. Determine Dotfiles Directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/wezterm/wezterm.lua" ]; then
    DOTFILES_DIR="$SCRIPT_DIR"
else
    DOTFILES_DIR="$HOME/.dotfiles"
fi

# 2. Prepare ~/.local/bin
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"
export DOTFILES_DIR="$DOTFILES_DIR"

DOT_BIN="$BIN_DIR/dot"

# 3. Detect Platform & Download Binary Release
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

TARGET=""
case "$OS" in
    linux)
        case "$ARCH" in
            x86_64) TARGET="x86_64-unknown-linux-gnu" ;;
            aarch64|arm64) TARGET="aarch64-unknown-linux-gnu" ;;
        esac
        ;;
    darwin)
        case "$ARCH" in
            arm64|aarch64) TARGET="aarch64-apple-darwin" ;;
            x86_64) TARGET="x86_64-apple-darwin" ;;
        esac
        ;;
esac

INSTALLED_FROM_RELEASE=false
if [ -n "$TARGET" ]; then
    RELEASE_URL="https://github.com/kachitaro/dotfiles/releases/latest/download/dot-${TARGET}.tar.gz"
    TEMP_TAR="/tmp/dot-${TARGET}.tar.gz"
    echo -e "${CYAN}🔹 Đang tải binary release (${TARGET}) từ GitHub...${NC}"
    if curl -fsSL -o "$TEMP_TAR" "$RELEASE_URL" 2>/dev/null; then
        tar -xzf "$TEMP_TAR" -C "$BIN_DIR" dot 2>/dev/null || tar -xzf "$TEMP_TAR" -C "$BIN_DIR"
        chmod +x "$DOT_BIN"
        rm -f "$TEMP_TAR"
        INSTALLED_FROM_RELEASE=true
        echo -e "  ${GREEN}✅ Đã tải và thiết lập binary 'dot' tại $DOT_BIN${NC}"
    else
        echo -e "  ${YELLOW}⚠️ Không thể tải binary release từ GitHub (offline hoặc chưa phát hành).${NC}"
    fi
fi

if [ "$INSTALLED_FROM_RELEASE" = false ]; then
    LOCAL_RELEASE="$DOTFILES_DIR/cli/target/release/dot"
    if [ -f "$LOCAL_RELEASE" ]; then
        cp "$LOCAL_RELEASE" "$DOT_BIN"
        chmod +x "$DOT_BIN"
        echo -e "  ${GREEN}✅ Đã dùng binary có sẵn tại $DOT_BIN${NC}"
    elif command -v cargo >/dev/null 2>&1 && [ -f "$DOTFILES_DIR/cli/Cargo.toml" ]; then
        echo -e "${CYAN}🔹 Biên dịch CLI từ mã nguồn qua Cargo...${NC}"
        cargo build --release --manifest-path "$DOTFILES_DIR/cli/Cargo.toml"
        if [ -f "$LOCAL_RELEASE" ]; then
            cp "$LOCAL_RELEASE" "$DOT_BIN"
            chmod +x "$DOT_BIN"
            echo -e "  ${GREEN}✅ Đã biên dịch thành công 'dot' vào $DOT_BIN${NC}"
        fi
    fi
fi

# 4. Full Machine Environment Setup (--full)
if [ "$FULL_INSTALL" = true ]; then
    echo -e "${CYAN}🔹 Đang cài đặt các công cụ hệ thống...${NC}"
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -y
        sudo apt-get install -y git curl wget unzip build-essential ripgrep fzf zoxide
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Syu --noconfirm git curl wget unzip base-devel ripgrep fd fzf bat eza zoxide
    elif command -v brew >/dev/null 2>&1; then
        brew install git curl ripgrep fd fzf bat eza zoxide starship neovim
    fi

    # Starship
    if ! command -v starship >/dev/null 2>&1; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "$BIN_DIR"
    fi

    # Clone dotfiles repo if missing
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        echo -e "${CYAN}🔹 Đang clone dotfiles repository về $DOTFILES_DIR...${NC}"
        if command -v git >/dev/null 2>&1; then
            mkdir -p "$(dirname "$DOTFILES_DIR")"
            git clone https://github.com/kachitaro/dotfiles.git "$DOTFILES_DIR"
            echo -e "  ${GREEN}✅ Dotfiles đã sẵn sàng tại $DOTFILES_DIR${NC}"
        fi
    fi
fi

# 5. Inject Configurations
if [ -x "$DOT_BIN" ]; then
    echo -e "${CYAN}🔹 Đồng bộ liên kết cấu hình qua 'dot inject'...${NC}"
    INJECT_ARGS=("inject")
    if [ "$FORCE_INSTALL" = true ]; then INJECT_ARGS+=("--force"); fi
    "$DOT_BIN" "${INJECT_ARGS[@]}"
fi

echo -e "\n${GREEN}====================================================================${NC}"
echo -e "${GREEN}  🎉 HOÀN TẤT THIẾT LẬP KACHITARO DOTFILES!                        ${NC}"
echo -e "${GREEN}====================================================================${NC}"
echo -e "  👉 Lệnh 'dot' đã sẵn sàng trong PATH (~/.local/bin)."
echo -e "  👉 Bạn có thể dùng 'dot --help' để xem toàn bộ hướng dẫn."
echo -e "${GREEN}====================================================================${NC}\n"
````

## File: themes/generated/theme.lua
````lua
-- Auto-generated by Theme Engine
return {
  bg = "#1e1e2e",
  fg = "#cdd6f4",
  black = "#45475a",
  red = "#f38ba8",
  green = "#a6e3a1",
  yellow = "#f9e2af",
  blue = "#89b4fa",
  magenta = "#f5c2e7",
  cyan = "#94e2d5",
  white = "#bac2de",
}
````

## File: powershell/functions.ps1
````powershell
# ==========================================
# FILE: functions.ps1
# ==========================================

# ------------------------------------------
# 1. LINUX ALIASES & UTILITIES
# ------------------------------------------
function grep {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        $InputObject,
        [Parameter(Position = 0)]
        [string]$Pattern,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$ArgumentList
    )
    begin {
        $pipelineItems = [System.Collections.Generic.List[string]]::new()
    }
    process {
        if ($null -ne $InputObject) {
            $pipelineItems.Add($InputObject.ToString())
        }
    }
    end {
        if ($pipelineItems.Count -gt 0) {
            if (Get-Command rg -ErrorAction SilentlyContinue) {
                $pipelineItems | rg $Pattern @ArgumentList
            } else {
                $pipelineItems | Select-String -Pattern $Pattern
            }
        } else {
            if (Get-Command rg -ErrorAction SilentlyContinue) {
                rg $Pattern @ArgumentList
            } elseif ($ArgumentList.Count -ge 1) {
                Get-ChildItem -Path $ArgumentList[0] -Recurse -File -ErrorAction SilentlyContinue | Select-String -Pattern $Pattern
            } else {
                Select-String -Pattern $Pattern
            }
        }
    }
}

function find {
    if (Get-Command fd -ErrorAction SilentlyContinue) {
        fd @args
    } else {
        Get-ChildItem @args
    }
}

function which($name) {
    Get-Command $name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition
}

function touch {
    param (
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$files
    )
    foreach ($file in $files) {
        if (Test-Path $file) {
            (Get-Item $file).LastWriteTime = Get-Date
        } else {
            New-Item -ItemType File -Path $file | Out-Null
        }
    }
}

# ------------------------------------------
# 2. SYSTEM SIZE UTILITIES
# ------------------------------------------

# Hàm tính dung lượng thư mục dùng chung
function Get-FolderSize($path) {
    if (Test-Path $path) {
        $size = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        return [math]::Round($size / 1GB, 2)
    }
    return 0
}

# Lệnh kiểm tra dung lượng các ứng dụng đã cài đặt
function Get-AppSizeReport {
    $paths = @(
        "$env:ProgramFiles",
        "${env:ProgramFiles(x86)}",
        "$env:LOCALAPPDATA\Programs",
        "$env:LOCALAPPDATA\Microsoft",
        "$env:APPDATA",
        "$env:USERPROFILE\scoop\apps"
    )

    Write-Host "Đang quét dung lượng các ứng dụng, vui lòng chờ..." -ForegroundColor Cyan

    # Tối ưu hóa: Gán trực tiếp output của vòng lặp thay vì dùng +=
    $results = foreach ($basePath in $paths) {
        if (Test-Path $basePath) {
            Get-ChildItem -Path $basePath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $size = Get-FolderSize $_.FullName
                if ($size -gt 0) {
                    [PSCustomObject]@{
                        Application = $_.Name
                        Path        = $_.FullName
                        SizeGB      = $size
                    }
                }
            }
        }
    }

    $results | Sort-Object -Property SizeGB -Descending | Format-Table -AutoSize
}

# Lệnh kiểm tra tổng quan dung lượng hệ điều hành
function Get-SystemSizeReport {
    Write-Host "====== Checking Windows Size ======" -ForegroundColor Green
    Write-Host "Đang tính toán, vui lòng chờ..." -ForegroundColor Cyan

    $totalC = (Get-PSDrive C).Used / 1GB
    $windowsSize = Get-FolderSize "C:\Windows"
    $programFiles = Get-FolderSize "C:\Program Files"
    $programFilesX86 = Get-FolderSize "C:\Program Files (x86)"
    $users = Get-FolderSize "C:\Users"

    $winVer = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
    $baseline = if ($winVer -like "*Windows 11*") { 25 } else { 18 } 
    $extra = $totalC - $baseline

    Clear-Host
    Write-Host "====== Windows Size Report ======" -ForegroundColor Green
    Write-Host "Windows Version        : $winVer"
    Write-Host ("C: Used                : {0:N2} GB" -f $totalC)
    Write-Host ("C:\Windows             : {0:N2} GB" -f $windowsSize)
    Write-Host ("C:\Program Files       : {0:N2} GB" -f $programFiles)
    Write-Host ("C:\Program Files (x86) : {0:N2} GB" -f $programFilesX86)
    Write-Host ("C:\Users               : {0:N2} GB" -f $users)
    Write-Host ""
    Write-Host ("Baseline (clean install) : {0:N2} GB" -f $baseline)
    Write-Host ("Your system is using     : {0:N2} GB" -f $totalC)
    Write-Host ("Extra over baseline      : {0:N2} GB" -f $extra)
}


# ------------------------------------------------------------------------------
# Dotfiles CLI (dot)
# ------------------------------------------------------------------------------
function dot {
    $dotExe = ""
    if (Get-Command "dot.exe" -CommandType Application -ErrorAction SilentlyContinue) {
        $dotExe = (Get-Command "dot.exe" -CommandType Application -ErrorAction SilentlyContinue).Source
    } elseif (Test-Path "$env:USERPROFILE\.local\bin\dot.exe") {
        $dotExe = "$env:USERPROFILE\.local\bin\dot.exe"
    } elseif ($env:DOTFILES_DIR -and (Test-Path (Join-Path $env:DOTFILES_DIR "cli\target\release\dot.exe"))) {
        $dotExe = Join-Path $env:DOTFILES_DIR "cli\target\release\dot.exe"
    } elseif ($env:DOTFILES_DIR -and (Test-Path (Join-Path $env:DOTFILES_DIR "cli\target\debug\dot.exe"))) {
        $dotExe = Join-Path $env:DOTFILES_DIR "cli\target\debug\dot.exe"
    } elseif (Test-Path "$PSScriptRoot\..\cli\target\release\dot.exe") {
        $dotExe = "$PSScriptRoot\..\cli\target\release\dot.exe"
    } elseif (Test-Path "$PSScriptRoot\..\cli\target\debug\dot.exe") {
        $dotExe = "$PSScriptRoot\..\cli\target\debug\dot.exe"
    } elseif (Test-Path "$env:USERPROFILE\.dotfiles\cli\target\release\dot.exe") {
        $dotExe = "$env:USERPROFILE\.dotfiles\cli\target\release\dot.exe"
    } elseif (Test-Path "D:\work\dotfiles\cli\target\release\dot.exe") {
        $dotExe = "D:\work\dotfiles\cli\target\release\dot.exe"
    }

    if ($dotExe) {
        & $dotExe @args
    } else {
        Write-Error "Không tìm thấy dot.exe. Vui lòng chạy install.ps1 hoặc kiểm tra lại `$env:DOTFILES_DIR"
    }
}
````

## File: themes/generated/theme.ps1
````powershell
# Auto-generated by Theme Engine
$env:THEME_NAME="Catppuccin Mocha"
$env:BAT_THEME="Catppuccin Mocha"
$env:THEME_BG="#1e1e2e"
$env:THEME_FG="#cdd6f4"
$env:THEME_BLACK="#45475a"
$env:THEME_RED="#f38ba8"
$env:THEME_GREEN="#a6e3a1"
$env:THEME_YELLOW="#f9e2af"
$env:THEME_BLUE="#89b4fa"
$env:THEME_MAGENTA="#f5c2e7"
$env:THEME_CYAN="#94e2d5"
$env:THEME_WHITE="#bac2de"
````

## File: themes/generated/theme.sh
````bash
# Auto-generated by Theme Engine
export THEME_NAME="Catppuccin Mocha"
export BAT_THEME="Catppuccin Mocha"
export THEME_BG="#1e1e2e"
export THEME_FG="#cdd6f4"
export THEME_BLACK="#45475a"
export THEME_RED="#f38ba8"
export THEME_GREEN="#a6e3a1"
export THEME_YELLOW="#f9e2af"
export THEME_BLUE="#89b4fa"
export THEME_MAGENTA="#f5c2e7"
export THEME_CYAN="#94e2d5"
export THEME_WHITE="#bac2de"
````

## File: install.ps1
````powershell
# ==============================================================================
# 🚀 Windows Dotfiles & Dev Environment Installer
# Usage:
#   # ⚡ Fast Install: Tải CLI dot và gắn cấu hình ngay
#   irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex
#
#   # 🚀 Full Machine Setup: Cài đặt toàn bộ phần mềm, Scoop, Font, Node, Tools
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1))) -Full
# ==============================================================================

[CmdletBinding()]
param (
    [string]$DotfilesDir = "",
    [switch]$Full,            # Cài đặt toàn bộ môi trường phần mềm (Scoop, Neovim, WezTerm, Font, Tool...)
    [switch]$SkipFeatures,    # Bỏ qua kích hoạt tính năng ảo hoá Windows (Hyper-V, WSL)
    [switch]$ForceInstall     # Ghi đè file/cấu hình mà không tạo backup .bak_*
)

$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

function Write-Step   { param ([string]$msg) Write-Host "`n🔹 [STEP] $msg" -ForegroundColor Cyan }
function Write-Succ   { param ([string]$msg) Write-Host "  ✅ $msg" -ForegroundColor Green }
function Write-Warn   { param ([string]$msg) Write-Host "  ⚠️ $msg" -ForegroundColor Yellow }
function Write-Err    { param ([string]$msg) Write-Host "  ❌ $msg" -ForegroundColor Red }
function Write-Header {
    Write-Host @"
====================================================================
  🚀 KACHITARO DOTFILES & DEV ENVIRONMENT INSTALLER
  Repository: https://github.com/kachitaro/dotfiles
====================================================================
"@ -ForegroundColor Magenta
}

Write-Header

# 1. Xác định thư mục Dotfiles
if ([string]::IsNullOrWhiteSpace($DotfilesDir)) {
    if (Test-Path "$PSScriptRoot\wezterm\wezterm.lua") {
        $DotfilesDir = $PSScriptRoot
    } elseif (Test-Path "D:\work\dotfiles") {
        $DotfilesDir = "D:\work\dotfiles"
    } elseif (Test-Path "D:\work") {
        $DotfilesDir = "D:\work\dotfiles"
    } elseif (Test-Path "D:\") {
        $DotfilesDir = "D:\dotfiles"
    } else {
        $DotfilesDir = "$env:USERPROFILE\.dotfiles"
    }
}

# 2. Chuẩn bị thư mục chứa CLI Binary trong PATH (~/.local/bin)
$binDir = "$env:USERPROFILE\.local\bin"
if (!(Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null
}

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$binDir;$userPath", "User")
}
if ($env:Path -notlike "*$binDir*") {
    $env:Path = "$binDir;" + $env:Path
}

[Environment]::SetEnvironmentVariable("DOTFILES_DIR", $DotfilesDir, "User")
$env:DOTFILES_DIR = $DotfilesDir

$dotExe = "$binDir\dot.exe"

# 3. Tải Pre-built Binary Release từ GitHub hoặc Build từ nguồn
Write-Step "Thiết lập Dotfiles CLI (dot.exe)..."
$releaseUrl = "https://github.com/kachitaro/dotfiles/releases/latest/download/dot-x86_64-pc-windows-msvc.zip"
$tempZip = "$env:TEMP\dot-release.zip"
$tempExtract = "$env:TEMP\dot-release-extract"

$installedFromRelease = $false
try {
    Write-Host "  Đang tải binary release từ GitHub..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $releaseUrl -OutFile $tempZip -UseBasicParsing -TimeoutSec 30
    if (Test-Path $tempZip) {
        if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
        Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
        $extractedExe = Get-ChildItem -Path $tempExtract -Filter "dot.exe" -Recurse | Select-Object -First 1
        if ($extractedExe) {
            Copy-Item -Path $extractedExe.FullName -Destination $dotExe -Force
            $installedFromRelease = $true
            Write-Succ "Đã tải và thiết lập binary 'dot.exe' tại $dotExe"
        }
        Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
        Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Warn "Không thể tải release từ GitHub (offline hoặc chưa có release): $($_.Exception.Message)"
}

if (!$installedFromRelease) {
    $localRelease = if ($PSScriptRoot) { "$PSScriptRoot\cli\target\release\dot.exe" } else { "" }
    if ($localRelease -and (Test-Path $localRelease)) {
        Copy-Item -Path $localRelease -Destination $dotExe -Force
        Write-Succ "Đã dùng binary có sẵn tại $dotExe"
    } elseif (Get-Command cargo -ErrorAction SilentlyContinue) {
        $manifest = if ($PSScriptRoot) { "$PSScriptRoot\cli\Cargo.toml" } else { "cli\Cargo.toml" }
        if (Test-Path $manifest) {
            Write-Host "  Biên dịch CLI từ mã nguồn qua Cargo..." -ForegroundColor Gray
            cargo build --release --manifest-path $manifest
            $built = (Split-Path $manifest -Parent) + "\target\release\dot.exe"
            if (Test-Path $built) {
                Copy-Item -Path $built -Destination $dotExe -Force
                Write-Succ "Đã biên dịch thành công 'dot.exe' vào $dotExe"
            }
        }
    }
}

# 4. Nếu có cờ -Full: Cài đặt toàn bộ môi trường phần mềm
if ($Full) {
    Write-Step "Cấu hình PowerShell Execution Policy..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Succ "Execution Policy đã được đặt thành RemoteSigned."

    Write-Step "Kích hoạt Developer Mode (hỗ trợ Symlink)..."
    try {
        $devModeKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
        if (Test-Path $devModeKey) {
            $currentVal = (Get-ItemProperty -Path $devModeKey -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
            if ($currentVal -ne 1) {
                Start-Process powershell -Verb RunAs -Wait -ArgumentList "-NoProfile -Command Set-ItemProperty -Path '$devModeKey' -Name 'AllowDevelopmentWithoutDevLicense' -Value 1 -Type DWord"
            }
        }
        Write-Succ "Developer Mode đã sẵn sàng."
    } catch {
        Write-Warn "Không thể tự động bật Developer Mode."
    }

    Write-Step "Kiểm tra và cài đặt Scoop Package Manager..."
    if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "  Đang tải và cài đặt Scoop..." -ForegroundColor Gray
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        $env:Path = "$env:USERPROFILE\scoop\shims;$env:USERPROFILE\scoop\apps\scoop\current\bin;" + $env:Path
    }
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Succ "Scoop đã sẵn sàng."
        $buckets = @("main", "extras", "nerd-fonts", "nonportable")
        foreach ($bucket in $buckets) {
            scoop bucket add $bucket 2>$null
        }
        scoop update
    }

    Write-Step "Cài đặt các ứng dụng và công cụ qua Scoop..."
    $corePackages = @(
        "main/git", "main/7zip", "main/curl", "main/pwsh", "main/neovim",
        "main/ripgrep", "main/fd", "main/fzf", "main/bat", "main/eza",
        "main/lazygit", "main/starship", "main/carapace", "main/atuin",
        "main/zoxide", "main/python", "main/fnm", "main/bun",
        "vcredist-aio", "extras/wezterm", "extras/im-select", "nerd-fonts/JetBrainsMono-NF"
    )
    foreach ($pkg in $corePackages) {
        Write-Host "  Đang kiểm tra / cài đặt: $pkg ..." -ForegroundColor Gray
        scoop install $pkg
    }
    Write-Succ "Hoàn tất cài đặt các gói Scoop."

    Write-Step "Cài đặt các module PowerShell (PSReadLine, PSFzf)..."
    if (!(Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
    }
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    $psModules = @("PSReadLine", "PSFzf")
    foreach ($mod in $psModules) {
        if (!(Get-Module -Name $mod -ListAvailable)) {
            Install-Module -Name $mod -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
        }
    }
    Write-Succ "Modules PowerShell đã sẵn sàng."

    # Clone dotfiles repo nếu chưa có
    if (!(Test-Path "$DotfilesDir\.git")) {
        Write-Step "Đang clone dotfiles repository về $DotfilesDir..."
        if (Get-Command git -ErrorAction SilentlyContinue) {
            $parentDir = Split-Path -Path $DotfilesDir -Parent
            if (!(Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
            git clone https://github.com/kachitaro/dotfiles.git $DotfilesDir
            Write-Succ "Dotfiles đã sẵn sàng tại $DotfilesDir"
        }
    }

    # Bật ảo hoá nếu cần
    if (!$SkipFeatures) {
        Write-Step "Kiểm tra tính năng ảo hoá Windows..."
        $features = @("VirtualMachinePlatform", "Microsoft-Windows-Subsystem-Linux", "HypervisorPlatform")
        foreach ($feat in $features) {
            Enable-WindowsOptionalFeature -Online -FeatureName $feat -All -NoRestart -ErrorAction SilentlyContinue | Out-Null
        }
        Write-Succ "Đã kích hoạt các tính năng ảo hoá (WSL/Hyper-V)."
    }
}

# 5. Đồng bộ liên kết cấu hình (Inject)
if (Test-Path $dotExe) {
    Write-Step "Đồng bộ liên kết cấu hình qua 'dot inject'..."
    $injectArgs = @("inject")
    if ($ForceInstall) { $injectArgs += "--force" }
    & $dotExe @injectArgs
}

Write-Host @"

====================================================================
  🎉 HOÀN TẤT THIẾT LẬP KACHITARO DOTFILES!
====================================================================
  👉 Lệnh 'dot' đã sẵn sàng trong PATH của bạn.
  👉 Bạn có thể dùng 'dot --help' để xem toàn bộ hướng dẫn.
====================================================================
"@ -ForegroundColor Green
````

## File: shell/.bashrc
````
# ==============================================================================
# Dotfiles Shell Configuration (Bash & Zsh compatible for Linux / macOS)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Environment Variables & Paths
# ------------------------------------------------------------------------------
# UTF-8 Encoding
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LESSCHARSET="utf-8"

# Xử lý PATH cho local bin (Quan trọng để chạy các tool như bat qua symlink)
export PATH="$HOME/.local/bin:$PATH"

# Bun & FNM (Thêm vào PATH an toàn)
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"
[ -d "$HOME/.local/share/fnm" ] && export PATH="$HOME/.local/share/fnm:$PATH"

# Eza colors & Custom Config Paths
export EZA_COLORS="di=36"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export BAT_CONFIG_DIR="$HOME/.config/bat"
export BAT_CONFIG_PATH="$HOME/.config/bat/config"

# Dotfiles Directory Logic
if [ -z "$DOTFILES_DIR" ]; then
    if [ -n "$BASH_VERSION" ] && [ -n "${BASH_SOURCE[0]}" ]; then
        DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)"
    elif [ -n "$ZSH_VERSION" ]; then
        DOTFILES_DIR="$(cd "$(dirname "${(%):-%x}")/.." 2>/dev/null && pwd)"
    fi
fi
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# ------------------------------------------------------------------------------
# 2. Base Configuration & Editors
# ------------------------------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
    export VISUAL='nvim'
    alias vi='nvim'
    alias vim='nvim'
fi

# ------------------------------------------------------------------------------
# 3. Aliases
# ------------------------------------------------------------------------------
alias g='git'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'

# --- Eza (Modern ls) ---
if command -v eza >/dev/null 2>&1; then
    export EZA_STANDARD_OPTIONS="--color=always --icons=always --group-directories-first"
    alias ls="eza $EZA_STANDARD_OPTIONS"
    alias ll="eza -al $EZA_STANDARD_OPTIONS --git --time-style=long-iso --color-scale"
    alias la="eza -a $EZA_STANDARD_OPTIONS"
    alias lt="eza -a --tree --level=3 $EZA_STANDARD_OPTIONS"
else
    alias ll='ls -lh'
    alias la='ls -lah'
fi

# --- Bat (Modern cat) ---
# Xử lý trường hợp Ubuntu cài thành batcat
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
fi

if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
    alias b='bat'
fi

# ------------------------------------------------------------------------------
# 4. Tool Initializations (Lazy Load / Check)
# ------------------------------------------------------------------------------

# Detect current shell (zsh or bash)
CURRENT_SHELL=$(basename "$SHELL")

# --- FNM (Fast Node Manager) ---
if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd --shell $CURRENT_SHELL)"
fi

# --- Starship Prompt ---
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init $CURRENT_SHELL)"
fi

# --- Carapace Multi-shell Completion ---
if command -v carapace >/dev/null 2>&1; then
    export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        source <(carapace _carapace zsh)
    elif [ "$CURRENT_SHELL" = "bash" ]; then    
        source <(carapace _carapace bash)
    fi
fi

# --- Fzf ---
if command -v fzf >/dev/null 2>&1; then
    # Cấu hình FZF nâng cao với eza và bat
    export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --info=inline"
    export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza -a --tree --level=2 --color=always --icons=always {}; else bat --color=always --style=numbers,changes {}; fi' --preview-window 'right:55%,border-left' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
    export FZF_ALT_C_OPTS="--preview 'eza -a --tree --level=2 --color=always --icons=always {}' --preview-window 'right:55%,border-left' --bind 'ctrl-/:change-preview-window(down|hidden|)'"

    # Load Keybindings & Completions
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        for f in /usr/share/doc/fzf/examples/key-bindings.zsh /usr/share/fzf/key-bindings.zsh /usr/share/fzf/shell/key-bindings.zsh ~/.fzf.zsh; do
            [ -f "$f" ] && source "$f" && break
        done
        for f in /usr/share/doc/fzf/examples/completion.zsh /usr/share/fzf/completion.zsh /usr/share/fzf/shell/completion.zsh; do
            [ -f "$f" ] && source "$f" && break
        done
    elif [ "$CURRENT_SHELL" = "bash" ]; then
        for f in /usr/share/doc/fzf/examples/key-bindings.bash /usr/share/fzf/key-bindings.bash /usr/share/fzf/shell/key-bindings.bash ~/.fzf.bash; do
            [ -f "$f" ] && source "$f" && break
        done
        for f in /usr/share/doc/fzf/examples/completion.bash /usr/share/fzf/completion.bash /usr/share/fzf/shell/completion.bash; do
            [ -f "$f" ] && source "$f" && break
        done
    fi
fi

# ------------------------------------------------------------------------------
# 5. Functions & Themes
# ------------------------------------------------------------------------------
get_system_size() {
    echo -e "\033[0;32m====== Disk Usage Report ======\033[0m"
    df -h /
    echo ""
    echo -e "\033[0;32m====== Top 10 Largest Directories in Home ======\033[0m"
    du -h -d 2 "$HOME" 2>/dev/null | sort -hr | head -n 10
}

# Load Themes
if [ -f "$DOTFILES_DIR/themes/generated/theme.sh" ]; then
    source "$DOTFILES_DIR/themes/generated/theme.sh"
elif [ -f "$HOME/Desktop/Work/dotfiles/themes/generated/theme.sh" ]; then
    source "$HOME/Desktop/Work/dotfiles/themes/generated/theme.sh"
fi
````

## File: powershell/user_profile.ps1
````powershell
# ==============================================================================
# Dotfiles PowerShell Configuration
# ==============================================================================

# Ngăn chặn load trùng lặp trong cùng một phiên (do PowerShell gọi cả profile.ps1 lẫn Microsoft.PowerShell_profile.ps1)
if ($global:__DOTFILES_PROFILE_LOADED -and -not $env:FORCE_DOTFILES_RELOAD) {
    return
}
$global:__DOTFILES_PROFILE_LOADED = $true

# ------------------------------------------------------------------------------
# 1. Environment & Encodings
# ------------------------------------------------------------------------------
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:LESSCHARSET = 'utf-8'

# Eza, Bat & Fzf Environment Variables
$env:EZA_COLORS = "di=36"
$env:FZF_DEFAULT_OPTS = "--height 50% --layout=reverse --border --info=inline"
$env:FZF_ALT_C_OPTS   = "--preview 'eza -a --tree --level=2 --color=always --icons=always {}' --preview-window 'right:55%,border-left'"
$env:BAT_CONFIG_DIR   = "$env:USERPROFILE\.config\bat"
$env:BAT_CONFIG_PATH  = "$env:USERPROFILE\.config\bat\config"


# ------------------------------------------------------------------------------
# 2. PSReadLine Foundation (Bắt buộc load ĐẦU TIÊN)
# ------------------------------------------------------------------------------
Import-Module PSReadLine -ErrorAction SilentlyContinue
if (Get-Module -Name PSReadLine) {
    try {
        Set-PSReadLineOption -BellStyle None -ErrorAction SilentlyContinue
        Set-PSReadLineOption -MaximumHistoryCount 100 -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue

        # Tự động duy trì file lịch sử gọn nhẹ (100 dòng) vì đã có Atuin quản lý toàn bộ
        $histPath = (Get-PSReadLineOption).HistorySavePath
        if ($histPath -and (Test-Path $histPath)) {
            $fileInfo = Get-Item $histPath -ErrorAction SilentlyContinue
            if ($fileInfo -and $fileInfo.Length -gt 15KB) {
                $lines = [System.IO.File]::ReadAllLines($histPath)
                if ($lines.Length -gt 150) {
                    $recent = $lines[($lines.Length - 100)..($lines.Length - 1)]
                    [System.IO.File]::WriteAllLines($histPath, $recent)
                }
            }
        }
    } catch {}
}

# ------------------------------------------------------------------------------
# 3. PSFzf (Chỉ lấy Ctrl+F, NHƯỜNG Ctrl+R cho Atuin)
# ------------------------------------------------------------------------------
Import-Module PSFzf -ErrorAction SilentlyContinue
if (Get-Module -Name PSFzf) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f'
}

# ------------------------------------------------------------------------------
# 4. Modern CLI Tools (Phải load SAU PSReadLine để ghi đè phím)
# ------------------------------------------------------------------------------
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    zoxide init powershell | Out-String | Invoke-Expression
}

# Carapace (Ghi đè phím TAB)
if (Get-Command carapace -ErrorAction SilentlyContinue) {
    $env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    carapace _carapace | Out-String | Invoke-Expression
}

# Atuin (Ghi đè phím Mũi tên lên và Ctrl+R)
if (Get-Command atuin -ErrorAction SilentlyContinue) {
   Invoke-Expression ((&atuin init powershell --disable-up-arrow) -join "`n")
}

# ------------------------------------------------------------------------------
# 5. Aliases & Functions
# ------------------------------------------------------------------------------
Set-Alias g git -ErrorAction SilentlyContinue
Set-Alias vim nvim -ErrorAction SilentlyContinue
Set-Alias vi nvim -ErrorAction SilentlyContinue

$usrBinPath = Join-Path $env:USERPROFILE "scoop\apps\git\current\usr\bin"
if (Test-Path (Join-Path $usrBinPath "tig.exe")) { Set-Alias tig (Join-Path $usrBinPath "tig.exe") -ErrorAction SilentlyContinue }
if (Test-Path (Join-Path $usrBinPath "less.exe")) { Set-Alias less (Join-Path $usrBinPath "less.exe") -ErrorAction SilentlyContinue }

# --- Thay thế 'cat' bằng 'bat' ---
Remove-Item alias:cat -Force -ErrorAction SilentlyContinue
function cat { bat --paging=never $args }
function b { bat $args }

# --- Thay thế 'ls' bằng 'eza' ---
Remove-Item alias:ls -Force -ErrorAction SilentlyContinue
function ls { eza --color=always --icons=always --group-directories-first $args }
function ll { eza -al --color=always --icons=always --group-directories-first --git --time-style=long-iso --color-scale $args }
function la { eza -a --color=always --icons=always --group-directories-first $args }
function lt { eza -a --tree --level=3 --color=always --icons=always --group-directories-first $args }

# ------------------------------------------------------------------------------
# 6. Load External Scripts & Themes
# ------------------------------------------------------------------------------
# Thiết lập biến DOTFILES_DIR
if (-not $env:DOTFILES_DIR -and $PSScriptRoot) {
    $env:DOTFILES_DIR = Split-Path -Path $PSScriptRoot -Parent
}
if ($env:DOTFILES_DIR -and (Test-Path "$env:DOTFILES_DIR\bin")) {
    if ($env:PATH -notlike "*$env:DOTFILES_DIR\bin*") {
        $env:PATH = "$env:DOTFILES_DIR\bin;" + $env:PATH
    }
}
$localBin = Join-Path $env:USERPROFILE ".local\bin"
if (Test-Path $localBin) {
    if ($env:PATH -notlike "*$localBin*") {
        $env:PATH = "$localBin;" + $env:PATH
    }
}

# Load functions.ps1
$funcPath = Join-Path $PSScriptRoot "functions.ps1"
if (-not (Test-Path $funcPath)) {
    $funcPath = Join-Path -Path $env:USERPROFILE -ChildPath ".config\powershell\functions.ps1"
}
if (Test-Path -Path $funcPath) {
    . $funcPath
} else {
    Write-Warning "Không tìm thấy file functions.ps1 tại: $funcPath"
}

# Load Themes
$theme_candidates = @(
    $(if ($env:DOTFILES_DIR) { Join-Path $env:DOTFILES_DIR "themes\generated\theme.ps1" }),
    "$env:USERPROFILE\.dotfiles\themes\generated\theme.ps1",
    "$env:USERPROFILE\Desktop\Work\dotfiles\themes\generated\theme.ps1"
)
foreach ($t_path in $theme_candidates) {
    if ($t_path -and (Test-Path $t_path)) {
        . $t_path
        break
    }
}
````

## File: README.md
````markdown
# 🛠️ Cross-Platform Dotfiles & Dev Environment

![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/anhtai2k)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)

🌐 **Language**: **English** | [Tiếng Việt](README.vi.md)

A personal cross-platform dotfiles suite for **PowerShell 7**, **Bash / Zsh**, modern CLI tools, **WezTerm** GPU terminal emulator, and **Neovim (NvChad)** IDE, powered by a native Rust management CLI (`k-dot` / `dot`) & **Theme Engine**.

Rebuild your development environment on **Windows 11/10** and **Linux / WSL / macOS** with a single command.

---

## 📸 Showcase & Preview

![Dotfiles Terminal & Neovim Preview](assets/showcase.png)

## 📑 Table of Contents

- [📸 Showcase & Preview](#-showcase--preview)
- [🚀 Installation Guide](#-installation-guide)
- [🧰 Management with `dot` CLI](#-management-with-dot-cli)
- [🎨 Theme Engine (System-wide Color Sync)](#-theme-engine-system-wide-color-sync)
- [⌨️ Keybindings & Utilities](#️-keybindings--utilities)
- [☕ Support / Donate](#-support--donate)
- [📜 License](#-license)

---

## 🚀 Installation Guide

### 1. Windows (PowerShell)

Open **PowerShell** (Run as Administrator recommended for full setup) and run:

```powershell
# ⚡ Fast Install: Downloads dot CLI binary & syncs configs immediately
irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex

# 🚀 Full Machine Setup: Installs Scoop, Neovim, WezTerm, Font, Node, Tools & virtualization
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1))) -Full
```

### 2. Linux / macOS

Open **Terminal** and run:

```bash
# ⚡ Fast Install: Downloads pre-built dot binary & syncs configs immediately
curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash

# 🚀 Full Machine Setup: Installs system packages (apt/brew/pacman), Neovim, WezTerm, Font, Node & Tools
curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash -s -- --full
```

### 3. Run Directly from Cloned Repo

```bash
# Windows
.\install.ps1        # or .\install.ps1 -Full

# Linux/macOS
./install.sh         # or ./install.sh --full
```

> [!IMPORTANT]
> After installing on Windows, **restart your machine** to apply Hyper-V, WSL, and font settings. On Linux/macOS, run `source ~/.bashrc` or open a new terminal tab.

### 4. Overwrite & Uninstall

| Action                                              | Windows                       | Linux/macOS              |
| :-------------------------------------------------- | :---------------------------- | :----------------------- |
| Overwrite (skip backup)                             | `.\install.ps1 -ForceInstall` | `./install.sh --force`   |
| Uninstall (remove symlinks, restore original shell) | `dot uninstall`               | `dot uninstall`          |

---

## 🧰 Management with `dot` CLI (Rust-powered)

The management CLI (`k-dot` / `dot`) is written in **Rust** for blazing-fast startup, robust cross-platform path resolution, and native symlink handling without runtime dependencies.

```bash
dot init [path]                  # Initialize standalone dotfiles workspace (default ~/.dotfiles) with starter theme.json
dot install                      # Run system installer (Options: --force / -ForceInstall)
dot update                       # Self-update CLI binary (dot) to latest version from GitHub Release
dot add <path>                   # Adopt a config folder into repo (e.g. dot add ~/.config/alacritty)
dot eject                        # Unlink dotfiles and restore independent real files to system
dot inject                       # Re-link dotfiles symlinks and configurations into system (Options: --force)
dot uninstall                    # Fully uninstall dotfiles
dot theme reload                 # Recompile and apply theme from theme.json
dot theme path                   # Print absolute path of themes/generated directory (for dynamic scripts)
dot --help                       # Display help menu
```

### 🦀 Build CLI from Source

To compile the CLI binary manually:

```bash
cd cli
cargo build --release
```

#### Cross-compilation Targets:
- **Windows (MSVC)**: `cargo build --release --target x86_64-pc-windows-msvc`
- **Linux (x86_64)**: `cargo build --release --target x86_64-unknown-linux-gnu`
- **macOS (Apple Silicon)**: `cargo build --release --target aarch64-apple-darwin`

---

## 🎨 Theme Engine (System-wide Color Sync)

All colors across Neovim, WezTerm, Starship, Bash, Zsh, and PowerShell are synchronized from a **single source of truth**: `themes/theme.json`.

1. Edit colors in `themes/theme.json`.
2. Run `dot theme reload`.
3. The built-in Rust Theme Engine compiles JSON directly into:
   - `themes/generated/theme.lua` (WezTerm & Neovim)
   - `themes/generated/theme.sh` (Bash & Zsh)
   - `themes/generated/theme.ps1` (PowerShell)
   - `atuin/themes/theme.toml` (Atuin Shell History)
4. WezTerm, Neovim, and Shell dynamically pick up the new colors instantly.

Current default theme: **Catppuccin Mocha**.

---

## ⌨️ Keybindings & Utilities

### WezTerm

| Keybinding          | Action                  |
| :------------------ | :---------------------- |
| `Ctrl + Shift + \|` | Split pane vertically   |
| `Ctrl + Shift + D`  | Split pane horizontally |

### Core Shell & Shell Tools

| Keybinding / Command   | Description                                                                       |
| :--------------------- | :-------------------------------------------------------------------------------- |
| `Ctrl + R`             | **Atuin** interactive history search (with full duration, exit code, timestamp)   |
| `Ctrl + F`             | **PSFzf / FZF** file finder                                                       |
| `Tab`                  | **Carapace** rich menu auto-completion (with descriptions & syntax flags)        |
| `z <dir>`              | **Zoxide** jump to frequently used directory                                      |
| `g`                    | Alias for `git`                                                                   |
| `ls`, `ll`, `la`, `lt` | **Eza** modern file listings (icons, git status, tree view)                       |
| `cat <file>`           | **Bat** file viewer with syntax highlighting and line numbers                     |
| `Get-SystemSizeReport` | *(PowerShell)* Detailed disk space analysis across dev directories and caches     |

---

## ☕ Support / Donate

If you find this dotfiles setup useful, consider supporting:

- **Ko-fi**: [ko-fi.com/anhtai2k](https://ko-fi.com/anhtai2k)
- **Star the repo**: ⭐ Leave a star on GitHub!

---

## 📜 License

Distributed under the **MIT License**. See `LICENSE` for more information.
````
