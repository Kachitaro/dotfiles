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

    #[cfg(windows)]
    {
        let local_appdata = dirs::data_local_dir().unwrap_or_else(|| home_dir.join("AppData").join("Local"));
        let config_dir = home_dir.join(".config");

        let app_configs = [
            ("wezterm", config_dir.join("wezterm"), true),
            ("nvim", local_appdata.join("nvim"), true),
            ("nvim", config_dir.join("nvim"), true),
            ("starship", config_dir.join("starship"), true),
            ("atuin", config_dir.join("atuin"), true),
            ("carapace", config_dir.join("carapace"), true),
            ("powershell", config_dir.join("powershell"), true),
            ("scoop", config_dir.join("scoop"), true),
        ];

        for (src_name, dest, is_dir) in app_configs {
            let src = dotfiles_dir.join(src_name);
            if src.exists() {
                create_safe_link(&dest, &src, is_dir, force)?;
            }
        }

        // Special: ~/.wezterm.lua
        let wz_file_src = dotfiles_dir.join("wezterm").join("wezterm.lua");
        let wz_file_dest = home_dir.join(".wezterm.lua");
        if wz_file_src.exists() {
            create_safe_link(&wz_file_dest, &wz_file_src, false, force)?;
        }

        // Re-inject PowerShell profile loading
        inject_powershell_profiles(&dotfiles_dir, &home_dir)?;
    }

    #[cfg(unix)]
    {
        let config_dir = home_dir.join(".config");
        let app_configs = [
            ("wezterm", config_dir.join("wezterm"), true),
            ("nvim", config_dir.join("nvim"), true),
            ("starship", config_dir.join("starship"), true),
            ("atuin", config_dir.join("atuin"), true),
            ("carapace", config_dir.join("carapace"), true),
        ];

        for (src_name, dest, is_dir) in app_configs {
            let src = dotfiles_dir.join(src_name);
            if src.exists() {
                create_safe_link(&dest, &src, is_dir, force)?;
            }
        }

        // Link CLI binary if built
        let local_bin = home_dir.join(".local").join("bin");
        let cli_bin = dotfiles_dir.join("cli").join("target").join("release").join("dot");
        if cli_bin.exists() {
            create_safe_link(&local_bin.join("dot"), &cli_bin, false, force)?;
        }

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
